class SeriesController < ApplicationController
  before_action :authenticate_user!, only: [:create, :add, :move_up, :move_down, :remove, :update, :destroy]
  before_action :set_owned_series, only: [:move_up, :move_down, :remove, :update, :destroy]

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
    series_urls = Array(params[:series]).map(&:to_s).reject(&:blank?).uniq
    raise ActiveRecord::RecordNotFound if series_urls.empty?

    series_by_url = current_user.series.where(url: series_urls).index_by(&:url)
    raise ActiveRecord::RecordNotFound unless series_by_url.size == series_urls.size

    Series.transaction do
      series_urls.each do |series_url|
        series = series_by_url.fetch(series_url)
        series.with_lock do
          series.series_articles.find_or_create_by!(article: article) do |listing|
            listing.position = series.series_articles.maximum(:position).to_i + 1
          end
        end
      end
    end
    record_activity('add to series', "Added article #{params[:articleId]} to series #{series_urls.join(',')}.")
    render json: "Added"
  end

  def move_up
    @series.with_lock do
      listing = @series.series_articles.find_by!(article: params[:article])
      previous_item = @series.series_articles.find_by!(position: listing.position - 1)
      listing.decrement!(:position)
      previous_item.increment!(:position)
      record_activity('move article', "Moved article #{params[:article]} up and #{previous_item.id} down.")
    end
    redirect_back(fallback_location: root_path)
  end

  def move_down
    @series.with_lock do
      listing = @series.series_articles.find_by!(article: params[:article])
      next_item = @series.series_articles.find_by!(position: listing.position + 1)
      listing.increment!(:position)
      next_item.decrement!(:position)
      record_activity('move article', "Moved article #{params[:article]} down and #{next_item.id} up.")
    end
    redirect_back(fallback_location: root_path)
  end

  def remove
    @series.articles.delete(Article.find(params[:article]))
    redirect_back(fallback_location: root_path)
    record_activity('remove from series', "Removed article #{params[:article]} from series #{params[:series]}.")
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

    def set_owned_series
      @series = current_user.series.find_by!(url: params[:series] || params[:id] || params[:url])
    end
end
