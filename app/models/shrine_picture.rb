class ShrinePicture < ApplicationRecord
  include ShrineUploader::Attachment.new(:picture)

  belongs_to :page, polymorphic: true, optional: true
end
