class DrawingsController < ApplicationController
  def create
  end
  
  def show
    @drawing = Drawing.find(params[:id])
  end
end
