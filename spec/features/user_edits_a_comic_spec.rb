require "rails_helper"

RSpec.feature "User edits a comic", :type => :feature do
  let(:comic) { create(:comic) }
  let!(:user) { comic.user }

  scenario "to change each field" do
    sign_in user
    visit comic_path(comic)
    click_link "Edit details"
    select "Mature", from: "comic_rating"
    select "Mature", from: "comic_front_page_rating"
    fill_in "comic_title", with: "New Title"
    fill_in "comic_pages", with: 0
    fill_in "comic_description", with: "This is a description"
    fill_in "comic_fandom_list", with: "Fandom1, Fandom2"
    click_button "Update"
    expect(page).to have_content('New Title')
    expect(page).to have_content('This is a description')
    expect(page).to have_content('Fandom2')
  end
end