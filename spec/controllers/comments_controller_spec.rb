require 'rails_helper'

RSpec.describe CommentsController, type: :controller do
  let!(:language) { create :russian_language }
  let(:administrator) { create :administrator, language: language }
  let(:user) { create :user, language: language }
  let!(:entity) { create :comment, user: user, language: language }

  before :each do
    allow(controller).to receive(:current_user).and_return(user)
    allow(controller).to receive(:require_role)
    I18n.locale = language.code
  end

  shared_examples 'entity_assigner' do
    it 'assigns post to @entity' do
      expect(assigns[:entity]).to eq(entity)
    end
  end

  describe 'get index' do
    before(:each) { get :index }
    
    it_behaves_like 'administrative_page'

    it 'assigns entity to @collection' do
      expect(assigns[:collection]).to include(entity)
    end

    it 'renders view "index"' do
      expect(response).to render_template(:index)
    end
  end

  describe 'get new' do
    before(:each) { get :new }

    it 'assigns new Comment to @entity' do
      expect(assigns[:entity]).to be_a_new(Comment)
    end

    it 'renders view "new"' do
      expect(response).to render_template(:new)
    end
  end

  describe 'post create' do
    context 'when data is valid' do
      let!(:dream) { create :dream }
      let(:data) { { commentable_id: dream.id, commentable_type: dream.class, body: '1'} }

      let(:action) { -> { post :create, comment: data } }

      it 'creates new Comment in database' do
        expect(action).to change(Comment, :count).by(1)
      end

      it 'redirects to commentable page' do
        action.call
        expect(response).to redirect_to(Comment.last.commentable)
      end
    end

    context 'when data is invalid' do
      let(:action) { -> { post :create, comment: { body: ' ' } } }

      it 'leaves comments table intact' do
        expect(action).not_to change(Comment, :count)
      end

      it 'renders view :new' do
        action.call
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'get show' do
    before(:each) { get :show, id: entity }

    it_behaves_like 'entity_assigner'
    it_behaves_like 'administrative_page'

    it 'renders view "show"' do
      expect(response).to render_template(:show)
    end
  end

  describe 'get edit' do
    before(:each) { get :edit, id: entity }

    it_behaves_like 'entity_assigner'
    it_behaves_like 'administrative_page'

    it 'renders view "edit"' do
      expect(response).to render_template(:edit)
    end
  end

  describe 'patch update' do
    context 'when data is valid' do
      let(:action) { -> { patch :update, id: entity, comment: { body: 'new body'} } }

      it 'updates entity' do
        action.call
        entity.reload
        expect(entity.body).to eq('new body')
      end

      it 'redirects to entity page' do
        action.call
        expect(response).to redirect_to(entity)
      end
    end

    context 'when data is invalid' do
      let(:action) { -> { patch :update, id: entity, comment: { body: ' '} } }

      it 'does not update entity' do
        action.call
        entity.reload
        expect(entity.body).not_to be_blank
      end

      it 'renders view "edit"' do
        action.call
        expect(response).to render_template(:edit)
      end
    end

    context 'restricting access' do
      before(:each) { patch :update, id: entity, comment: { body: 'new lead'} }

      it_behaves_like 'administrative_page'
    end
  end

  describe 'delete destroy' do
    context 'changing database' do
      let(:action) { -> { delete :destroy, id: entity } }

      it 'removes entity from database' do
        expect(action).to change(Comment, :count).by(-1)
      end
    end

    context 'redirect and restriction' do
      before(:each) { delete :destroy, id: entity }

      it_behaves_like 'administrative_page'

      it 'redirects to comments page' do
        expect(response).to redirect_to(comments_path)
      end
    end
  end
end