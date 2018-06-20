module Concerns::Validatable
  extend ActiveSupport::Concern

  def has_fandoms
    number_of_tags = tag_list_cache_on("fandoms").uniq.length
    errors.add(:base, "Please add a fandom") if number_of_tags < 1
  end

end