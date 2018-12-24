class SignalBoostsController < ApplicationController
  before_action :get_article, only: [:new, :create]
  before_action :get_signal_boost, only: [:edit, :update, :destroy]

  def new
    @signal_boost = SignalBoost.new
  end

  def create
    @signal_boost = SignalBoost.create(origin: @article, comment: params[:signal_boost][:comment])
    current_user.statuses.create(post: @signal_boost, timeline_time: Time.now)
    if params[:signal_boost][:picture]
      params[:signal_boost][:picture].each do |picture|
        article_picture = ArticlePicture.create(picture: picture)
        @signal_boost.append(render_to_body(partial: 'article_pages/image_tag', locals: {picture: article_picture}).html_safe)
      end
    end
    redirect_to @article.user
  end

  def edit
  end

  def destroy
    @signal_boost.destroy
    redirect_to @user
  end

  private
    def get_article
      @user = User.find(params[:user_id])
      @article = @user.articles.find(params[:id])
    end

    def get_signal_boost
      @user = User.find(params[:user_id])
      @signal_boost = @user.signal_boosts.find(params[:id])
      @article = @signal_boost.origin
    end
end
