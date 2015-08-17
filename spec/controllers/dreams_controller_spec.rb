require 'rails_helper'

RSpec.describe DreamsController, type: :controller do
  let(:language) { create :russian_language }
  let(:owner) { create :user, language: language }
  let(:user) { create :user, language: language }
  let!(:generally_accessible_dream) { create :dream, language: language }
  let!(:dream_for_community) { create :dream_for_community, user: owner, language: language }
  let!(:dream_for_followees) { create :dream_for_followees, user: owner, language: language }
  let!(:personal_dream) { create :personal_dream, user: owner, language: language }

  before :each do
    allow(controller).to receive(:current_user).and_return(user)
    allow(controller).to receive(:restrict_editing)
    allow_any_instance_of(Dream).to receive(:visible_to?).and_return(true)
    I18n.locale = language.code
  end

  shared_examples 'restricted_editing' do
    it 'restricts editing' do
      expect(controller).to have_received(:restrict_editing)
    end
  end

  shared_examples 'entity_assigner' do
    it 'assigns Dream to @entity' do
      expect(assigns[:entity]).to be_a(Dream)
    end

    it 'checks visibility of entity to user' do
      expect(assigns[:entity]).to have_received(:visible_to?).with(user)
    end
  end

  shared_examples 'generally_accessible_dreams' do
    it 'adds generally accessible dreams to @collection' do
      expect(assigns[:collection]).to include(generally_accessible_dream)
    end
  end

  shared_examples 'hidden_dreams_for_followees' do
    it 'does not add dreams for followees to @collection' do
      expect(assigns[:collection]).not_to include(dream_for_followees)
    end
  end

  shared_examples 'hidden_personal_dreams' do
    it 'does not add personal dreams to @collection' do
      expect(assigns[:collection]).not_to include(personal_dream)
    end
  end

  shared_examples 'setting_dream_patterns' do
    it 'sets dream grains' do
      expect_any_instance_of(Dream).to receive(:grains_string=)
      action.call
    end

    it 'caches dream patterns' do
      expect_any_instance_of(Dream).to receive(:cache_patterns!)
      action.call
    end
  end

  shared_examples 'not_setting_dream_patterns' do
    it 'does not set new grains' do
      expect_any_instance_of(Dream).not_to receive(:grains_string=)
      action.call
    end

    it 'does not cache patterns' do
      expect_any_instance_of(Dream).not_to receive(:cache_patterns!)
      action.call
    end
  end

  describe 'get index' do
    context 'when user is not logged in' do
      before :each do
        allow(controller).to receive(:current_user).and_return(nil)
        get :index
      end

      it_behaves_like 'generally_accessible_dreams'
      it_behaves_like 'hidden_dreams_for_followees'
      it_behaves_like 'hidden_personal_dreams'

      it 'does not add dreams for community to @collection' do
        expect(assigns[:collection]).not_to include(dream_for_community)
      end
    end

    context 'when user is logged in' do
      before(:each) { get :index }

      it_behaves_like 'generally_accessible_dreams'
      it_behaves_like 'hidden_dreams_for_followees'
      it_behaves_like 'hidden_personal_dreams'

      it 'adds dreams for community to @collection' do
        expect(assigns[:collection]).to include(dream_for_community)
      end
    end
  end

  describe 'get new' do
    before(:each) { get :new }

    it 'assigns new Dream to @entity' do
      expect(assigns[:entity]).to be_a_new(Dream)
    end

    it 'renders view "new"' do
      expect(response).to render_template(:new)
    end
  end

  describe 'post create' do
    context 'when data is valid' do
      let(:action) { -> { post :create, dream: attributes_for(:dream).merge(privacy: 'generally_accessible') } }

      it_behaves_like 'setting_dream_patterns'

      it 'creates new Dream in database' do
        expect(action).to change(Dream, :count).by(1)
      end

      it 'redirects to created dream page' do
        action.call
        expect(response).to redirect_to(Dream.last)
      end
    end

    context 'when data is invalid' do
      let(:action) { -> { post :create, dream: { body: ' ' } } }

      it_behaves_like 'not_setting_dream_patterns'

      it 'leaves dreams table intact' do
        expect(action).not_to change(Dream, :count)
      end

      it 'renders view :new' do
        action.call
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'get show' do
    before(:each) { get :show, id: generally_accessible_dream }

    it_behaves_like 'entity_assigner'

    it 'renders view "show"' do
      expect(response).to render_template(:show)
    end
  end

  describe 'get edit' do
    before(:each) { get :edit, id: generally_accessible_dream }

    it_behaves_like 'entity_assigner'
    it_behaves_like 'restricted_editing'

    it 'renders view "edit"' do
      expect(response).to render_template(:edit)
    end
  end

  describe 'patch update' do
    before(:each) { allow(controller).to receive(:current_user).and_return(owner) }

    context 'when data is valid' do
      let(:action) { -> { patch :update, id: dream_for_community, dream: { body: 'new text'} } }

      it_behaves_like 'setting_dream_patterns'

      it 'updates dream' do
        action.call
        dream_for_community.reload
        expect(dream_for_community.body).to eq('new text')
      end

      it 'redirects to dream page' do
        action.call
        expect(response).to redirect_to(dream_for_community)
      end
    end

    context 'when data is invalid' do
      let(:action) { -> { patch :update, id: dream_for_community, dream: { body: ' '} } }

      it_behaves_like 'not_setting_dream_patterns'

      it 'does not update post' do
        action.call
        dream_for_community.reload
        expect(dream_for_community.body).not_to be_blank
      end

      it 'renders view "edit"' do
        action.call
        expect(response).to render_template(:edit)
      end
    end

    context 'when editor is not owner' do
      let(:action) { -> { patch :update, id: dream_for_community, dream: { body: 'new text'} } }

      before(:each) { allow(controller).to receive(:current_user).and_return(create :administrator) }

      it_behaves_like 'not_setting_dream_patterns'
    end
  end

  describe 'delete destroy' do
    before(:each) { allow(controller).to receive(:current_user).and_return(owner) }

    context 'changing database' do
      let(:action) { -> { delete :destroy, id: generally_accessible_dream } }

      it 'removes dream from database' do
        expect(action).to change(Dream, :count).by(-1)
      end
    end

    context 'redirect and restriction' do
      before(:each) { delete :destroy, id: generally_accessible_dream }

      it_behaves_like 'restricted_editing'

      it 'redirects to dreams page' do
        expect(response).to redirect_to(dreams_path)
      end
    end
  end

  describe 'get tagged' do
    pending
  end
end
