class ShrinePicture < ApplicationRecord
  include ShrineUploader::Attachment.new(:picture)
end
