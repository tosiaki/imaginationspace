class SeriesArticle < ApplicationRecord
  belongs_to :series
  belongs_to :article
end
