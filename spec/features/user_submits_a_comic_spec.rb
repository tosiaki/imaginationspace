require "rails_helper"

RSpec.feature "User submits a comic", :type => :feature do
  let(:user) { create(:user) }

  scenario "with one page" do
    sign_in user
    visit new_comic_path
    select "General audiences", from: "comic_rating"
    select "General audiences", from: "comic_front_page_rating"
    fill_in "comic_title", with: "Test Title"
    attach_file "comic_comic_page_drawing", File.join(Rails.root, 'spec', 'files', 'samplefile.jpg')
    fill_in "comic_fandom_list", with: "Fandom"
    click_button "Post"
    expect(page).to have_content('Test Title')
  end
end