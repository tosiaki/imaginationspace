class PagesController < ApplicationController
  def home
    @comics = Comic.all
    @drawings = Drawing.all
    @fandoms = @drawings.tag_counts_on(:fandoms, order: "count desc")
  end
end
