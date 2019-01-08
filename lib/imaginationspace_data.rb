class ImaginationspaceData
  attr_reader :users
  attr_reader :illusts
  attr_reader :novels
  attr_reader :comments
  attr_reader :threads
  attr_reader :tags
  attr_reader :taggings
  attr_reader :follows
  attr_reader :bookmarks

  def initialize(mysql_db)
    @mysql_db = mysql_db
  end

  def select_query(query, *args)
    @mysql_db.select_all(ActiveRecord::Base.send(:sanitize_sql_array, [query] + args))
  end

  def get_data
    @users = select_query("SELECT * FROM user")

    @illusts = select_query("SELECT * FROM illust WHERE deleted=0")
    @images = select_query("SELECT * FROM image")
    @novels = select_query("SELECT * FROM novel WHERE deleted=0")
    @chapters = select_query("SELECT * FROM chapter")
    @threads = select_query("SELECT * FROM thread")
    @comments = select_query("SELECT * FROM comment")
    @tags = select_query("SELECT * FROM tag")
    @taggings = select_query("SELECT * FROM tagging")
    @follows = select_query("SELECT * FROM follow WHERE unfollow=0")
    @bookmarks = select_query("SELECT * FROM bookmark WHERE deleted=0")

    @deleted_illusts = select_query("SELECT * FROM illust WHERE deleted=1")
    @deleted_novels = select_query("SELECT * FROM novel WHERE deleted=1")

    # @users.each do |user|
    #   @illusts[user] = 3
    #   @illusts[user] = select_query("SELECT * FROM illust WHERE user_id = ? AND deleted=0", user['id'])
    #   @illusts[user].each do |illust|
    #     @images[illust] = select_query("SELECT * FROM image WHERE illust_id = ?", illust['id'])
    #     @comments[illust] = select_query("SELECT * FROM comment WHERE subject_id = ? AND subject_type=1", illust['id'])
    #   end
    #   @novels[user] = select_query("SELECT * FROM novel WHERE user_id = ? AND deleted=0", user['id'])
    #   @novels[user].each do |novel|
    #     @chapters[novel] = select_query("SELECT * FROM chapter WHERE novel_id = ?", novel['id'])
    #   end
    #   @follows[user] = select_query("SELECT * FROM follow WHERE user_id = ?", user['id'])
    # end

    # @tags = @mysql_db.select_all("SELECT * FROM tag")
    # @taggings = @mysql_db.select_all("SELECT * FROM tagging")
    # @follows = @mysql_db.select_all("SELECT * FROM follow")
  end

  def get_user_by_id(id)
    result = @users.to_hash.select { |entry| entry["id"] == id }
    result[0]
  end

  def get_images_by_illust_id(id)
    @images.to_hash.select { |entry| entry["illust_id"] == id }
  end

  def get_chapters_by_novel_id(id)
    @chapters.to_hash.select{ |entry| entry["novel_id"] == id }
  end

  def get_comments_by_thread_id(id)
    @comments.to_hash.select{ |entry| entry["subject_id"] == id && entry["subject_type"] == 23 }
  end

  def check_deleted_illusts(id)
    @deleted_illusts.to_hash.select{ |entry| entry["id"] == id }.count
  end

  def check_deleted_novels(id)
    @deleted_novels.to_hash.select{ |entry| entry["id"] == id }.count
  end
end