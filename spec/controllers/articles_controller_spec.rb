require 'rails_helper'

RSpec.describe ArticlesController, type: :controller do
  before do
    routes.draw do
      get "articles", to: "articles#index"
      get ":board", to: "articles#index"
    end
    controller.define_singleton_method(:current_user) { nil }
    controller.define_singleton_method(:user_signed_in?) { false }
  end

  it "rejects an unknown board before aggregation queries" do
    expect(controller).not_to receive(:get_associated_tags)
    expect(Status).not_to receive(:select_by)

    get :index, params: { board: "crawler-probe" }

    expect(response).to have_http_status(:not_found)
    expect(response.headers["Cache-Control"]).to include("public", "max-age=300")
  end

  it "rejects excessive page depth before aggregation queries" do
    expect(controller).not_to receive(:get_associated_tags)
    expect(Status).not_to receive(:select_by)

    get :index, params: { page: "101" }

    expect(response).to have_http_status(:not_found)
  end

  it "rejects malformed listing dimensions before aggregation queries" do
    expect(controller).not_to receive(:get_associated_tags)
    expect(Status).not_to receive(:select_by)

    invalid_requests = [
      { page: "0" },
      { page: "not-a-page" },
      { order: "random" },
      { show_replies: "unexpected" },
      { tags: (1..6).map { |number| "tag#{number}" }.join(",") },
      { tags: "t" * 101 },
      { thread_id: "not-an-id" },
      { board: "b" * 101 },
      { tags: ["nested", "values"] },
      { page: { number: "2" } }
    ]

    invalid_requests.each do |request_params|
      get :index, params: request_params
      expect(response).to have_http_status(:not_found)
    end
  end

  it "rejects unknown parameters before aggregation queries" do
    expect(controller).not_to receive(:get_associated_tags)
    expect(Status).not_to receive(:select_by)

    get :index, params: { crawler_variant: "unbounded" }

    expect(response).to have_http_status(:not_found)
  end

  it "allows a known board through to the bounded listing query" do
    ArticleTag.create!(context: "fandom", name: "known-board")
    allow(controller).to receive(:get_associated_tags).and_return(nil)
    expect(Status).to receive(:select_by).with(hash_including(board: "known-board", page_number: 1)).and_return([])

    get :index, params: { board: "known-board" }

    expect(response).to have_http_status(:ok)
  end

  it "loads all tag facets with one aggregate query" do
    media_tag = ArticleTag.new(context: "media", name: "Comic")
    language_tag = ArticleTag.new(context: "language", name: "English")
    expect(ArticleTag).to receive(:associate_tags).once.and_return([media_tag, language_tag])
    allow(Status).to receive(:select_by).and_return([])

    get :index

    expect(response).to have_http_status(:ok)
    expect(assigns(:tag_hash)["media"]).to eq([media_tag])
    expect(assigns(:tag_hash)["language"]).to eq([language_tag])
    expect(assigns(:tag_hash)["fandom"]).to eq([])
  end

end
