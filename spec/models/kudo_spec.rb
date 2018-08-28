require 'rails_helper'

RSpec.describe Kudo, type: :model do
  context 'when the comic exists' do
    given!(:user) { create(:user) }
    given!(:comic) { create(:comic) }

    it 'can be given' do
      pending 'This model redesign TBD'
      comic.add_kudos(user)
    end
end
