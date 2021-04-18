class SeriesController < ApplicationController
  before_action :authenticate_user!, only: [:create, :update, :destroy]

  def create
    render json: current_user.series.create(series_with_url)
  end

  def show
    render json: self.series_by_url
  end

  def update
    render json: self.series_by_url.update(series_params)
  end

  def destroy
    render json: self.series_by_url.destroy
  end

  private
    def series_params
      params.require(:series).permit(:title)
    end

    def series_with_url
      {
        **self.series_params,
        url: self.series_params.title.underscore
      }
    end

    def series_by_url
      Series.find_by(url: params[:url])
    end
end
