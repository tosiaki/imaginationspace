module Concerns::TagsFunctionality
  extend ActiveSupport::Concern

  def get_associated_tags
    @tag_list = params[:tags].split(",").map(&:strip).delete_if(&:empty?) if params[:tags]
    @tag_list ||= []

    @tag_hash = ArticleTag.context_strings.map do |context|
      if action_name == 'show'
        [context, ArticleTag.associate_tags(context: context, tags: @tag_list.present? ? @tag_list : nil, user: @user, exclusions: @tag_list)]
      else
        [context, ArticleTag.associate_tags(context: context, tags: @tag_list.present? ? @tag_list : nil, bookmarked_by: @user, exclusions: @tag_list)]
      end
    end.to_h

    @tag_present = @tag_hash.map{ |context,tags| tags.count }.max > 0
  end
end