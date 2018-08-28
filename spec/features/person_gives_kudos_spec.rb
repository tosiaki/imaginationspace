require "rails_helper"

RSpec.feature "Person gives kudos", :type => :feature do
  let!(:comic) { create(:comic) }

  context "when not logged in" do
    background do
      visit comic_path(comic)
    end

    it "increases kudos only the first time" do
      expect(page.body).to have_link("Kudos", href: comic_kudos_path(comic))
      click_on("Kudos")
      expect(page).to have_current_path(comic_path(comic))
      expect(page.body).to include("Kudos: 1")
      click_on("Kudos")
      expect(page.body).to include("Kudos: 1")
    end
  end

  context "when logged in as other" do
    background do
      other_user = create(:second_user)
      sign_in other_user
      visit comic_path(comic)
    end

    it "increases kudos only the first time" do
      expect(page.body).to have_link("Kudos", href: comic_kudos_path(comic))
      click_on("Kudos")
      expect(page).to have_current_path(comic_path(comic))
      expect(page.body).to include("Kudos: 1")
      click_on("Kudos")
      expect(page.body).to include("Kudos: 1")
    end
  end

  context "when logged in as owner" do
    background do
      user = comic.user
      sign_in user
      visit comic_path(comic)
    end

  	it "does not show or increase kudos" do
      expect(page.body).to_not have_link("Kudos", href: comic_kudos_path(comic))
    end
  end

end