class Kudo < ApplicationRecord
  belongs_to :work, polymorphic: true
  belongs_to :user, optional: true
  validates :ip_address, presence: true, unless: :user_id?
  validates_presence_of :user, if: :user_id?

  default_scope -> { order(created_at: :asc) }
end
