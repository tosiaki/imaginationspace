module TagsFunctionality
  extend ActiveSupport::Concern

  def get_associated_tags
    @tag_list = params[:tags].split(",").map(&:strip).delete_if(&:empty?) if params[:tags]
    @tag_list ||= []

    filters = {
      tags: @tag_list.presence,
      exclusions: @tag_list,
      include_replies: params[:show_replies],
      filter_maps: !user_signed_in? || current_user.filter_content?
    }
    filters[action_name == 'show' ? :user : :bookmarked_by] = @user

    tags_by_context = ArticleTag.associate_tags(**filters).group_by(&:context)
    @tag_hash = ArticleTag.context_strings.index_with do |context|
      tags_by_context.fetch(context, [])
    end

    @tag_present = @tag_hash.map{ |context,tags| tags.count }.max > 0
  end
end
