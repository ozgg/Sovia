require 'rails_helper'

RSpec.describe Admin::CommentsController, type: :controller do
  let!(:entity) { create :comment }
  let(:required_roles) { :administrator }

  it_behaves_like 'index_entities_with_required_roles'
  it_behaves_like 'show_entity_with_required_roles'
end
