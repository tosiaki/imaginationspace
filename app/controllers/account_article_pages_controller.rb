class AccountArticlePagesController < ApplicationController
  PAGE_SIZE = 50

  include PictureFunctions

  before_action :prevent_private_response_caching
  before_action :require_authenticated_user!
  before_action :load_owned_article
  before_action :validate_cursor, only: :index
  before_action :load_page, only: [:edit, :update]
  after_action :prevent_private_response_caching

  layout "authentication"

  def index
    pages = @article.pages
      .select(:id, :page_number, :title)
      .reorder(page_number: :asc)
    pages = pages.where("page_number > ?", @after_page) if @after_page

    page = pages.limit(PAGE_SIZE + 1).to_a
    @has_more = page.length > PAGE_SIZE
    @pages = page.first(PAGE_SIZE)
    @next_cursor = @pages.last&.page_number if @has_more
  end

  def edit
  end

  def update
    attributes = page_params
    if inline_upload_data?(attributes[:content])
      attributes = attributes.to_h
      attributes["content"] = InlineUploadAuthorizer.new(user: current_user).call(attributes["content"])
      @page.assign_attributes(attributes)
      @page.content = process_inline_uploads(@page)
      saved = @page.save
    else
      saved = @page.update(attributes)
    end

    if saved
      @updated = true
      render :edit
    else
      render :edit, status: :unprocessable_content
    end
  rescue InlineUploadAuthorizer::InvalidUpload, ActiveRecord::RecordInvalid => error
    @page.assign_attributes(page_params)
    @page.errors.add(:content, upload_error_message(error))
    render :edit, status: :unprocessable_content
  end

  private

  def load_owned_article
    @article = Article.joins(:status)
      .where(statuses: { user_id: current_user.id })
      .find(params[:article_id])
  end

  def load_page
    @page = @article.pages.find_by!(page_number: params[:page_number])
  end

  def validate_cursor
    return if params[:after_page].blank?
    return @after_page = params[:after_page].to_i if params[:after_page].is_a?(String) && params[:after_page].match?(/\A[1-9]\d*\z/)

    head :bad_request
  end

  def page_params
    @page_params ||= params.require(:page).permit(:title, :content)
  end

  def inline_upload_data?(content)
    Nokogiri::HTML.fragment(content.to_s).css("[data-file-data]").any?
  end

  def upload_error_message(error)
    return error.message if error.is_a?(InlineUploadAuthorizer::InvalidUpload)

    "Upload content is not a valid supported image"
  end
end
