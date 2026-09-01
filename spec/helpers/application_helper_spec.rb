require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  before do
    helper.define_singleton_method(:works_search_path) { "/works/search" }
  end

  it "renders transient searches as POST forms without crawlable links" do
    fragment = Capybara.string(helper.transient_work_search_button("Tutorial", tags: "Tutorial", class: "tag"))

    expect(fragment).to have_css('form[action="/works/search"][method="post"]')
    expect(fragment).to have_button("Tutorial")
    expect(fragment).not_to have_link("Tutorial")
  end

  it "renders transient pagination as POST controls" do
    collection = double(total_pages: 3, current_page: 2)
    helper.instance_variable_set(:@search_tags, ["Tutorial"])
    helper.instance_variable_set(:@comics_page, 2)
    helper.instance_variable_set(:@drawings_page, 1)

    fragment = Capybara.string(helper.transient_work_pagination(collection, param_name: :comics_page))

    expect(fragment).to have_button("Previous")
    expect(fragment).to have_button("Next")
    expect(fragment).to have_text("Page 2 of 3")
    expect(fragment).not_to have_css("a")
    expect(fragment).to have_css('form[action="/works/search"][method="post"]', count: 2)
  end
end
