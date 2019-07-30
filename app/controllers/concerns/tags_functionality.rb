module Concerns::TagsFunctionality
  extend ActiveSupport::Concern

  def get_associated_tags
    @tag_list = params[:tags].split(",").map(&:strip).delete_if(&:empty?) if params[:tags]
    @tag_list ||= []

    @tag_hash = ArticleTag.context_strings.map do |context|
      if action_name == 'show'
        [context, ArticleTag.associate_tags(context: context, tags: @tag_list.present? ? @tag_list : nil, user: @user, exclusions: @tag_list, include_replies: params[:show_replies], filter_maps: !user_signed_in? || current_user.filter_content?)]
      else
        [context, ArticleTag.associate_tags(context: context, tags: @tag_list.present? ? @tag_list : nil, bookmarked_by: @user, exclusions: @tag_list, include_replies: params[:show_replies], filter_maps: !user_signed_in? || current_user.filter_content?)]
      end
    end.to_h

    @tag_present = @tag_hash.map{ |context,tags| tags.count }.max > 0
  end
end