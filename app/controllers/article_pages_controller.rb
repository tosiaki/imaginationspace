class ArticlePagesController < ApplicationController
  before_action :check_user, only: [:new, :create, :edit, :update, :destroy]
  before_action :check_pages, only: :destroy

  include Concerns::PictureFunctions

  def new
    @page = @article.pages.build
  end

  def create
    page_number = sanitize_page_number(params[:page][:page_number].to_i)
    if @article.add_page(content: params[:page][:content], title: params[:page][:title], page_number: page_number)
      if params[:page][:picture]
        params[:page][:picture].each_with_index do |picture, index|
          if index > 0
            if params[:options][:new_pages] == '1'
              page_number += 1
              @article.add_page(page_number: page_number)
            end
          end
          add_picture_to_page(picture, @article, page_number)
        end
      end
    else
      flash[:warning] = "Not all pages were successfully added"
    end
    redirect_to show_page_user_article_path(current_user,@article, page_number: page_number)
  end

  def edit
    @page = @article.pages.find_by( page_number: params[:page_number].to_i )
  end

  def update
    page_number = sanitize_page_number(params[:page_number].to_i)
    if @article.update_page(content: params[:page][:content], title: params[:page][:title], page_number: page_number)
      flash[:success] = "Page has been updated"
    else
      flash[:warning] = "Update unsuccessful"
    end
    redirect_to show_page_user_article_path(current_user, @article, page_number)
  end

  def destroy
    if @article.pages.count > 1
      @page = @article.pages.find_by( page_number: params[:page_number].to_i )
      @page.destroy
      @article.pages.each do |page|
        page.decrement!(:page_number) if page.page_number > params[:page_number].to_i
      end
      redirect_to show_page_user_article_path(current_user, @article, [params[:page_number].to_i, @article.pages.map(&:page_number).max].min)
    end
  end

  private

    def check_user
      @article = current_user.articles.find_by(id: params[:id])
      redirect_to Article.find(params[:id]) unless @article
    end

    def check_pages
      redirect_to @article unless @article.pages.count > 1
    end

    def sanitize_page_number(page)
      page_number = page || @article.next_page
      page_number = [[page_number.abs.round, @article.next_page].min, 1].max
    end

    def check_pages
      redirect_to @article unless @article.pages.count > 1
    end
end
