class Bookmark < ApplicationRecord
  belongs_to :bookmarkable, polymorphic: true, counter_cache: true
  belongs_to :user, inverse_of: :bookmarks
end
