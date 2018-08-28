include ActionDispatch::TestProcess

FactoryBot.define do
  factory :user do
    name { 'TestUser' }
    email { 'test@example.com' }
    password { 'f4k3p455w0rd' }
    confirmed_at { Time.now }
    title { 'UserTitle' }
    bio { 'UserBio' }
    show_adult { false }
  end

  factory :second_user, class: User do
  	name { 'SecondUser' }
  	email { 'second@example.com' }
  	password { 's3c0ndary' }
  	confirmed_at { Time.now }
  	title { 'SecondTitle' }
  	bio { 'SecondBio' }
  	show_adult { true }
  end

  factory :comic_page do
    orientation { 'column' }
    width { 1100 }
    height { 1100 }
    page { 1 }
    drawing { fixture_file_upload("spec/files/samplefile.jpg", "image/jpeg") }
  end

  factory :comic do
    user
    title { 'ComicTitle' }
    description { 'This is a description of a comic' }
    rating { "general_audiences" }
    front_page_rating { "front_general_audiences" }
    authorship { "own" }
    page_addition { Time.now }
    pages { 1 }
    before(:create) do |comic|
      comic.comic_pages << FactoryBot.build(:comic_page)
      comic.fandom_list.add('Tutorial')
      comic.character_list.add('A Different Character')
      comic.relationship_list.add('Nishikino Maki/Yazawa Nico')
      comic.tag_list.add('Rough sketch')
    end
  end

  factory :kudo do
  end

  factory :comment do
  	content { "This is a comment" }
  end

  factory :bookmark do
  end
end