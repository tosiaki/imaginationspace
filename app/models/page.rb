class Page < ApplicationRecord
  belongs_to :article, inverse_of: :pages
  default_scope -> { order(page_number: :asc) }

  has_many :shrine_pictures

  before_create :make_room
  after_create :update_article_planned_pages
  after_create :update_article_timeline_time
  before_save :check_editing_password
  before_save :update_display_image
  before_save :strip_end_whitespace

  before_destroy :check_editing_password
  before_destroy :check_number_of_pages

  validates :content, presence: true

  def display_title
    @title ||= title.present? ? title : "Page #{page_number}"
  end

  def previous_page
    article.pages.find_by(page_number: page_number-1)
  end

  def next_page
    article.pages.find_by(page_number: page_number+1)
  end

  def move_up
    article.make_room_at_page(page_number+1)
    increment!(:page_number)
  end

  def move_down
    if next_page
      next_page.move_down
    end
    decrement!(:page_number)
  end

  def make_room
    article.make_room_at_page(page_number)
  end

  def update_article_planned_pages
    article.update_planned_pages
  end

  def update_article_timeline_time
    article.touch
    article.update_timeline_time
  end

  def update_display_image
    image_tag = Nokogiri::HTML.fragment(content).css('img').first
    self.display_image = image_tag ? image_tag.attr('src') : nil
  end

  def strip_end_whitespace
    self.content = content.strip
  end

  def remove_page
    if next_page
      next_page.move_down
    end
    destroy
  end

  def normalize_page_number
    self.page_number ||= article.pages.count+1
    self.page_number = [[page_number.abs.round, article.pages.count+1].min, 1].max
  end

  def check_editing_password
    article.check_editing_password
  end

  def check_number_of_pages
    throw :abort unless article.pages.count > 1
  end
end
