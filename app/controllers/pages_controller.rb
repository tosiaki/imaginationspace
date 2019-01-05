class PagesController < ApplicationController

  include Concerns::GuestFunctions

  def home
    if user_signed_in?
      @feed_statuses = current_user.feed_statuses.order(timeline_time: :desc).paginate(page: 1, per_page: 20)
      leftover_amount = 20 - @feed_statuses.total_entries
      if leftover_amount > 0
        @all_statuses = Status.all.order(timeline_time: :desc).paginate(page: 1, per_page: leftover_amount)
      end
    else
      @all_statuses = Status.all.order(timeline_time: :desc).paginate(page: 1, per_page: 20)
    end
    @new_article = Article.new(guest_params)
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

  def about
  end

  private
    def specific_count(model)
      ActsAsTaggableOn::Tag.select('tags.id, tags.name, COUNT(tags.id) as count').joins(:taggings).where( taggings: { context: 'fandoms', taggable_type: model } ).group('tags.id').order('count DESC')
    end
end
