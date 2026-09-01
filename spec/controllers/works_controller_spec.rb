require 'rails_helper'

RSpec.describe WorksController, type: :controller do
  before do
    routes.draw do
      post "works/search", to: "works#search"
    end
  end

  it "renders bounded transient search results" do
    post :search, params: { tags: " Tutorial, Tutorial ", comics_page: 1_000, drawings_page: -2 }

    expect(response).to have_http_status(:ok)
    expect(response.headers["Cache-Control"]).to eq("no-store")
    expect(response.headers["X-Robots-Tag"]).to eq("noindex, nofollow")
    expect(assigns(:search_tags)).to eq(["Tutorial"])
    expect(assigns(:comics_page)).to eq(100)
    expect(assigns(:drawings_page)).to eq(1)
  end

  it "rejects an empty search without querying every work" do
    expect(Drawing).not_to receive(:tagged_with)
    expect(Comic).not_to receive(:tagged_with)

    post :search, params: { tags: " " }

    expect(response).to have_http_status(:unprocessable_content)
  end

  it "rejects excessive tag combinations" do
    post :search, params: { tags: (1..6).map { |number| "tag#{number}" }.join(",") }

    expect(response).to have_http_status(:unprocessable_content)
  end

end
