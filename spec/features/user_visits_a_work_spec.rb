require "rails_helper"

RSpec.feature "User visits a work", :type => :feature do
  scenario "with no comments" do
    # The comments counter should not display
    # it will be displayed if using the @work.comments.any? method due to the unsaved comment
  end
end