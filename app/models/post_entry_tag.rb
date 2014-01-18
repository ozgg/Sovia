class PostEntryTag < ActiveRecord::Base
  belongs_to :post
  belongs_to :entry_tag

  private

  def increment_dreams_count
    entry_tag.increment! :dreams_count if post.dream?
  end

  def decrement_dreams_count
    entry_tag.decrement! :dreams_count if post.dream?
  end
end
