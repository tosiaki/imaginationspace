class ArticlePicture < ApplicationRecord
  mount_uploader :picture, ArticlePictureUploader
end
