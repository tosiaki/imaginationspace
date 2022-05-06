class Translation < ApplicationRecord
  has_many :translation_chapters
  has_many :translation_pages
  has_many :translation_lines, through: :translation_pages
end
