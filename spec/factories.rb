include ActionDispatch::TestProcess

FactoryBot.define do
  factory :finding do
    thing_name { "MyText" }
    required_experience { 1 }
  end
  factory :ingredient do
    preparation { nil }
    item { nil }
  end
  factory :preparation do
    name { "MyText" }
    product { nil }
    time_required { 1.5 }
  end
  factory :gathering do
    item { nil }
    delay { 1.5 }
  end
  factory :inventory_entry do
    user { nil }
    item { nil }
    amount { 1 }
  end
  factory :item do
    name { "MyString" }
  end
  factory :user_language do
    user { nil }
    article_tag { nil }
  end
  factory :legacy_user do
    user { nil }
    legacy_password { "MyText" }
    legacy_username { "MyText" }
  end
  factory :user do
    id { 1 }
    name { 'TestUser' }
    email { 'test@example.com' }
    password { 'f4k3p455w0rd' }
    confirmed_at { Time.now }
    title { 'UserTitle' }
    bio { 'UserBio' }
    show_adult { false }
  end

  factory :second_user, class: User do
    id { 2 }
  	name { 'SecondUser' }
  	email { 'second@example.com' }
  	password { 's3c0ndary' }
  	confirmed_at { Time.now }
  	title { 'SecondTitle' }
  	bio { 'SecondBio' }
  	show_adult { true }
  end

  factory :comic_page do
    width { 1100 }
    height { 1100 }
    page { 1 }
    drawing { fixture_file_upload("spec/files/samplefile.jpg", "image/jpeg") }
  end

  factory :comic_page2, class: ComicPage do
    width { 1100 }
    height { 1100 }
    page { 2 }
    drawing { fixture_file_upload("spec/files/samplefile2.jpg", "image/jpeg") }
  end

  factory :comic do
    user
    rating { "general_audiences" }
    front_page_rating { "front_general_audiences" }
    title { 'ComicTitle' }
    description { 'This is a description of a comic' }
    authorship { "own" }
    page_addition { Time.now }
    pages { 1 }
    before(:create) do |comic|
      comic.comic_pages << FactoryBot.build(:comic_page)
      comic.comic_pages << FactoryBot.build(:comic_page2)
      comic.fandom_list.add('Tutorial')
      comic.character_list.add('A Different Character')
      comic.relationship_list.add('Nishikino Maki/Yazawa Nico')
      comic.tag_list.add('Rough sketch')
    end
  end

  factory :drawing do
  	user
  	rating { "general_audiences" }
  	title { 'DrawingTitle' }
  	caption { 'This is a description of a drawing' }
  	drawing { fixture_file_upload("spec/files/45319054_p0.jpg", "image/jpeg") }
  	authorship { "own" }
  	before(:create) do |drawing|
  	  drawing.fandom_list.add('Drawing')
  	  drawing.character_list.add('Character1')
  	  comic.relationship_list.add('Character2/Character5')
  	  comic.tag_list.add('Another Tag')
  	end
  end

  factory :kudo do
  end

  factory :comment do
  	content { "This is a comment" }
  end

  factory :bookmark do
  end

  factory :status do |status|
    user
    status.post { |a| a.association(:article) }
    timeline_time { Time.now }
  end

  factory :article do
    title { "This is an artile" }
    description { "This article has a description" }
    max_pages { 1 }
    before(:create) do |article|
      article.pages << FactoryBot.build(:page)
    end
  end

  factory :page do
    content { "This is some page content." }
    page_number { 1 }
    title { "Article title" }
  end
end