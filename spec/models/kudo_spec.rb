require 'rails_helper'

RSpec.describe Kudo, type: :model do
  context 'when the comic exists' do
    let!(:comic) { create(:comic) }

    it 'can be given' do
      pending 'This model redesign TBD'
      comic.add_kudos(user)
    end
  end
end
