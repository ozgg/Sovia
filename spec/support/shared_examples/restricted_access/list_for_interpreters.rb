require 'rails_helper'

RSpec.shared_examples_for 'list_for_interpreters' do
  describe 'get index' do
    let(:user) { create :chief_interpreter }

    before :each do
      allow(subject).to receive(:require_role)
      allow(subject).to receive(:current_user).and_return(user)
      allow(entity.class).to receive(:page_for_administration)
      get :index
    end

    it_behaves_like 'page_for_interpreters'

    it 'sends :page_for_administration to entity class' do
      expect(entity.class).to have_received(:page_for_administration)
    end
  end
end
