include ActionDispatch::TestProcess

FactoryBot.define do
  factory :kudo do
    
  end
  factory :comment do
    
  end
  factory :bookmark do
    
  end
  factory :user do
    name { 'TestUser' }
    email { 'test@example.com' }
    password { 'f4k3p455w0rd' }
    confirmed_at { Time.now }
    title { 'UserTitle' }
    bio { 'UserBio' }
    show_adult { false }
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
      # comic_pages << FactoryBot.build(:page)
      comic.fandom_list.add('Tutorial')
    end
  end
end