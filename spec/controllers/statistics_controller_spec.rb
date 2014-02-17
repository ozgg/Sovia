require 'spec_helper'

describe StatisticsController do
  pending "Omnious refactoring"

  context "get index" do
    before(:each) { get :index }

    it "renders statistics/index" do
      expect(response).to render_template('statistics/index')
    end
  end

  context "get symbols" do
    let!(:tag) { create(:entry_tag) }
    before(:each) { get :symbols }

    it "assigns entry tags to @tags" do
      expect(assigns[:tags]).to include(tag)
    end

    it "renders statistics/symbols" do
      expect(response).to render_template('statistics/symbols')
    end
  end
end