class UsersController < ApplicationController
  before_action :get_user, only: [:show, :profile, :edit, :update, :change_icon, :update_icon, :change_password, :update_password, :drawings, :comics, :bookmarked_drawings, :bookmarked_comics, :subscribe, :unsubscribe, :subscriptions]
  before_action :is_current_user, only: [:edit, :update, :change_icon, :update_icon, :change_password, :update_password]

  def show
    @user_comics = @user.comics
    @user_drawings = @user.drawings
    if @user_comics.any?
      @comic_fandoms = @user_comics.tag_counts_on(:fandoms, limit: 15, order: "count desc")
    end
    if @user_drawings.any?
      @drawing_fandoms = @user_drawings.tag_counts_on(:fandoms, limit: 15, order: "count desc")
    end
  end

  def profile
  end

  def edit
  end

  def update
    if @user.update_attributes(edit_user_params)
      flash[:success] = "Profile updated!"
      redirect_to profile_user_path(@user)
    else
      render 'edit'
    end
  end

  def change_icon
  end

  def update_icon
    if @user.update change_icon_params
      flash[:success] = "Icon updated!"
      redirect_to profile_user_path(@user)
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
      redirect_to profile_user_path(@user)
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

  def bookmarked_drawings
    list_works 'drawings', bookmarks: true
  end

  def bookmarked_comics
    list_works 'comics', bookmarks: true
  end

  def subscribe
    @subscription = current_user.bookmarks.build(bookmarkable: @user)
    if @subscription.save
      flash[:success] = render_to_string(partial: 'now_subscribed')
    else
      flash[:danger] = "Subscription unsuccessful"
    end
    redirect_back fallback_location: @user
  end

  def unsubscribe
    @subscription = current_user.bookmarks.find_by(bookmarkable: @user)
    if @subscription.destroy
      flash[:success] = "Unsubscribed"
    else
      flash[:danger] = "Unsubscription unsuccessful"
    end
    redirect_back fallback_location: @user
  end

  def subscriptions
    @subscriptions = @user.subscriptions
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
      instance_variable_set "@#{work}", @works
      render work
    end

    def edit_user_params
      params.require(:user).permit(:name, :title, :bio)
    end

    def change_icon_params
      params.require(:user).permit(:icon, :icon_alt, :icon_comment)
    end

    def change_password_params
      params.require(:user).permit(:password, :password_confirmation, :current_password)
    end
end
