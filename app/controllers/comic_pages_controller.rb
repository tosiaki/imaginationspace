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
    page_number = sanitize_page_number(params[:comic_page][:page_number].to_i)
    page_added = false
    params[:comic_page][:new_page].each do |new_page|
      if @comic.add_page(drawing: new_page, orientation: params[:comic_page][:orientation], page_number: page_number)
        page_number += 1
        page_added = true
      else
        flash[:warning] = "Not all pages were successfully added"
      end
    end
    if page_added
      redirect_to show_page_comic_path(@comic, page: page_number-1)
    else
      @comic_page = @comic.comic_pages.build
      @current_page = params[:comic_page][:page_number]
      render 'comic_pages/new'
    end
  end

  def edit
    @comic_page = @comic.comic_pages.find_by( page: params[:page].to_i )
  end

  def update
    page_number = sanitize_page_number(params[:page].to_i)
    params[:comic_page][:new_page].each do |new_page|
      if @comic.replace_page(drawing: new_page, orientation: params[:comic_page][:orientation], page_number: page_number)
        flash[:success] = "Page has been updated"
      else
        flash[:warning] = "Not all pages were successfully updated"
      end
      page_number += 1
    end
    redirect_to show_page_comic_path(@comic, page: page_number-1)
  end

  def change_orientation
    @comic_page = @comic.comic_pages.find_by( page: params[:page].to_i )
    if @comic_page.update_attribute(:orientation, params[:orientation])
      flash[:success] = "Changed page orientation"
    end
    redirect_to show_page_comic_path(@comic, page: @comic_page.page)
  end

  def destroy
    @comic_page = @comic.comic_pages.find_by( page: params[:page].to_i )
    @comic_page.destroy
    @comic.comic_pages.each do |page|
      page.decrement!(:page) if page.page > params[:page].to_i
    end
    redirect_to show_page_comic_path(@comic, page: [params[:page].to_i, @comic.comic_pages.map(&:page).max].min)
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

    def sanitize_page_number(page)
      page_number = page || @comic.next_page
      page_number = [[page_number.abs.round, @comic.next_page].min, 1].max
    end
end
