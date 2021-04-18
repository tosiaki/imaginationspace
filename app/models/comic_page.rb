class ComicPage < ApplicationRecord
  include DrawingImage
  belongs_to :comic, inverse_of: :comic_pages
  default_scope -> { order(page: :asc) }
  validates :comic, presence: true
  validates :page, presence: true
  before_create :make_room

  def move_up
    comic.make_room_at_page(page+1)
    increment!(:page)
  end

  def make_room
    comic.make_room_at_page(page)
  end
end
