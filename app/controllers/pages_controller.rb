class PagesController < ApplicationController
  def home
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
