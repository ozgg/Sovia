require 'spec_helper'

describe TagsController do
  pending "Omnious refactoring"

  let!(:entry_tag) { create(:entry_tag, name: 'Эталон') }

  shared_examples "restricted area" do
    it "refuses to render tags list" do
      expect { get :index }.to raise_error(ApplicationController::UnauthorizedException)
    end

    it "refuses to render new tag form" do
      expect { get :new }.to raise_error(ApplicationController::UnauthorizedException)
    end

    it "refuses to render existing tag form" do
      expect { get :edit, id: entry_tag }.to raise_error(ApplicationController::UnauthorizedException)
    end

    it "refuses to update tag" do
      expect { patch :update, id: entry_tag }.to raise_error(ApplicationController::UnauthorizedException)
    end

    it "refuses to delete tag" do
      expect { delete :destroy, id: entry_tag }.to raise_error(ApplicationController::UnauthorizedException)
    end
  end

  context "anonymous user" do
    before(:each) { session[:user_id] = nil }

    it_should_behave_like "restricted area"
  end

  context "unauthorized user" do
    before(:each) { session[:user_id] = create(:user).id }

    it_should_behave_like "restricted area"
  end

  context "editor" do
    before(:each) { session[:user_id] = create(:editor).id }

    context "get index" do
      before(:each) { get :index }

      it "assigns tags to @tags" do
        expect(assigns[:tags]).to include(entry_tag)
      end

      it "renders tags/index" do
        expect(response).to render_template('tags/index')
      end
    end

    context "get show" do
      before(:each) { get :show, id: entry_tag }

      it "assigns tag to @tag" do
        expect(assigns[:tag]).to eq(entry_tag)
      end

      it "renders tags/show" do
        expect(response).to render_template('tags/show')
      end
    end

    context "get new" do
      before(:each) { get :new }

      it "assigns new tag to @tag" do
        expect(assigns[:tag]).to be_a_new(EntryTag)
      end

      it "renders tags/new" do
        expect(response).to render_template('tags/new')
      end
    end

    context "post create with valid attributes" do
      let(:action) { lambda { post :create, entry_tag: { name: 'Интересное' } } }

      it "assigns new tag to @tag" do
        action.call
        expect(assigns[:tag]).to be_a(EntryTag)
      end

      it "creates tag in database" do
        expect(action).to change(EntryTag, :count).by(1)
      end

      it "redirects to tag page" do
        action.call
        expect(response).to redirect_to(EntryTag.last)
      end

      it "adds flash message #{I18n.t('tag.added')}" do
        action.call
        expect(flash[:message]).to eq(I18n.t('tag.added'))
      end
    end

    context "post create with invalid attributes" do
      let(:action) { lambda { post :create, entry_tag: { name: ' ' } } }

      it "assigns new tag to @tag" do
        action.call
        expect(assigns[:tag]).to be_a_new(EntryTag)
      end

      it "doesn't create tag in database" do
        expect(action).not_to change(EntryTag, :count)
      end

      it "renders tags/new" do
        action.call
        expect(response).to render_template('tags/new')
      end
    end

    context "get edit" do
      before(:each) { get :edit, id: entry_tag }

      it "assigns tag to @tag" do
        expect(assigns[:tag]).to eq(entry_tag)
      end

      it "renders tags/edit" do
        expect(response).to render_template('tags/edit')
      end
    end

    context "patch update with valid parameters" do
      before(:each) { patch :update, id: entry_tag, entry_tag: { name: 'Прдунь!' } }

      it "assigns tag to @tag" do
        expect(assigns[:tag]).to eq(entry_tag)
      end

      it "updates tag" do
        entry_tag.reload
        expect(entry_tag.name).to eq('Прдунь!')
      end

      it "redirects to tag page" do
        expect(response).to redirect_to(entry_tag)
      end

      it "adds flash message #{I18n.t('tag.updated')}" do
        expect(flash[:message]).to eq(I18n.t('tag.updated'))
      end
    end

    context "patch update with invalid parameters" do
      before(:each) { patch :update, id: entry_tag, entry_tag: { name: ' ' } }

      it "assigns tag to @tag" do
        expect(assigns[:tag]).to eq(entry_tag)
      end

      it "leaves tag intact" do
        expect(entry_tag.name).to eq('Эталон')
      end

      it "renders tags/edit" do
        expect(response).to render_template('tags/edit')
      end
    end

    context "delete destroy" do
      let(:action) { lambda { delete :destroy, id: entry_tag } }

      it "removes tag from database" do
        expect(action).to change(EntryTag, :count).by(-1)
      end

      it "redirects to tags index" do
        action.call
        expect(response).to redirect_to(entry_tags_path)
      end

      it "adds flash message #{I18n.t('tag.deleted')}" do
        action.call
        expect(flash[:message]).to eq(I18n.t('tag.deleted'))
      end
    end
  end
end