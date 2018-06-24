class KudosController < ApplicationController
  before_action :find_work

  def create
    @kudo = @work.kudos.build

    if user_signed_in?
      if @work.kudos_giver_users.include?(current_user)
        already_gave_kudos
      else
        @kudo.user_id = current_user.id
      end
    else
      if @work.guest_gave_kudos?(request.remote_ip)
        already_gave_kudos
      else
        @kudo.ip_address = request.remote_ip
      end
    end

    unless @already_gave_kudos
      if @kudo.save
        flash[:success] = "Gave kudos!"
      else
        flash[:errors] = @kudo.errors.full_messages
      end
    end
    redirect_back fallback_location: @work
  end

  private
    def find_work
      @work = params[:parent].constantize.find(params["#{params[:parent].downcase}_id"])
    end

    def already_gave_kudos
      flash[:errors] = "You have already left kudos here. :)"
      @already_gave_kudos = true
    end
end
