require "rails_helper"

RSpec.feature "Guest visits a page", :type => :feature do
  describe "the home page" do
    before do
      visit '/'
    end

    it 'includes the site name' do
      expect(page.body).to include("Fancomics")
    end

    it 'includes Home in the title' do
      expect(page.title).to include("Home")
    end
  end

  describe "the about page" do
    before do
      visit '/about'
    end

    it 'includes the phrase `about fancomics`' do
      expect(page.body).to include("About fancomics")
    end
  end

  describe "the signup page" do
    it 'includes the email and password fields' do
      visit '/signup'
      expect(page.body).to include("email")
      expect(page.body).to include("password")
    end
  end

  describe "the signout page" do
    before do
      visit '/logout'
    end

    it 'redirects the user to the home page' do
      expect(current_path).to eq(root_path)
    end
  end

  pending 'greets the user when logged in'
end