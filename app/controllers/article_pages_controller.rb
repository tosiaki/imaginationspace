class ArticlePagesController < ApplicationController
  before_action :check_user
  before_action :check_pages, only: :destroy

  include Concerns::PictureFunctions

  def new
    session[:editing] = true
    @page = @article.pages.build
  end

  def create
    @article.editing_password = params[:article][:editing_password] unless @article.user
    @page = @article.pages.build(page_params)
    @page.normalize_page_number
    @page.content = process_inline_uploads(@page)

    @page = add_pictures_to_article(params[:page][:picture], @article, @page, params[:options][:new_pages] == '1')

    if @article.save
      session.delete(:editing)
      redirect_to show_page_article_path(@article, page_number: @page.page_number)
    else
      render 'new'
    end
  end

  def edit #This is unused
    @page = @article.pages.find_by( page_number: params[:page_number].to_i )
  end

  def update #This is unused
    page_number = sanitize_page_number(params[:page_number].to_i)
    if @article.update_page(content: params[:page][:content], title: params[:page][:title], page_number: page_number)
      flash[:success] = "Page has been updated"
    else
      flash[:warning] = "Update unsuccessful"
    end
    redirect_to show_page_article_path(@article, page_number)
  end

  def destroy
    @current_page = params[:page_number].to_i
    unless @article.user
      @article.editing_password = params[:article] ? params[:article][:editing_password] : cookies[:editing_password]
    end
    if @article.remove_page(@current_page)
      redirect_to show_page_article_path(@article, [@current_page, @article.current_max_page].min)
    end
  end

  private

    def page_params
      params.require(:page).permit(:title,:content,:page_number)
    end

    def check_user
      if user_signed_in?
        @article = current_user.articles.find(params[:id])
      else
        @article = Article.joins(:status).where(statuses: {user_id: nil}).find(params[:id])
      end
      redirect_to Article.find(params[:id]) unless @article
    end

    def check_pages
      redirect_to @article unless @article.pages.count > 1
    end

    def check_pages
      redirect_to @article unless @article.pages.count > 1
    end
end
