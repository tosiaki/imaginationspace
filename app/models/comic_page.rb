class ComicPage < ApplicationRecord
  belongs_to :comic, inverse_of: :comic_pages
  default_scope -> { order(page: :asc) }
  mount_uploader :drawing, DrawingUploader
  validates :comic, presence: true
  validates :page, presence: true
  validates :drawing, presence: true
end
