class ArticlesController < ApplicationController
  protect_from_forgery except: [:edit_tags]
  before_action :check_user, only: [:edit, :update, :destroy]
  before_action :check_tag_editor, only: [:edit_tags]
  before_action :authenticate_user!, only: [:new, :create, :edit_tags]

  include TagsFunctionality
  include PictureFunctions
  include GuestFunctions

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
    @new_article.thread = if @new_article.reply_to
      @new_article.reply_to.thread
    else
      @new_article
    end
    @new_article.reply_time = Time.now

    if params[:new_page][:picture]
      if false # params[:options][:new_pages] != '1'
        params[:new_page][:picture].reverse!
      end
      add_picture_to_page(params[:new_page][:picture][0], @new_page)
      @other_pictures = params[:new_page][:picture].drop(1)
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

      if params[:reply]
        @new_article.reply_to.add_reply
        @new_article.thread.update_attribute(:reply_time, Time.now)
      end

      if @other_pictures
        if true # params[:options][:new_pages] == '1'
          AddPicturesJob.perform_later(pictures: @other_pictures, article: @new_article, page_number: 1, editing_password: params[:article][:editing_password])
        else
          AddPicturesJob.perform_later(pictures: @other_pictures, page: @new_page, editing_password: params[:article][:editing_password])
        end
      end
    else
      flash[:danger] = 'New post requires content.'
    end

    redirect_to thread_path(@new_article.thread, anchor: @new_article.id)
  end


  def show(submitted_new_article=false)
    if request.content_type == 'application/json'
      return render json: Article.find(params[:id]).pages
    end
    @article = Article.find(params[:id])
    @page = @article.pages.find_by(page_number: current_page) || Page.fix_page(@article, current_page)

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
      add_picture_to_page(params[:page][:picture][0], @page)
      @other_pictures = params[:page][:picture].drop(1)
    end

    if @article.save && @page.save
      # session.delete(:editing)
      #redirect_to session.delete(:return_to) || show_page_article_path(@article,page_number: @page_number)

      if @other_pictures
        AddPicturesJob.perform_later(pictures: @other_pictures, page: @page, editing_password: params[:article][:editing_password])
      end

      redirect_to thread_path(@article.thread, anchor: @article.id)
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
    if params[:thread_id]
      @thread = Article.find(params[:thread_id])
      @boards = @thread.fandom_tags
      @statuses = Status.select_by(thread: params[:thread_id], order: params[:order], filter_languages_user: current_user, filter_maps: !user_signed_in? || current_user.filter_content?)
    elsif params[:board]
      @statuses = Status.select_by(board: params[:board], order: params[:order] || 'reply_time', page_number: params[:page].present? ? params[:page].to_i : 1, filter_languages_user: current_user, filter_maps: !user_signed_in? || current_user.filter_content?)
    else
      @statuses = Status.select_by(tags: @tag_list, order: params[:order], include_replies: params[:show_replies], page_number: params[:page].present? ? params[:page].to_i : 1, filter_languages_user: current_user, filter_maps: !user_signed_in? || current_user.filter_content?)
    end
    ActiveRecord::Associations::Preloader.new.preload(@statuses,
      [:post, :user,
        article: [:user, :media_tags, :fandom_tags, :character_tags, :relationship_tags, :other_tags, :attribution_tags, :pages,
          thread_posts: [:user, :media_tags, :fandom_tags, :character_tags, :relationship_tags, :other_tags, :attribution_tags, :pages]],
        signal_boost: [origin: [:user, :pages, :media_tags, :fandom_tags, :character_tags, :relationship_tags, :other_tags, :attribution_tags]],
      ])
    @new_article = Article.new(guest_params)
  end

  def edit_tags
    article = Article.find(params[:id])
    [
      { in: :derivative, context: 'fandom' },
      { in: :relationship, context: 'relationship' },
      { in: :character, context: 'character' },
      { in: :other, context: 'other' },
      { in: :language, context: 'language' },
      { in: :author, context: 'attribution' }
    ].each do |association|
      article.set_tags(params[association[:in]].join(','), association[:context])
    end

    render json: 'Done.'
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

    def check_tag_editor
      redirect_to Article.find(params[:id]) unless current_user.tag_editor?
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
