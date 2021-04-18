module SeriesHelper
  def series_chapter_title(article, index)
    if article.title.present?
      article.title
    else
      "Chapter #{index + 1}"
    end
  end
end
