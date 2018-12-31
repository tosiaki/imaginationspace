class ArticleTagsController < ApplicationController
  def index
    render json: ArticleTag.find_tags(starting_with: params[:value], context: params[:context]).map(&:name).to_json

    respond_to do |format|
      format.json
    end
  end
end
