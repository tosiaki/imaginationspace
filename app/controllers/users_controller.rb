class UsersController < ApplicationController
  before_action :get_user, only: [:show, :old_show, :profile, :edit, :update, :preferences, :update_preferences, :change_icon, :update_icon, :change_password, :update_password, :drawings, :comics, :bookmarked_drawings, :bookmarked_comics, :bookmarks, :subscribe, :unsubscribe, :subscriptions, :subscribers]
  before_action :is_current_user, only: [:edit, :update, :preferences, :update_preferences, :change_icon, :update_icon, :change_password, :update_password]

  include Concerns::TagsFunctionality
  include Concerns::GuestFunctions

  def show
    @new_article = Article.new(guest_params)
    
    get_associated_tags
    @statuses = Status.select_by(tags: @tag_list, user: @user, order: params[:order], include_replies: params[:show_replies], page_number: params[:page].present? ? params[:page].to_i : 1, filter_maps: !user_signed_in? || current_user.filter_content?)

    ActiveRecord::Associations::Preloader.new.preload(@statuses,
      [:post, :user,
        article: [:user, :pages, :media_tags, :fandom_tags, :character_tags, :relationship_tags, :other_tags, :attribution_tags],
        signal_boost: [origin: [:user, :pages, :media_tags, :fandom_tags, :character_tags, :relationship_tags, :other_tags, :attribution_tags]],
      ])
  end

  def old_show
    @user_comics = @user.comics.paginate(page: 1, per_page: 20)
    @user_drawings = @user.drawings.paginate(page: 1, per_page: 20)
    @user_scanlations = @user.scanlations.paginate(page: 1, per_page: 20)
    if @user_comics.any?
      @comic_fandoms = @user_comics.tag_counts_on(:fandoms, limit: 15, order: "count desc")
    end
    if @user_drawings.any?
      @drawing_fandoms = @user_drawings.tag_counts_on(:fandoms, limit: 15, order: "count desc")
    end
    if @user_scanlations.any?
      @scanlation_fandoms = @user_scanlations.tag_counts_on(:fandoms, limit: 15, order: "count desc")
    end
  end

  def profile
  end

  def edit
  end

  def update
    if @user.update_attributes(edit_user_params)
      flash[:success] = "Profile updated!"
      redirect_to @user
    else
      render 'edit'
    end
  end

  def preferences
  end

  def update_preferences
    if params[:user][:languages]
      @user.set_languages(params[:user][:languages])
    end

    if @user.update_attributes(preferences_params)
      flash[:success] = "Preferences updated!"
      redirect_to preferences_user_path(@user)
    else
      render 'preferences'
    end
  end

  def change_icon
  end

  def update_icon
    if @user.update change_icon_params
      flash[:success] = "Icon updated!"
      redirect_to @user
    else
      render 'change_icon'
    end
  end

  def change_password
  end

  def update_password
    if @user.update_with_password(change_password_params)
      bypass_sign_in(@user)
      flash[:success] = "Password updated!"
      redirect_to @user
    else
      render 'change_password'
    end
  end

  def drawings
    list_works 'drawings'
  end

  def comics
    list_works 'comics'
  end

  def scanlations
    list_works 'scanlations'
  end

  def bookmarked_drawings
    list_works 'drawings', bookmarks: true
  end

  def bookmarked_comics
    list_works 'comics', bookmarks: true
  end

  def bookmarks
    @new_article = Article.new(guest_params)
    get_associated_tags
    @statuses = Status.select_by(tags: @tag_list, bookmarked_by: @user, order: params[:order])
  end

  def subscribe
    @subscription = current_user.bookmarks.build(bookmarkable: @user)
    if @subscription.save
      flash[:success] = render_to_string(partial: 'now_subscribed') unless request.format.json?
    else
      flash[:danger] = "Following unsuccessful"
    end
    respond_to do |format|
      format.html do
        redirect_back fallback_location: @user
      end
      format.json do
        render json: {
          current_followers: @user.subscribers_count,
          new_link: unsubscribe_from_user_path(@user)
        }.to_json
      end
    end
  end

  def unsubscribe
    unless @user == current_user
      @subscription = current_user.bookmarks.find_by(bookmarkable: @user)
      if @subscription.destroy
        flash[:success] = "Unfollowed" unless request.format.json?
      else
        flash[:danger] = "Unfollowing unsuccessful"
      end
    end
    respond_to do |format|
      format.html do
        redirect_back fallback_location: @user
      end
      format.json do
        render json: {
          current_followers: @user.subscribers_count,
          new_link: subscribe_to_user_path(@user)
        }.to_json
      end
    end
  end

  def subscriptions
    @subscriptions = @user.proper_subscriptions.paginate(page: params[:page], per_page: 100)
  end

  def subscribers
    @subscribers = @user.proper_subscribers.paginate(page: params[:page], per_page: 100)
  end

  private
    def get_user
      @user = User.find(params[:id])
    end

    def is_current_user
      redirect_to @user unless @user == current_user
    end

    def get_works(work, bookmarks: false)
      list_method = work;
      list_method = "bookmarked_" + list_method if bookmarks
      if params[:tags]
        tag_list = params[:tags].split(",").map(&:strip)
        @works = @user.send(list_method).tagged_with(tag_list)
      else
        @works = @user.send(list_method)
      end
    end

    def list_works(work, bookmarks: false)
      get_works work, bookmarks: bookmarks
      instance_variable_set "@#{work}", @works.paginate(page: params[:page], per_page: 100)
      @bookmarks = true if bookmarks
      render work
    end

    def edit_user_params
      params.require(:user).permit(:name, :title, :bio, :website)
    end

    def preferences_params
      params.require(:user).permit(:show_adult, :notify_follow, :notify_kudos, :notify_bookmark, :notify_reply, :notify_signal_boost, :site_updates)
    end

    def change_icon_params
      params.require(:user).permit(:icon, :icon_alt, :icon_comment)
    end

    def change_password_params
      params.require(:user).permit(:password, :password_confirmation, :current_password)
    end
end
