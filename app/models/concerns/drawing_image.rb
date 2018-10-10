module Concerns::DrawingImage
  extend ActiveSupport::Concern

  included do
    mount_uploader :drawing, DrawingUploader
    validates :drawing, presence: true
    skip_callback :commit, :after, :remove_drawing!

    validates :width, presence: true, numericality: { only_integer: true }
    validates :height, presence: true, numericality: { only_integer: true }
  end

  def big_page?
    width > 1200 || height > 2000
  end
end