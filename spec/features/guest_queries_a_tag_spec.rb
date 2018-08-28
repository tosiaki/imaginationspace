require "rails_helper"

RSpec.feature "Guest queries a tag", :type => :feature do
  context 'when there are works found' do
    describe 'the comics display' do
      let!(:comic) { create(:comic) }

      context 'with no nonzero stats' do
        background do
          visit works_search_path(tags: 'Tutorial')
        end

        it 'displays the title' do
          expect(page.body).to have_link(comic.title)
        end

        it 'displays the tags' do
          expect(page.body).to have_link(comic.fandom_list.first)
          expect(page.body).to have_link(comic.character_list.first)
          expect(page.body).to have_link(comic.relationship_list.first)
          expect(page.body).to have_link(comic.tag_list.first)
        end

        it 'displays the summary information' do
          expect(page.body).to include(comic.description)
        end

        it 'does not display data' do
          expect(page.body).to_not include('Comments')
          expect(page.body).to_not include('Kudos')
          expect(page.body).to_not include('Bookmarks')
          expect(page.body).to_not include('Hits')
        end
      end

      context "with nonzero stats" do
        given(:user_id) { comic.user_id }

        background do
          kudo = comic.kudos.build(attributes_for(:kudo))
          kudo.user_id = user_id
          kudo.save
          visit works_search_path(tags: 'Tutorial')
        end

        it 'does display kudos' do
          expect(page.body).to include('Kudos')
        end
      end
    end
  end
end