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
    redirect_to @work
  end

  def destroy
    @bookmark = current_user.bookmarks.find_by(bookmarkable: @work)
    if @bookmark.destroy
      flash[:success] = "Removed from bookmarks"
    else
      flash[:danger] = "Unbookmarking unsuccessful"
    end
    redirect_to @work
  end

  private

    def find_work
      if params[:work] == 'drawings'
        @work = Drawing.find(params[:id])
      else
        @work = Comic.find(params[:id])
      end
    end

end
