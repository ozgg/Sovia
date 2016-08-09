require 'rails_helper'

RSpec.describe Admin::AgentsController, type: :controller do
  let!(:entity) { create :agent }

  it_behaves_like 'list_for_administration'

end
