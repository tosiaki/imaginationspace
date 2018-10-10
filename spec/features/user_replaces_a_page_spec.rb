require "rails_helper"

RSpec.feature "User replaces a page", :type => :feature do
  let(:comic) { create(:comic) }
  let!(:user) { comic.user }

  scenario "on an already existing comic" do
    sign_in user
    visit comic_path(comic)
    click_link "replace-page-link"
    attach_file "comic_page_new_page", File.join(Rails.root, 'spec', 'files', '063.jpg')
    click_button "Update"
    expect(page).to have_content(comic.title)
  end
end