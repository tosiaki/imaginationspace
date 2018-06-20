class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    @user_comics = @user.comics
    @user_drawings = @user.drawings
    if @user_comics.any?
      @comic_fandoms = @user_comics.tag_counts_on(:fandoms, limit: 15, order: "count desc")
    end
    if @user_drawings.any?
      @drawing_fandoms = @user_drawings.tag_counts_on(:fandoms, limit: 15, order: "count desc")
    end
  end

  def drawings
    @user = User.find(params[:id])
    if params[:tags]
      tag_list = params[:tags].split(",").map(&:strip)
      @drawings = @user.drawings.tagged_with(tag_list)
    else
      @drawings = @user.drawings
    end
  end
end
