class SeriesController < ApplicationController
  protect_from_forgery except: [:create]
  before_action :authenticate_user!, only: [:create, :update, :destroy]

  def create
    render json: current_user.series.create({
      title: params[:title],
      url: params[:title].tr(' ', '_')
    })
    record_activity('create series', "Created series with name #{params[:title]}")
  end

  def show
    @series = Series.includes(:articles).find_by(url: params[:id])
  end

  def index
    render json: Series.all.select(:title, :url)
  end

  def add
    article = Article.find(params[:articleId])
    params[:series].each do |series_url|
      series = Series.find_by(url: series_url)
      series.series_articles.create(article: article, position: series.series_articles.count + 1)
    end
    record_activity('add to series', "Added article #{params[:articleId]} to series #{params[:series].join(',')}.")
    render json: "Added"
  end

  def move_up
    ActiveRecord::Base.transaction do
      series = Series.find_by(url: params[:series])
      listing = series.series_articles.find_by(article: params[:article])
      previous_item = series.series_articles.find_by(position: listing.position - 1)
      listing.decrement!(:position)
      previous_item.increment!(:position)
      record_activity('move article', "Moved article #{params[:article]} up and #{previous_item.id} down.")
    end
    redirect_back(fallback_location: root_path)
  end

  def move_down
    ActiveRecord::Base.transaction do
      series = Series.find_by(url: params[:series])
      listing = series.series_articles.find_by(article: params[:article])
      next_item = series.series_articles.find_by(position: listing.position + 1)
      listing.increment!(:position)
      next_item.decrement!(:position)
      record_activity('move article', "Moved article #{params[:article]} down and #{next_item.id} up.")
    end
    redirect_back(fallback_location: root_path)
  end

  def remove
    series = Series.find_by(url: params[:series])
    series.articles.delete(Article.find(params[:article]))
    redirect_back(fallback_location: root_path)
    record_activity('delete series', "Deleted series #{params[:series]}.")
  end

  def update
    # render json: self.series_by_url.update(series_params)
  end

  def destroy
    # render json: self.series_by_url.destroy
  end

  private
    def series_by_url
      Series.find_by(url: params[:url])
    end
end
