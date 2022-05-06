class TranslationPage < ApplicationRecord
  belongs_to :translation
  belongs_to :translation_chapter, optional: true

  has_many :translation_lines
end
