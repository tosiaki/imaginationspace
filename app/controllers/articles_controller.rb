class ArticlesController < ApplicationController
  before_action :get_article, only: [:show, :edit, :update, :destroy]
  before_action :get_page, only: :show

  include Concerns::TagsFunctionality
  include Concerns::PictureFunctions

  def create
    article = Article.new(article_params)
    article.pages.build(new_article_params)
    article.max_pages = 1
    current_user.statuses.create(post: article, timeline_time: Time.now)

    ['fandom', 'character', 'relationship', 'other'].each do |context|
      if params[:tags][context.to_sym]
        article.set_tags(params[:tags][context.to_sym],context)
      end
    end

    if params[:new_page][:picture]
      page_number=1
      params[:new_page][:picture].each_with_index do |picture, index|
        if index > 0
          if params[:options][:new_pages] == '1'
            page_number += 1
            article.add_page(page_number: page_number)
          end
        end
        add_picture_to_page(picture, article, page_number)
      end
    end
    redirect_to current_user
  end

  def create_reply
    article = Article.new(article_params)
    article.pages.build(new_article_params)
    article.max_pages = 1
    article.reply_to = Article.find(params[:id])
    current_user.statuses.create(post: article, timeline_time: Time.now)

    ['fandom', 'character', 'relationship', 'other'].each do |context|
      if params[:tags][context.to_sym]
        article.set_tags(params[:tags][context.to_sym],context)
      end
    end

    if params[:new_page][:picture]
      page_number=1
      params[:new_page][:picture].each_with_index do |picture, index|
        if index > 0
          if params[:options][:new_pages] == '1'
            page_number += 1
            article.add_page(page_number: page_number)
          end
        end
        add_picture_to_page(picture, article, page_number)
      end
    end
    article.reply_to.add_reply
    redirect_to user_article_path(article.user,article)
  end


  def show
    if params[:go_to_page]
      redirect_to show_page_user_article_path(@user, @article, params[:go_to_page])
    end
    @current_page = (params[:page_number] || 1).to_i
    @new_article = Article.new
    if @article.pages.count > 1
      @page_options = @article.pages.map(&:display_title).zip 1..@article.pages.count
    end
  end

  def edit
    @page_number = params[:page_number] || 1
    @page = @article.pages.find_by(page_number: @page_number)
  end

  def update
    @article.update_attributes(article_params)
    @page_number = params[:page][:page_number] || 1
    @page = @article.pages.find_by(page_number: @page_number)
    @page.update_attributes(article_page_params)

    params[:page][:picture].each do |picture|
      add_picture_to_page(picture, @article, @page_number)
    end

    redirect_to show_page_user_article_path(@article.user,@article,page_number: @page_number)

    ['fandom', 'character', 'relationship', 'other'].each do |context|
      if params[:article][context.to_sym]
        @article.set_tags(params[:article][context.to_sym],context)
      end
    end
  end

  def destroy
    if @article.reply_to
      decrease_reply_number(@article.reply_to, 1+@article.reply_number)
    end
    @article.destroy
    redirect_to @user
  end

  def index
    get_associated_tags
    @statuses = Status.select_by(tags: @tag_list)
    if user_signed_in?
      @new_article = Article.new
    end
  end

  private
    def get_article
      @user = User.find(params[:user_id])
      @article = @user.articles.find(params[:id])
    end

    def get_page
      @page = @article.pages.find_by(page_number: current_page)
    end

    def current_page
      @page_number = params[:page_number]
      @page_number ||= 1
    end

    def article_params
      params.require(:article).permit(:title,:description)
    end

    def new_article_params
      params.require(:new_page).permit(:content)
    end

    def article_page_params
      params.require(:page).permit(:title,:content)
    end

    def decrease_reply_number(article, number)
      if article.reply_to
        decrease_reply_number(article.reply_to, number)
      end
      article.update_attribute(:reply_number, article.reply_number-number)
    end
end
