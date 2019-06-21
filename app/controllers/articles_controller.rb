class ArticlesController < ApplicationController
  before_action :check_user, only: [:edit, :update, :destroy]

  include Concerns::TagsFunctionality
  include Concerns::PictureFunctions
  include Concerns::GuestFunctions

  impressionist actions: [:show]

  def new
    article = Article.find(params[:reply_to_id])
    @new_article = Article.new
    render json: {
      result_template: render_to_body(partial: 'shared/posting_form', locals: { reply_to: article, placeholder: "Post reply here..." })
    }
    respond_to do |format|
      format.json
    end
  end

  def create
    @new_article = Article.new(article_params)
    @new_page = @new_article.pages.build(new_article_params)
    @new_page.content = process_inline_uploads(@new_page)

    @new_article.max_pages = 1
    @new_article.reply_to = Article.find(params[:id]) if params[:reply]

    if params[:new_page][:picture]
      page_number=1
      params[:new_page][:picture].each_with_index do |picture, index|
        if index > 0
          if params[:options][:new_pages] == '1'
            page_number += 1
            @new_page = @new_article.pages.build(page_number: page_number, content: '')
          end
        end
        add_picture_to_page(picture, @new_page)
      end
    end

    if user_signed_in?
      new_status = current_user.statuses.build(post: @new_article, timeline_time: Time.now)
    else
      new_status = Status.new(post: @new_article, timeline_time: Time.now)
      cookies.permanent[:display_name] = @new_article.display_name
    end

    if new_status.save
      ArticleTag.context_strings.each do |context|
        if params[:tags][context.to_sym]
          @new_article.set_tags(params[:tags][context.to_sym],context)
        end
      end

      @new_article.reply_to.add_reply if params[:reply]
    else
      flash[:danger] = 'New post requires content.'
    end
    if request.referer == root_url
      redirect_to @new_article
    else
      redirect_back fallback_location: @new_article
    end
  end


  def show(submitted_new_article=false)
    @article = Article.find(params[:id])
    @page = @article.pages.find_by(page_number: current_page)
    if params[:go_to_page]
      if request.format.json?
        render json: {
          destination_url: (show_page_article_path(@article, params[:go_to_page]) if params[:go_to_page])
        }.to_json
      else
        redirect_to show_page_article_path(@article, params[:go_to_page])
      end
    else
      @current_page = (params[:page_number] || 1).to_i

      @new_article = Article.new(guest_params) unless submitted_new_article
      if @article.pages.count > 1
        @page_options = @article.pages.map(&:display_title).zip 1..@article.pages.count
      end

      respond_to do |format|
        format.html
        format.json do
          render json: {
            article: @article.id,
            page_title: [@article.title,@page.title,@article.authored_by].reject{|e| e.blank?}.join(' - ') + " | Imagination Space",
            page_number: @page.page_number,
            title: @page.title,
            content: (render_to_string partial: 'articles/content', formats: :html, locals: {content: @page.content}),
            previous_page_content: (render_to_string partial: 'articles/content', formats: :html, locals: {content: @page.previous_page.content} if @page.page_number > 1),
            next_page_content: (render_to_string partial: 'articles/content', formats: :html, locals: {content: @page.next_page.content} if @page.page_number < @article.pages.count),
            previous_url: (show_page_article_path(@article, @page.page_number-1) if @page.page_number > 1 ),
            next_url: (show_page_article_path(@article, @page.page_number+1) if @page.page_number < @article.pages.count),
            article_pages: @article.pages.count,
            edit_url: edit_article_path(@article, page_number: params[:page_number]),
            add_page_before_url: add_page_at_article_path(@article,@page.page_number),
            add_page_after_url: add_page_at_article_path(@article,@page.page_number+1),
            remove_page_url: remove_page_article_path(@article,@page.page_number)
          }.reject{|key, value| value.nil?}.to_json
        end
      end
    end
  end

  def edit
    # session[:return_to] ||= request.referer unless session[:editing].present?
    # session[:editing] = true
    @page_number = params[:page_number] || 1
    @page = @article.pages.find_by(page_number: @page_number)
  end

  def update
    @page_number = params[:page][:page_number] || 1
    @page = @article.pages.find_by(page_number: @page_number)

    @article.assign_attributes(article_params)
    @page.assign_attributes(article_page_params)
    @page.content = process_inline_uploads(@page)

    ArticleTag.context_strings.each do |context|
      if params[:article][context.to_sym]
        @article.set_tags(params[:article][context.to_sym],context)
      end
    end

    if params[:page][:picture]
      params[:page][:picture].each do |picture|
        add_picture_to_page(picture, @page)
      end
    end

    if @article.save && @page.save
      # session.delete(:editing)
      #redirect_to session.delete(:return_to) || show_page_article_path(@article,page_number: @page_number)
      redirect_to show_page_article_path(@article,page_number: @page_number)
    else
      render 'edit'
    end
  end

  def destroy
    unless @article.user
      @article.editing_password = params[:article] ? params[:article][:editing_password] : cookies[:editing_password]
    end
    if @article.destroy
      redirect_back fallback_location: @article.user || @article.reply_to || Rails.root
    end
  end

  def index
    get_associated_tags
    @statuses = Status.select_by(tags: @tag_list, order: params[:order], include_replies: params[:show_replies], page_number: params[:page].present? ? params[:page].to_i : 1)
    @new_article = Article.new(guest_params)
  end

  private
    def check_user
      if user_signed_in?
        @article = current_user.articles.find(params[:id])
      else
        @article = Article.joins(:status).where(statuses: {user_id: nil}).find(params[:id])
      end
      redirect_to Article.find(params[:id]) unless @article
    end

    def current_page
      @page_number = params[:page_number]
      @page_number ||= 1
    end

    def article_params
      params.require(:article).permit(:title,:description,:planned_pages,:display_name,:editing_password)
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
