class BookmarksController < ApplicationController
  before_action :authenticate_user!
  before_action :find_work

  def create
    @bookmark = current_user.bookmarks.build(bookmarkable: @work)
    if @bookmark.save
      flash[:success] = "Added to bookmarks"
    else
      flash[:danger] = "Bookmarking unsuccessful"
    end
    redirect_back fallback_location: @work
  end

  def destroy
    @bookmark = current_user.bookmarks.find_by(bookmarkable: @work)
    if @bookmark.destroy
      flash[:success] = "Removed from bookmarks"
    else
      flash[:danger] = "Unbookmarking unsuccessful"
    end
    redirect_back fallback_location: @work
  end

  private

    def find_work
      if params[:work] == 'drawings'
        @work = Drawing.find(params[:id])
      elsif params[:work] == 'comics'
        @work = Comic.find(params[:id])
      else
        @work = Article.find(params[:id])
      end
    end

end
