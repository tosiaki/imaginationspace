class YoutubeVideoController < ApplicationController
  def create
    render json: YoutubeVideo.create({
      url: params[:url],
      title: params[:title]
    })
  end

  def show
    render json: video_by_url(params[:url])
  end

  def update
    render json: video_by_url(params[:url]).update_attributes(watched: true, date_watched: Time.now)
  end

  def index
    render json: {}
  end

  private
    def video_by_url(url)
      return YoutubeVideo.find_by(url: url)
    end
end
