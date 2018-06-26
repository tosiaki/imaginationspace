class PagesController < ApplicationController
  def home
    @comics = Comic.all.paginate(page: 1, per_page: 100)
    @drawings = Drawing.all.paginate(page: 1, per_page: 100)
    @fandoms_drawings = @drawings.tag_counts_on(:fandoms, order: "count desc")
    @fandoms_comics = @comics.tag_counts_on(:fandoms, order: "count desc")

    if user_signed_in?
      @feed_drawings = current_user.feed_drawings
      @feed_comics = current_user.feed_comics
    end
  end

  def about
  end
end
