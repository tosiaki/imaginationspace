require "rails_helper"

RSpec.feature "User adds a page", :type => :feature do
  let(:comic) { create(:comic) }
  let!(:user) { comic.user }

  scenario "to an existing comic" do
    sign_in user
    visit comic_path(comic)
    click_link "add-page-link"
    attach_file "comic_page_new_page", File.join(Rails.root, 'spec', 'files', 'samplefile.jpg')
    click_button "Post"
    expect(page).to have_content(comic.title)
  end
end