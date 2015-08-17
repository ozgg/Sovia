require 'rails_helper'

RSpec.describe DeedsController, type: :controller do
  let(:user) { create :user }
  let!(:deed) { create :deed, user: user }

  before :each do
    allow(controller).to receive(:restrict_anonymous_access)
    allow(controller).to receive(:current_user).and_return(user)
  end

  shared_examples 'entity_assigner' do
    it 'assigns deed to @entity' do
      expect(assigns[:entity]).to eq(deed)
    end
  end

  describe 'get index' do
    before(:each) { get :index }

    it 'renders view "index"' do
      expect(response).to render_template(:index)
    end
  end

  describe 'get new' do
    before(:each) { get :new }

    it_behaves_like 'page_for_users'

    it 'assigns new instance Deed to @entity' do
      expect(assigns[:entity]).to be_a_new(Deed)
    end

    it 'renders view "new"' do
      expect(response).to render_template(:new)
    end
  end

  describe 'post create' do
    let(:action) { -> { post :create, deed: attributes_for(:deed).merge(status: :issued) } }

    context 'authorization and redirects' do
      before(:each) { action.call }

      it_behaves_like 'page_for_users'

      it 'redirects to created deed' do
        expect(response).to redirect_to(Deed.last)
      end
    end

    context 'database change' do
      it 'inserts row into deeds table' do
        expect(action).to change(Deed, :count).by(1)
      end
    end
  end

  describe 'get show' do
    before(:each) { get :show, id: deed }

    it_behaves_like 'page_for_users'
    it_behaves_like 'entity_assigner'

    it 'renders view "show"' do
      expect(response).to render_template(:show)
    end
  end

  describe 'get edit' do
    before(:each) { get :edit, id: deed }

    it_behaves_like 'page_for_users'
    it_behaves_like 'entity_assigner'

    it 'renders view "edit"' do
      expect(response).to render_template(:edit)
    end
  end

  describe 'patch update' do
    before(:each) do
      patch :update, id: deed, deed: { essence: 'new value' }
    end

    it_behaves_like 'page_for_users'
    it_behaves_like 'entity_assigner'

    it 'updates deed' do
      deed.reload
      expect(deed.essence).to eq('new value')
    end

    it 'redirects to deed page' do
      expect(response).to redirect_to(deed)
    end
  end

  describe 'delete destroy' do
    let(:action) { -> { delete :destroy, id: deed } }

    context 'authorization' do
      before(:each) { action.call }

      it_behaves_like 'page_for_users'

      it 'redirects to deeds page' do
        expect(response).to redirect_to(my_deeds_path)
      end
    end

    it 'removes deed from database' do
      expect(action).to change(Deed, :count).by(-1)
    end
  end
end