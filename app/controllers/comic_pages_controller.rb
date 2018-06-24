class ComicPagesController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :destroy]
  before_action :check_user, only: [:new, :create, :destroy]
  before_action :check_pages, only: :destroy

  def new
    @comic_page = @comic.comic_pages.build
    if params[:page].nil?
      @current_page = @comic.comic_pages.count+1
    else
      @current_page = params[:page]
    end
  end

  def create
    @comic_page = @comic.comic_pages.build(page: params[:comic_page][:page_number], drawing: params[:comic_page][:new_page])
    @comic_page.page = [ @comic_page.page.abs.round, @comic.comic_pages.count+1 ].min
    if @comic_page.valid?
      @comic_page.save
      @comic.comic_pages.each do |page|
        page.increment!(:page) if page.page >= @comic_page.page && page != @comic_page
      end
      new_max_page = @comic.comic_pages.map(&:page).max
      if @comic.pages != 0 && @comic.pages < new_max_page
        @comic.update_attribute(:pages, new_max_page)
      end
      redirect_to @comic
    else
      render 'comics/new_page'
    end
  end

  def destroy
    @comic_page = @comic.comic_pages.find_by( page: params[:page].to_i )
    @comic_page.destroy
    @comic.comic_pages.each do |page|
      page.decrement!(:page) if page.page > params[:page].to_i
    end
    redirect_to @comic
  end

  private

    def check_user
      @comic = current_user.comics.find(params[:id])
      redirect_to Comic.find(params[:id]) unless @comic
    end

    def check_pages
      redirect_to @comic unless @comic.comic_pages.count > 1
    end
end
