class SignalBoostsController < ApplicationController
  before_action :get_article, only: [:new, :create]
  before_action :get_signal_boost, only: [:edit, :update, :destroy]

  include Concerns::PictureFunctions

  def new
    session[:return_to] ||= request.referer
    @signal_boost = SignalBoost.new
  end

  def create
    @signal_boost = SignalBoost.new(origin: @article, comment: params[:signal_boost][:comment])
    @signal_boost.comment = process_inline_uploads(@signal_boost)
    process_pictures
    if current_user.statuses.create(post: @signal_boost, timeline_time: Time.now)
      flash[:success] = "Posted signal boost."
    else
      flash[:danger] = "Signal boost failed."
    end
    redirect_to session.delete(:return_to) || current_user
  end

  def edit
  end

  def update
    @signal_boost.assign_attributes(signal_boost_params)
    @signal_boost.comment = process_inline_uploads(@signal_boost)
    process_pictures
    if @signal_boost.save
      flash[:success] = "Signal boost updated."
    else
      flash[:danger] = "Signal boost update unsuccessful."
    end
    redirect_to current_user
  end

  def destroy
    @signal_boost.destroy
    redirect_back fallback_location: current_user
  end

  private
    def get_article
      @article = Article.find(params[:id])
    end

    def get_signal_boost
      @signal_boost = current_user.signal_boosts.find(params[:id])
      @article = @signal_boost.origin
    end

    def signal_boost_params
      params.require(:signal_boost).permit(:comment)
    end

    def process_pictures
      if params[:signal_boost][:picture]
        params[:signal_boost][:picture].each do |picture|
          add_picture_to_signal_boost(picture, @signal_boost)
        end
      end
    end
end
