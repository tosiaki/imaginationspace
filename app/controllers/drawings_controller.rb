class DrawingsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :edit, :destroy]

  def new
    @drawing = Drawing.new
  end

  def create
    @drawing = current_user.drawings.build(drawing_params);
    if @drawing.save
      flash[:success] = "Drawing posted!"
      redirect_to @drawing
    else
      render 'drawings/new'
    end
  end
  
  def show
    @drawing = Drawing.find(params[:id])
  end

  private

    def drawing_params
      params.require(:drawing).permit(:title, :drawing, :caption)
    end
end
