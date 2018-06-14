class Drawing < ApplicationRecord
  belongs_to :user
  mount_uploader :drawing, DrawingUploader
end
