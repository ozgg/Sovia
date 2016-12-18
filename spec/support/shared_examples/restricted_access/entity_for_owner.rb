require 'rails_helper'

RSpec.shared_examples_for 'entity_for_owner' do
  describe 'get show' do
    before :each do
      expect(entity.class).to receive(:owned_by).and_call_original
      allow(entity.class).to receive(:find_by).and_return(entity)
      get :show, params: { id: entity.id }
    end

    it_behaves_like 'entity_finder'
    it_behaves_like 'http_success'
  end
end
