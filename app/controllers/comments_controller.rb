class CommentsController < ApplicationController
  before_action :authenticate_user!, only: :destroy
  before_action :user_is_author, only: :destroy

  def create
    @commentable = params[:parent].constantize.find(params["#{params[:parent].downcase}_id"])
    @comment = @commentable.comments.build(comment_params)
    if params[:parent] == 'Comment'
      @comment.work = @commentable.work
    else
      @comment.work = @commentable
    end

    if user_signed_in?
      @comment.user_id = current_user.id
    end
    if @comment.save
      flash[:success] = "Posted comment"
    else
      flash[:errors] = @comment.errors.full_messages
    end
    redirect_back fallback_location: @commentable
  end

  def destroy
    if @comment.destroy
      flash[:success] = "Comment deleted"
    else
      flash[:danger] = "Deletion unsuccessful"
    end
    redirect_back fallback_location: @comment.commentable
  end

  private
    def comment_params
      params.require(:comment).permit(:name, :email, :content)
    end

    def user_is_author
      @comment = Comment.find(params[:id])
      redirect_to @comment.commentable unless @comment.user == current_user
    end
end
