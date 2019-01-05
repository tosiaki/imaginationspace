class WorksConverter
  def self.tag_contexts
    @contexts = [
      { old_name: "fandom", new_name: "fandom" },
      { old_name: "character", new_name: "character" },
      { old_name: "relationship", new_name: "relationship" },
      { old_name: "tag", new_name: "other" },
      { old_name: "author", new_name: "attribution" }
    ]
  end

  def unformatted_html 
    @unformatted_html ||= Nokogiri::XML::Node::SaveOptions.class_eval { |m| m::DEFAULT_HTML ^ m::FORMAT }
  end

  def initialize(old_work, resume = false)
    @work = old_work
    if resume
      @article = Article.find(98)
      @article.add_tag("Drawings(s)", "media")
    else
      create_article
      convert_comments(@article, @work)
      convert_tags
    end
    convert_kudos
    convert_impressions
    return @status
  end

  def convert_comments(add_reply_to, get_replies_from)
    get_replies_from.comments.each do |comment|
      new_comment_status = Status.new(
        user: comment.user,
        created_at: comment.created_at,
        updated_at: comment.updated_at,
        timeline_time: comment.created_at
      )
      new_comment_article = Article.new(
        planned_pages: 1,
        max_pages: 1,
        reply_to: add_reply_to,
        display_name: comment.name,
        created_at: comment.created_at,
        updated_at: comment.updated_at,
        editing_password: comment.user ? nil : SecureRandom.urlsafe_base64,
        status: new_comment_status
        )
      new_comment_article.pages.build(
        content: comment.content,
        created_at: comment.created_at,
        updated_at: comment.updated_at,
        page_number: 1
        )
      new_comment_article.save

      convert_comments(new_comment_article, comment)
    end
  end

  def convert_tags
    WorksConverter.tag_contexts.each do |context|
      @article.add_tags(@work.send("#{context[:old_name]}_list"), context[:new_name])
    end
    if @work.class == Comic
      @article.add_tag("Comic", "media")
    elsif @work.class == Drawing
      @article.add_tag("Drawing(s)", "media")
    end
  end

  def convert_kudos
    @work.kudos.each do |kudo|
      @article.kudos.create(
        user_id: kudo.user_id,
        ip_address: kudo.ip_address,
        created_at: kudo.created_at,
        updated_at: kudo.updated_at
        )
    end
  end

  def convert_impressions
    @work.impressions.each do |impression|
      new_impression = impression.dup
      new_impression.impressionable = @article
      new_impression.save
    end
  end

  def convert_drawing_page(drawing)
    new_doc = Nokogiri::HTML::DocumentFragment.parse ""
    Nokogiri::HTML::Builder.with(new_doc) do |doc|
      doc.div {
        doc.a(href: drawing.drawing.url) {
          doc.img src: drawing.drawing.show_page.url
        }
      }
      if drawing.width > 1200 || drawing.height > 2000
        doc.div(class: "note page-note") {
          doc.text "This image has been resized from the original size of " + drawing.width.to_s + " by " + drawing.height.to_s + " To see the full image, click "
          doc.a(href: drawing.drawing.url) { doc.text "here" }
          doc.text "or on the image itself."
        }
      end
    end
    new_doc
  end
end