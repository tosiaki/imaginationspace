class KudosController < ApplicationController
  before_action :find_work

  def create
    @kudo = @work.kudos.build

    result = if user_signed_in?
      @work.add_kudos(user: current_user) unless @work.user==current_user
    else
      @work.add_kudos(ip_address: request.remote_ip)
    end

    if result == :already_gave_kudos
      flash[:errors] = "You have already left kudos here. :)"
    elsif result
      flash[:success] = "Gave kudos!"
    else
      flash[:errors] = @kudo.errors.full_messages
    end

    redirect_back fallback_location: @work
  end

  private
    def find_work
      if params[:parent]
        @work = params[:parent].constantize.find(params["#{params[:parent].downcase}_id"])
      else
        @work = Article.find(params[:id])
      end
    end

    def already_gave_kudos
      flash[:errors] = "You have already left kudos here. :)"
      @already_gave_kudos = true
    end
end
