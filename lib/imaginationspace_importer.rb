require 'open-uri'
require_relative 'imaginationspace_data'
require_relative 'import_association_map'

class ImaginationspaceImporter
  def unformatted_html 
    @unformatted_html ||= Nokogiri::XML::Node::SaveOptions.class_eval { |m| m::DEFAULT_HTML ^ m::FORMAT }
  end

  def extensions
    @extensions ||= {
      1 => 'jpg',
      2 => 'png',
      3 => 'gif'
    }
  end

  def tag_context(tag_type)
    case tag_type
    when 0
      'other'
    when 1
      'fandom'
    when 2
      'character'
    end
  end

  def initialize
    @report_additions = false
    @upload_images = true
    mysql_db = ActiveRecord::Base.establish_connection(
      adapter: "mysql2",
      host: "localhost",
      username: "root",
      password: ENV['MYSQL_PASSWORD'],
      database: "pralic_is"
      ).connection
    @imaginationspace_data = ImaginationspaceData.new(mysql_db)
    @import_association_map = ImportAssociationMap.new
  end

  def import
    @imaginationspace_data.get_data
    store_data
  end

  def store_data
    ActiveRecord::Base.establish_connection(:development)
    store_users
    store_illusts
    store_novels
    store_threads
    store_comments
    store_tags
    store_taggings
    store_follows
    store_bookmarks
  end

  def store_users
    @imaginationspace_data.users.each do |user|
      puts "Adding user " + user['display_name'] + '.' if @report_additions
      if (new_user = User.find_by(email: user['email'].downcase))
        puts "Notice: user " + user['display_name'] + " already exists."
      else
        random_password = SecureRandom.urlsafe_base64
        new_user = User.new(
          name: user['display_name'],
          password: random_password,
          password_confirmation: random_password,
          legacy_password: 1,
          email: user['email'],
          created_at: user['since'],
          updated_at: user['since'],
          title: user['title'],
          bio: user['profile_description'],
          website: user['website']
          )
        new_user.build_legacy_user(
          legacy_username: user['username'],
          legacy_password_digest: user['password']
          )
        new_user.skip_confirmation!
        unless new_user.save
          debugger
        end
      end
      @import_association_map.add_association(user, new_user, :user)
    end
  end

  def store_illusts
    @imaginationspace_data.illusts.each do |illust|
      puts "Adding illust with id #{illust['id']}." if @report_additions
      new_user = @import_association_map.get_by_old_id(illust['user_id'], :user)
      status = Status.new(
        user: new_user,
        created_at: illust['time'],
        updated_at: illust['time'],
        timeline_time: illust['time']
        )
      article = Article.new(
        title: illust['title'],
        description: illust['caption'],
        planned_pages: illust['pages'],
        max_pages: illust['pages'],
        created_at: illust['time'],
        updated_at: illust['time'],
        status: status
        )
      store_images(article, illust)
      if article.save
        article.add_tag("Drawing(s)", "media")
        @import_association_map.add_association(illust, article, :illust)
      else article.save
        debugger
      end
    end
  end

  def store_images(article, illust)
    user = @imaginationspace_data.get_user_by_id(illust['user_id'])
    @imaginationspace_data.get_images_by_illust_id(illust['id']).each do |image|
      puts "Adding image with id #{image['id']} to illust with id #{illust['id']}." if @report_additions
      doc, shrine_picture = convert_drawing_page(image, illust, user) if @upload_images

      page = article.pages.build(
        content: @upload_images ? doc.to_html(save_with: unformatted_html) : "content!",
        created_at: illust['time'],
        updated_at: illust['time'],
        page_number: image['page']
        )
      page.shrine_pictures << shrine_picture if @upload_images
    end
  end

  def store_novels
    @imaginationspace_data.novels.each do |novel|
      puts "Adding novel with id #{novel['id']}." if @report_additions
      new_user = @import_association_map.get_by_old_id(novel['user_id'], :user)
      chapters = @imaginationspace_data.get_chapters_by_novel_id(novel['id'])
      status = Status.new(
        user: new_user,
        created_at: novel['date'],
        updated_at: novel['date'],
        timeline_time: novel['date']
        )
      article = Article.new(
        title: novel['title'],
        description: novel['description'],
        planned_pages: chapters.count,
        max_pages: chapters.count,
        created_at: novel['date'],
        updated_at: novel['date'],
        status: status
        )
      store_chapters(article, novel, chapters)
      if article.save
        article.add_tag("Story", "media")
        @import_association_map.add_association(novel, article, :novel)
      else
        debugger
      end
    end
  end

  def store_chapters(article, novel, chapters)
    user = @imaginationspace_data.get_user_by_id(novel['user_id'])
    chapters.each do |chapter|
      puts "Adding chapter with id #{chapter['id']} to novel with id #{novel['id']}." if @report_additions
      page = article.pages.build(
        content: chapter['content'],
        created_at: chapter['date'],
        updated_at: chapter['last_updated'] || chapter['date'],
        page_number: chapter['chapter_number']
        )
    end
  end

  def store_threads
    @imaginationspace_data.threads.each do |thread|
      puts "Adding thread with id #{thread['id']}." if @report_additions
      comment = @imaginationspace_data.get_comments_by_thread_id(thread['id']).sort_by{ |c| c["date"] }.first
      new_user = @import_association_map.get_by_old_id(comment['user_id'], :user)
      status = Status.new(
        user: new_user,
        created_at: thread['created'],
        updated_at: thread['created'],
        timeline_time: thread['created']
        )
      article = Article.new(
        planned_pages: 1,
        max_pages: 1,
        created_at: thread['created'],
        updated_at: thread['created'],
        status: status
        )
      article.pages.build(
        content: comment['message'],
        created_at: thread['created'],
        updated_at: thread['created'],
        page_number: 1
        )
      if article.save
        article.add_tag("Status", "media")
        @import_association_map.add_association(thread, article, :thread)
      else
        debugger
      end
    end
  end

  def store_comments
    @imaginationspace_data.comments.each do |comment|
      puts "Adding comment with id #{comment['id']} with subject id #{comment['subject_id']} and subject type #{comment['subject_type']}." if @report_additions
      new_user = @import_association_map.get_by_old_id(comment['user_id'], :user)
      if comment['subject_type'] == 1
        reply_to = @import_association_map.get_by_old_id(comment['subject_id'], :illust)
      elsif comment['subject_type'] == 23
        reply_to = @import_association_map.get_by_old_id(comment['subject_id'], :thread)
        if reply_to.pages.first.content == comment['message']
          puts "The thread message itself has been skipped."
          next
        end
      else
        debugger
      end
      status = Status.new(
        user: new_user,
        created_at: comment['date'],
        updated_at: comment['date'],
        timeline_time: comment['date']
        )
      article = Article.new(
        planned_pages: 1,
        max_pages: 1,
        created_at: comment['date'],
        updated_at: comment['date'],
        status: status,
        anonymous: comment['anonymous'] == 1,
        reply_to: reply_to
        )
      article.pages.build(
        content: comment['message'],
        created_at: comment['date'],
        updated_at: comment['date'],
        page_number: 1
        )
      if article.save
        article.add_tag("Status", "media")
        reply_to.add_reply
      else
        debugger
      end
    end
  end

  def store_tags
    @imaginationspace_data.tags.each do |tag|
      puts "Adding tag " + tag['name'] + '.' if @report_additions
      if (new_tag = ArticleTag.find_by(name: tag['name'], context: tag_context(tag['type'])))
        puts "Notice: tag " + tag['name'] + " already exists"
      else
        new_tag = ArticleTag.create(
          name: tag['name'],
          context: tag_context(tag['type'])
          )
      end
      @import_association_map.add_association(tag, new_tag, :tag)
    end
  end

  def store_taggings
    @imaginationspace_data.taggings.each do |tagging|
      puts "Adding tagging of tag_id #{tagging['tag_id']} to subject_id #{tagging['subject_id']} and subject_type #{tagging['subject_type']}." if @report_additions
      new_tag = @import_association_map.get_by_old_id(tagging['tag_id'], :tag)
      if tagging['subject_type'] == 1
        new_object = @import_association_map.get_by_old_id(tagging['subject_id'], :illust)
      elsif tagging['subject_type'] == 3
        new_object = @import_association_map.get_by_old_id(tagging['subject_id'], :novel)
      elsif tagging['subject_type'] == 20
        #new_object = @import_association_map.get_by_old_id(tagging['subject_id'], :user)
      elsif tagging['subject_type'] == 23
        new_object = @import_association_map.get_by_old_id(tagging['subject_id'], :thread)
      else
        debugger
      end

      if !new_object
        # puts "The subject may be deleted or the tagged subject is a user."
        # puts "The subject_id is #{tagging['subject_id']} and the subject_type is #{tagging['subject_type']} (20 if user)."
        if tagging['subject_type'] == 1
          # puts "The number of deleted illusts with this id is #{@imaginationspace_data.check_deleted_illusts(tagging['subject_id'])}."
          debugger unless @imaginationspace_data.check_deleted_illusts(tagging['subject_id']) > 0
        elsif tagging['subject_type'] == 3
          # puts "The number of deleted novels with this id is #{@imaginationspace_data.check_deleted_novels(tagging['subject_id'])}."
          debugger unless @imaginationspace_data.check_deleted_novels(tagging['subject_id']) > 0
        elsif tagging['subject_type'] == 20
          # puts "This is indeed a user."
        else
          debugger
        end
      else
        new_tagging = ArticleTagging.create(
        article_tag: new_tag,
        article: new_object
        )
      end
    end
  end

  def store_follows
    @imaginationspace_data.follows.each do |follow|
      puts "Adding follow of user with user_id #{follow['user_id']} for id #{follow['subject_id']} of type #{follow['subject_type']}." if @report_additions
      new_user = @import_association_map.get_by_old_id(follow['user_id'], :user)
      if follow['subject_type'] == 20
        followed_subject = @import_association_map.get_by_old_id(follow['subject_id'], :user)
      elsif follow['subject_type'] == 10
        followed_subject = @import_association_map.get_by_old_id(follow['subject_id'], :tag)
      end
      result = new_user.bookmarks.find_by(bookmarkable: followed_subject)

      if result
        puts "#{new_user.name} is already following this."
      else
        new_user.bookmarks.create(bookmarkable: followed_subject)
      end
    end
  end

  def store_bookmarks
    @imaginationspace_data.bookmarks.each do |bookmark|
      puts "Adding bookmark of user with user_id #{bookmark['user_id']} for id #{bookmark['work_id']} of type #{bookmark['work_type']}." if @report_additions
      new_user = @import_association_map.get_by_old_id(bookmark['user_id'], :user)
      if bookmark['work_type'] == 1
        bookmarked = @import_association_map.get_by_old_id(bookmark['work_id'], :illust)
      elsif  bookmark['work_type'] == 3
        bookmarked = @import_association_map.get_by_old_id(bookmark['work_id'], :novel)
      elsif  bookmark['work_type'] == 23
        bookmarked = @import_association_map.get_by_old_id(bookmark['work_id'], :thread)
      else
        debugger
      end
      result = new_user.bookmarks.find_by(bookmarkable: bookmarked) if bookmarked

      if !bookmarked
        # puts "The bookmarked subject may be deleted."
        # puts "The bookmarked id is #{bookmark['work_id']} and the bookmarked type is #{bookmark['work_type']}."
        if bookmark['work_type'] == 1
          # puts "The number of deleted illusts with this id is #{@imaginationspace_data.check_deleted_illusts(bookmark['work_id'])}."
          debugger unless @imaginationspace_data.check_deleted_illusts(bookmark['work_id']) > 0
        elsif bookmark['work_type'] == 3
          # puts "The number of deleted novels with this id is #{@imaginationspace_data.check_deleted_novels(bookmark['work_id'])}."
          debugger unless @imaginationspace_data.check_deleted_novels(bookmark['work_id']) > 0
        else
          debugger
        end
      elsif result
        puts "#{new_user.name} has already bookmarked this."
      else
        new_user.bookmarks.create(bookmarkable: bookmarked)
      end
    end
  end

  def convert_drawing_page(image, illust, user)
    filename = illust['pages'] == 1 ? illust['id'].to_s : illust['id'].to_s + "_p" + image['page'].to_s
    new_file = File.open(Rails.root.join('lib','tasks','legacy_i',user['username'],filename + "." + extensions[image['filetype']]))
    new_shrine_picture = ShrinePicture.create(picture: new_file)
    new_doc = Nokogiri::HTML::DocumentFragment.parse ""
    Nokogiri::HTML::Builder.with(new_doc) do |doc|
      doc.div {
        doc.a(href: new_shrine_picture.picture[:original].url) {
          doc.img src: new_shrine_picture.picture[:original].url
        }
      }
    end
    return new_doc, new_shrine_picture
  end
end