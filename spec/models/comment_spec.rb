require 'rails_helper'

RSpec.describe Comment, type: :model do
  context 'when the comic exists' do
    let!(:comic) { create(:comic) }

    it 'can be created with content' do
      pending 'This model redesign TBD'
      comic.add_comment(attributes_for(:comment))
    end
  end
end
