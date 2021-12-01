class YoutubeVideoController < ApplicationController
  def create
    if video_by_url(params[:url])
      render json: { message: "Video already added." }
    else
      render json: YoutubeVideo.create({
        url: params[:url],
        title: params[:title]
      })
    end
  end

  def show
    render json: video_by_url(params[:url])
  end

  def set_watched
    render json: video_by_url(params[:url]).update(watched: true, date_watched: Time.now)
  end

  def index
    render json: {}
  end

  private
    def video_by_url(url)
      return YoutubeVideo.find_by(url: url)
    end
end
