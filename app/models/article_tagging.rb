class ArticleTagging < ApplicationRecord
  belongs_to :article_tag
  belongs_to :article
end
