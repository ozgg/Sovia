require 'spec_helper'

describe Comment do
  context "integrity" do
    let(:comment) { build(:comment) }
    let(:user) { create(:user) }
    let(:dream) { create(:dream) }

    it "has non-blank body" do
      comment.body = ' '
      comment.valid?
      expect(comment.errors).to have_key(:body)
    end

    it "is invalid without entry_id" do
      comment.valid?
      expect(comment.errors).to have_key(:entry)
    end
  end

  context "#notify_entry_owner?" do
    shared_examples "non-notifier" do
      it "returns false" do
        expect(comment).not_to be_notify_entry_owner
      end
    end

    context "when entry is anonymous" do
      let(:comment) { create(:comment, entry: create(:dream)) }

      it_should_behave_like "non-notifier"
    end

    context "when entry owner cannot receive letters" do
      let(:user) { create(:user) }
      let(:comment) { create(:comment, entry: create(:owned_dream, user: user) ) }

      it_should_behave_like "non-notifier"
    end

    context "when commentator is entry owner" do
      let(:user) { create(:confirmed_user, allow_mail: true) }
      let(:comment) { create(:comment, entry: create(:owned_dream, user: user), user: user ) }

      it_should_behave_like "non-notifier"
    end

    context "when commentator is not entry owner who can receive letters" do
      let(:user) { create(:confirmed_user, allow_mail: true) }
      let(:comment) { create(:comment, entry: create(:owned_dream, user: user))}

      it "returns true" do
        expect(comment).to be_notify_entry_owner
      end
    end

    context "when commentator replies to owner's comment" do
      let(:user) { create(:confirmed_user, allow_mail: true) }
      let(:dream) { create(:owned_dream, user: user) }
      let(:parent) { create(:comment, entry: dream, user: user) }
      let(:comment) { create(:comment, entry: dream, parent: parent) }

      it_should_behave_like "non-notifier"
    end

    context "when entry owner replies to another comment" do
      let(:user) { create(:confirmed_user, allow_mail: true) }
      let(:dream) { create(:owned_dream, user: user) }
      let(:parent) { create(:comment, entry: dream) }
      let(:comment) { create(:comment, entry: dream, parent: parent, user: user) }

      it_should_behave_like "non-notifier"
    end
  end

  context "#notify_parent_owner?" do
    let(:dream) { create(:owned_dream) }

    shared_examples "non-notifier" do
      it "returns false" do
        expect(comment).not_to be_notify_parent_owner
      end
    end

    context "when parent is anonymous" do
      let(:parent) { create(:comment, entry: dream) }
      let(:comment) { create(:comment, parent: parent, entry: dream) }

      it_should_behave_like "non-notifier"
    end

    context "when parent owner cannot receive letters" do
      let(:user) { create(:user) }
      let(:parent) { create(:comment, entry: dream, user: user ) }
      let(:comment) { create(:comment, parent: parent, entry: dream) }

      it_should_behave_like "non-notifier"
    end

    context "when commentator is parent owner" do
      let(:user) { create(:confirmed_user, allow_mail: true) }
      let(:parent) { create(:comment, entry: dream, user: user ) }
      let(:comment) { create(:comment, parent: parent, entry: dream, user: user ) }

      it_should_behave_like "non-notifier"
    end

    context "when commentator is not parent owner who can receive letters" do
      let(:user) { create(:confirmed_user, allow_mail: true) }
      let(:parent) { create(:comment, entry: dream, user: user) }
      let(:comment) { create(:comment, parent: parent, entry: dream) }

      it "returns true" do
        expect(comment).to be_notify_parent_owner
      end
    end
  end
end