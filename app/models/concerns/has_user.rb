module HasUser
  extend ActiveSupport::Concern

  included do
    belongs_to :user, counter_cache: true
  end

  def owned_by?(person)
    self.user == person
  end
end
