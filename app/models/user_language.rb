class UserLanguage < ApplicationRecord
  belongs_to :user
  belongs_to :article_tag
end
