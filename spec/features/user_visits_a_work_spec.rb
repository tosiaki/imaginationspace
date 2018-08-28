require "rails_helper"

RSpec.feature "User visits a work", :type => :feature do
  scenario "with no comments" do
    # The comments counter should not display
    # it will be displayed if using the @work.comments.any? method due to the unsaved comment
  end

  describe "the actions links" do
    let!(:comic) { create(:comic) }

    context "when it is not the user's own work" do
      background do
        visit comic_path(comic)
      end

      it 'does not contain a link to add a page' do
        expect(page.body).to_not have_link("Add page(s)", href: new_comic_page_path(comic))
      end
    end

    context "when it is the user's own work" do
      background do
        user = comic.user
        sign_in user
        visit comic_path(comic)
      end

      it 'contains a link to add a page' do
        expect(page.body).to have_link("Add page(s)", href: new_comic_page_path(comic))
      end
    end
  end
end