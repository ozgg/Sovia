require 'spec_helper'

describe "my/index/index.html.erb" do
  shared_examples "mandatory links" do
    it "has link to profile page" do
      expect(rendered).to have_selector('a', href: my_profile_path)
    end

    it "has link to user's dreams page" do
      expect(rendered).to have_selector('a', href: my_dreams_path)
    end

    it "has link to user's tags page" do
      expect(rendered).to have_selector('a', href: my_symbols_path)
    end

    it "has link to user's deeds page" do
      expect(rendered).to have_selector('a', href: my_deeds_path)
    end

    it "has link to user's posts page" do
      expect(rendered).to have_selector('a', href: my_posts_path)
    end

    it "has link to user's thoughts page" do
      expect(rendered).to have_selector('a', href: my_thoughts_path)
    end
  end

  context "when user's email is confirmed" do
    let(:user) { create(:confirmed_user) }

    before(:each) do
      view.stub(:current_user).and_return(user)
      render
    end

    it_should_behave_like "mandatory links"

    it "has no link to email confirmation page" do
      expect(rendered).not_to have_selector('a', href: my_confirmation_path)
    end
  end

  context "when user's email is not confirmed" do
    let(:user) { create(:user) }

    before(:each) do
      view.stub(:current_user).and_return(user)
      render
    end

    it_should_behave_like "mandatory links"

    it "has link to email confirmation page" do
      expect(rendered).to have_selector('a', href: my_confirmation_path)
    end
  end
end
