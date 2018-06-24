class WorksController < ApplicationController
  def index
    @comics = Comic.all.paginate(page: params[:comics_page], per_page: 100)
    @drawings = Drawing.all.paginate(page: params[:drawings_page], per_page: 100)
  end

  def search
    if params[:tags]
      tag_list = params[:tags].split(",").map(&:strip)
      tagged_drawings = Drawing.tagged_with(tag_list);
      tagged_comics = Comic.tagged_with(tag_list)
      if params[:rating]
        tagged_drawings = tagged_drawings.where(rating: Drawing.ratings[params[:rating]])
        tagged_comics = tagged_comics.where(rating: Drawing.ratings[params[:rating]])
      end
      @drawings = tagged_drawings.paginate(page: params[:drawings_page], per_page: 100)
      @comics = tagged_comics.paginate(page: params[:comics_page], per_page: 100)
    else
      @drawings = Drawing.all.paginate(page: params[:drawings_page], per_page: 100)
      @comics = Comic.all.paginate(page: params[:comics_page], per_page: 100)
    end
  end
end
