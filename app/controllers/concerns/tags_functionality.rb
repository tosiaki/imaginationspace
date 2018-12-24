module Concerns::TagsFunctionality
  extend ActiveSupport::Concern

  def get_associated_tags
    @tag_list = params[:tags].split(",").map(&:strip).delete_if(&:empty?) if params[:tags]
    @tag_list ||= []

    @fandom_tags = ArticleTag.associate_tags(context: 'fandom', tags: @tag_list.present? ? @tag_list : nil, user: @user, exclusions: @tag_list)
    @character_tags = ArticleTag.associate_tags(context: 'character', tags: @tag_list.present? ? @tag_list : nil, user: @user, exclusions: @tag_list)
    @relationship_tags = ArticleTag.associate_tags(context: 'relationship', tags: @tag_list.present? ? @tag_list : nil, user: @user, exclusions: @tag_list)
    @other_tags = ArticleTag.associate_tags(context: 'other', tags: @tag_list.present? ? @tag_list : nil, user: @user, exclusions: @tag_list)
  end
end