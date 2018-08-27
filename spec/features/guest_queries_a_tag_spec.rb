require "rails_helper"

RSpec.feature "Guest queries a tag", :type => :feature do
  context 'when there are works found' do
    describe 'the comics display' do
      let!(:comic) { create(:comic) }

      background do
        visit works_search_path(tags: 'Tutorial')
      end

      it 'displays the comic title' do
        expect(page.body).to include(comic.title)
      end

      it 'displays the summary information' do
        expect(page.body).to include(comic.description)
      end
    end
  end
end