class AccountsController < ApplicationController
  before_action :prevent_account_response_caching
  before_action :require_authenticated_user!
  after_action :prevent_account_response_caching

  layout "authentication"

  def show
    @user = current_user
  end

  def update
    @user = current_user

    if @user.update(account_params)
      redirect_to account_path, notice: "Account updated."
    else
      render :show, status: :unprocessable_content
    end
  end

  private

  def account_params
    params.require(:user).permit(:name, :title, :bio, :website)
  end

  def prevent_account_response_caching
    response.headers["Cache-Control"] = "no-store"
  end
end
