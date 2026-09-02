class AccountArticlesController < ApplicationController
  PAGE_SIZE = 25

  before_action :prevent_private_response_caching
  before_action :require_authenticated_user!
  before_action :validate_cursor
  after_action :prevent_private_response_caching

  layout "authentication"

  def index
    articles = Article.joins(:status)
      .where(statuses: { user_id: current_user.id })
      .select(:id, :title, :updated_at, :pages_count)
      .order(id: :desc)
    articles = articles.where("articles.id < ?", @before_id) if @before_id

    page = articles.limit(PAGE_SIZE + 1).to_a
    @has_more = page.length > PAGE_SIZE
    @articles = page.first(PAGE_SIZE)
    @next_cursor = @articles.last&.id if @has_more
  end

  private

  def validate_cursor
    return if params[:before_id].blank?
    return @before_id = params[:before_id].to_i if params[:before_id].is_a?(String) && params[:before_id].match?(/\A[1-9]\d*\z/)

    head :bad_request
  end
end
