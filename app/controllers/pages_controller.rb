class PagesController < ApplicationController

  include GuestFunctions

  def home
    if false && user_signed_in?
      @feed_statuses = current_user.feed_statuses.includes(:post, :user,
        article: [:user, :pages, :media_tags, :fandom_tags, :character_tags, :relationship_tags, :other_tags, :attribution_tags],
        signal_boost: [origin: [:user, :pages, :media_tags, :fandom_tags, :character_tags, :relationship_tags, :other_tags, :attribution_tags]]).order(timeline_time: :desc).paginate(page: 1, per_page: 20)
    end
    @all_statuses = Status.includes(:post, :user,
        article: [:user, :pages, :media_tags, :fandom_tags, :character_tags, :relationship_tags, :other_tags, :attribution_tags],
        signal_boost: [origin: [:user, :pages, :media_tags, :fandom_tags, :character_tags, :relationship_tags, :other_tags, :attribution_tags]])
      .joins(:article).merge(Article.where(reply_to: nil)).order(timeline_time: :desc).paginate(page: params[:page] . present? ? params[:page].to_i : 1, per_page: 20)
    @new_article = Article.new(guest_params)
    @messages = DiscordMessage.select(
      'discord_messages.*, SUM(discord_reactions.count) as reaction_count'
    ).
    joins(:reactions).
    includes(:embeds).
    includes(:attachments).
    group('discord_messages.id').
    where('message_created_at > ?', 30.days.ago).
    order('reaction_count DESC').
    limit(15)
  end

  def old_home
    @comics = Comic.all.paginate(page: 1, per_page: 100)
    @drawings = Drawing.all.paginate(page: 1, per_page: 100)
    @fandoms_drawings = specific_count('Drawing')
    @fandoms_comics = specific_count('Comic')
    if user_signed_in?
      @feed_drawings = current_user.feed_drawings
      @feed_comics = current_user.feed_comics
    end
  end

  def support
  end

  def about
  end

  private
    def specific_count(model)
      ActsAsTaggableOn::Tag.select('tags.id, tags.name, COUNT(tags.id) as count').joins(:taggings).where( taggings: { context: 'fandoms', taggable_type: model } ).group('tags.id').order('count DESC')
    end
end
