class WorksController < ApplicationController
  MAX_SEARCH_TAGS = 5
  MAX_TAG_LENGTH = 100
  MAX_SEARCH_PAGE = 100
  SEARCH_PAGE_SIZE = 50

  def index
    @comics = Comic.all.paginate(page: params[:comics_page], per_page: 100)
    @drawings = Drawing.all.paginate(page: params[:drawings_page], per_page: 100)
  end

  def search
    response.headers["Cache-Control"] = "no-store"
    response.headers["X-Robots-Tag"] = "noindex, nofollow"

    @search_tags = normalized_search_tags
    return head :unprocessable_content unless valid_search_tags?

    @drawings_page = bounded_page(params[:drawings_page])
    @comics_page = bounded_page(params[:comics_page])

    tagged_drawings = Drawing.tagged_with(@search_tags)
    tagged_comics = Comic.tagged_with(@search_tags)
    if params[:rating].present?
      rating = Drawing.ratings[params[:rating]]
      return head :unprocessable_content unless rating

      tagged_drawings = tagged_drawings.where(rating: rating)
      tagged_comics = tagged_comics.where(rating: rating)
    end

    @drawings = tagged_drawings.paginate(page: @drawings_page, per_page: SEARCH_PAGE_SIZE)
    @comics = tagged_comics.paginate(page: @comics_page, per_page: SEARCH_PAGE_SIZE)

  end

  private

    def normalized_search_tags
      params[:tags].to_s.split(",").map(&:strip).reject(&:blank?).uniq
    end

    def valid_search_tags?
      @search_tags.present? &&
        @search_tags.length <= MAX_SEARCH_TAGS &&
        @search_tags.all? { |tag| tag.length <= MAX_TAG_LENGTH }
    end

    def bounded_page(value)
      value.to_i.clamp(1, MAX_SEARCH_PAGE)
    end
end
