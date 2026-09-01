require "rails_helper"

RSpec.describe SeriesController, type: :controller do
  before do
    routes.draw do
      root to: redirect("https://example.com")
      post "series/add", to: "series#add"
      patch "series/:series/move_down/:article", to: "series#move_down"
      delete "series/:series/remove/:article", to: "series#remove"
    end
    allow(controller).to receive(:record_activity)
  end

  let(:owner) { create(:user) }
  let(:other_user) { create(:second_user) }
  let(:series) { Series.create!(title: "Owned", url: "owned", user: owner) }
  let(:first_article) { create_thread_article("First") }
  let(:second_article) { create_thread_article("Second") }
  let(:third_article) { create_thread_article("Third") }

  before do
    series.series_articles.create!(article: first_article, position: 1)
    series.series_articles.create!(article: second_article, position: 2)
  end

  def create_thread_article(title)
    article = Article.new(title: title, max_pages: 1)
    article.thread = article
    article.pages.build(content: "Page", page_number: 1)
    article.save!
    article
  end

  def authenticate_as(user)
    controller.define_singleton_method(:authenticate_user!) { true }
    controller.define_singleton_method(:current_user) { user }
  end

  it "allows the owner to reorder the series" do
    authenticate_as(owner)

    patch :move_down, params: { series: series.url, article: first_article.id }

    expect(series.series_articles.order(:position).pluck(:article_id)).to eq([second_article.id, first_article.id])
  end

  it "allows the owner to add an article to the series" do
    authenticate_as(owner)

    post :add, params: { series: [series.url], articleId: third_article.id }

    expect(series.reload.articles).to include(third_article)
  end

  it "does not allow another user to add to the series" do
    authenticate_as(other_user)

    expect do
      post :add, params: { series: [series.url], articleId: third_article.id }
    end.to raise_error(ActiveRecord::RecordNotFound)

    expect(series.reload.articles).not_to include(third_article)
  end

  it "does not allow another user to reorder the series" do
    authenticate_as(other_user)

    expect do
      patch :move_down, params: { series: series.url, article: first_article.id }
    end.to raise_error(ActiveRecord::RecordNotFound)

    expect(series.series_articles.order(:position).pluck(:article_id)).to eq([first_article.id, second_article.id])
  end

  it "allows the owner to remove an article" do
    authenticate_as(owner)

    delete :remove, params: { series: series.url, article: first_article.id }

    expect(series.reload.articles).to contain_exactly(second_article)
  end

  it "does not allow another user to remove an article" do
    authenticate_as(other_user)

    expect do
      delete :remove, params: { series: series.url, article: first_article.id }
    end.to raise_error(ActiveRecord::RecordNotFound)

    expect(series.reload.articles).to contain_exactly(first_article, second_article)
  end
end
