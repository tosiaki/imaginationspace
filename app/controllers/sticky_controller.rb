class StickyController < ApplicationController
  before_action :get_article, only: :create

  def create
    current_user.update_attribute(:sticky, @article)
    redirect_to current_user
  end

  def destroy
    current_user.update_attribute(:sticky, nil)
    redirect_to current_user
  end

  private
    def get_article
      @article = current_user.articles.find(params[:id])
    end
end
