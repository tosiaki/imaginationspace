class ComicPage < ApplicationRecord
  enum orientation: { screen: 0, column: 1 }
  belongs_to :comic, inverse_of: :comic_pages
  default_scope -> { order(page: :asc) }
  mount_uploader :drawing, DrawingUploader
  skip_callback :commit, :after, :remove_drawing!
  validates :comic, presence: true
  validates :page, presence: true
  validates :drawing, presence: true
  before_create :make_room

  def move_up
    comic.make_room_at_page(page+1)
    increment!(:page)
  end

  def make_room
    comic.make_room_at_page(page)
  end
end
