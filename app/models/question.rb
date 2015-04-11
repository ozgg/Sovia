class Question < ActiveRecord::Base
  include HasOwner
  include HasLanguage

  belongs_to :agent
  has_many :answers, dependent: :destroy

  validates_presence_of :owner, :body
end
