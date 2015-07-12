class Pattern < ActiveRecord::Base
  include HasLanguage
  include HasTrace
  include HasOwner
  include HasNameWithSlug

  belongs_to :user
  has_many :grains, dependent: :nullify
  has_many :comments, as: :commentable, dependent: :destroy

  validates_uniqueness_of :slug, scope: :language_id
end
