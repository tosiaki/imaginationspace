class ComicPagesController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :change_orientation, :destroy]
  before_action :check_user, only: [:new, :create, :edit, :update, :change_orientation, :destroy]
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
    @current_page = params[:comic_page][:page_number].to_i
    @current_page ||= @comic.comic_pages.count+1
    @current_page = [[ @current_page.abs.round, @comic.comic_pages.count+1 ].min, 1].max
    page_added = false
    params[:comic_page][:new_page].each do |new_page|
      @comic_page = @comic.comic_pages.build(page: @current_page, drawing: new_page, orientation: params[:comic_page][:orientation])
      if @comic_page.valid?
        @comic_page.save
        @comic.comic_pages.each do |existing_page|
          existing_page.increment!(:page) if existing_page.page >= @comic_page.page && existing_page != @comic_page
        end
        @current_page += 1
        page_added = true
      else
        flash[:warning] = "Not all pages were successfully added"
      end
    end
    if page_added
      change_update_time(@comic, @comic.current_max_page)
      redirect_to comic_path(@comic, anchor: "page-#{@current_page-1}")
    else
      @current_page = params[:comic_page][:page_number]
      render 'comic_pages/new'
    end
  end

  def edit
    @comic_page = @comic.comic_pages.find_by( page: params[:page].to_i )
  end

  def update
    page_number = params[:page].to_i
    params[:comic_page][:new_page].each do |new_page|
      if page_number <= @comic.current_max_page
        current_page = @comic.comic_pages.find_by( page: page_number )
        if current_page.update_attributes( drawing: new_page, orientation: params[:comic_page][:orientation] )
          flash[:success] = "Page has been updated"
        else
          flash[:warning] = "Not all pages were successfully updated"
        end
      else
        current_page = @comic.comic_pages.build(page: page_number, drawing: new_page, orientation: params[:comic_page][:orientation])
        if current_page.save
          flash[:success] = "Page has been updated"
          change_update_time(@comic, page_number)
        else
          flash[:warning] = "Not all pages were successfully updated"
        end
      end
      page_number += 1
    end
    redirect_to comic_path(@comic, anchor: "page-#{page_number-1}")
  end

  def change_orientation
    @comic_page = @comic.comic_pages.find_by( page: params[:page].to_i )
    if @comic_page.update_attribute(:orientation, params[:orientation])
      flash[:success] = "Changed page orientation"
    end
    redirect_to comic_path(@comic, anchor: "page-#{@comic_page.page}")
  end

  def destroy
    @comic_page = @comic.comic_pages.find_by( page: params[:page].to_i )
    @comic_page.destroy
    @comic.comic_pages.each do |page|
      page.decrement!(:page) if page.page > params[:page].to_i
    end
    redirect_to comic_path(@comic, anchor: "page-#{[params[:page].to_i, @comic.comic_pages.map(&:page).max].min}")
  end

  private

    def check_user
      @comic = current_user.comics.find_by(id: params[:id])
      @comic = current_user.scanlations.find(params[:id]) unless @comic
      redirect_to Comic.find(params[:id]) unless @comic
    end

    def check_pages
      redirect_to @comic unless @comic.comic_pages.count > 1
    end

    def change_update_time(comic, page_number)
      if comic.max_pages < page_number
        comic.update_attribute(:max_pages, page_number)
        comic.update_attribute(:page_addition, Time.now)
      end
      if comic.pages != 0 && comic.pages < page_number
        comic.update_attribute(:pages, page_number)
      end
    end
end
