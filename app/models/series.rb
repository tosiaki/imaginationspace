class Series < ApplicationRecord
  belongs_to :user
  has_many :series_articles, -> { order(:position) }
  has_many :articles, through: :series_articles
end
