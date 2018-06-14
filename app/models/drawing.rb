class Drawing < ApplicationRecord
  belongs_to :user
  mount_uploader :drawing, DrawingUploader
  default_scope -> { order(created_at: :desc) }
end
