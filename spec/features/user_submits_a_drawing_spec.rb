require "rails_helper"

RSpec.feature "User submits a drawing", :type => :feature do
  let(:user) { create(:user) }

  scenario "with one page" do
    sign_in user
    visit new_drawing_path
    select "General audiences", from: "drawing_rating"
    fill_in "drawing_title", with: "Drawing Title"
    fill_in "drawing_caption", with: "This is a caption."
    attach_file "drawing_drawing", File.join(Rails.root, 'spec', 'files', '45319054_p0.jpg')
    fill_in "drawing_fandom_list", with: "Fandom3"
    click_button "Post"
    expect(page).to have_content('Drawing Title')
    expect(page).to have_content('This is a caption.')
  end
end