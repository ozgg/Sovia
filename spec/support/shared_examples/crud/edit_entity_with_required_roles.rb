require 'rails_helper'

RSpec.shared_examples_for 'edit_entity_with_required_roles' do
  describe 'get edit' do
    before :each do
      get :edit, params: { id: entity.id }
    end

    it_behaves_like 'required_roles'
    it_behaves_like 'entity_finder'
    it_behaves_like 'http_success'
  end
end
