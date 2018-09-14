class ComicsController < ApplicationController
  include Concerns::WorksFunctionality

  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]
  before_action :check_user, only: [:edit, :update,:destroy]

  impressionist actions: [:show]

  def new
    @comic = Comic.new
  end

  def create
    @comic = current_user.comics.build(comic_params);
    add_tags(@comic, :comic)
    current_page = 1
    params[:comic][:first_page].each do |page|
      comic_page = @comic.comic_pages.build(page: current_page, drawing: page, orientation: params[:orientation])
      if comic_page.valid?
        current_page += 1
      else
        flash[:warning] = "Not all pages were successfully added"
      end
    end
    @comic.pages = @comic.pages.abs.round
    @comic.max_pages = @comic.comic_pages.map(&:page).max
    if @comic.pages != 0 && @comic.pages < @comic.max_pages
      @comic.pages = @comic.max_pages
    end
    @comic.page_addition = Time.now
    if @comic.save
      flash[:success] = "Comic posted!"
      redirect_to @comic
    else
      render 'new'
    end
  end

  def show
    show_work(Comic)
    page_number = params[:page] || 1
    @page = @comic.comic_pages.find_by(page: page_number)

    respond_to do |format|
      format.html
      format.json do
        render json: {
          comic: @comic.id,
          page_number: @page.page,
          drawing_url: @page.drawing.show_page.url,
          full_url: @page.drawing.url,
          orientation: @page.orientation,
          big_page: @page.big_page?,
          dimensions: {
            width: @page.width,
            height: @page.height
          },
          previous_url: (show_page_comic_path(@comic, page: @page.page-1) if @page.page > 1 ),
          next_url: (show_page_comic_path(@comic, page: @page.page+1) if @page.page < @comic.comic_pages.count),
          comic_pages: @comic.comic_pages.count,
          add_page_url: new_comic_page_at_path(@comic,@page.page),
          replace_page_url: edit_page_comic_path(@comic,@page.page),
          delete_page_url: delete_comic_page_path(@comic,@page.page)
        }.reject{|key, value| value.nil?}.to_json
      end
    end
  end

  def show_all
    show_work(Comic)
  end

  def index
    index_works(Comic)
  end

  def edit
  end

  def update
    @comic.assign_attributes(comic_params)
    @comic.pages = @comic.pages.abs.round
    @comic.pages = 0 if @comic.pages < @comic.comic_pages.count
    update_tags
    if @comic.save
      flash[:success] = "Details updated!"
      redirect_to @comic
    else
      render 'edit'
    end
  end

  def destroy
    @comic.destroy
    flash[:success] = "Fancomic deleted."
    redirect_to current_user
  end

  private

    def comic_params
      params.require(:comic).permit(:rating, :front_page_rating, :title, :description, :pages, :authorship)
    end

    def add_tags(object, key)
      object.fandom_list.add(params[key][:fandom_list], parse: true ) unless params[key][:fandom_list].empty?
      object.character_list.add(params[key][:character_list], parse: true ) unless params[key][:character_list].empty?
      object.relationship_list.add(params[key][:relationship_list], parse: true ) unless params[key][:relationship_list].empty?
      object.tag_list.add(params[key][:tag_list], parse: true ) unless params[key][:tag_list].empty?
      object.author_list.add(params[key][:author_list], parse: true ) unless params[key][:author_list].empty?
    end

    def update_tags
      contexts = ['fandom', 'relationship', 'character', 'tag', 'author']
      contexts.each do |context|
        set_tags(context)
      end
    end

    def set_tags(context)
      list_name = "#{context}_list";
      new_tags = params['comic'][list_name].split(',').map(&:strip).reject { |c| c.empty? }
      old_tags = @comic.send(list_name)
      unless new_tags == old_tags
        (old_tags - new_tags).map {|e| @comic.send(list_name).remove(e)}
        (new_tags - old_tags ).map {|e| @comic.send(list_name).add e}
      end
    end

    def check_user
      @comic = current_user.comics.find_by(id: params[:id])
      @comic = current_user.scanlations.find(params[:id]) unless @comic
      redirect_to Comic.find(params[:id]) unless @comic
    end
end
