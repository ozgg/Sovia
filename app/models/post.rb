class Post < ActiveRecord::Base
  include HasLanguage
  include HasUser

  belongs_to :agent
  has_many :comments, as: :commentable, dependent: :destroy

  validates_presence_of :user, :title, :body
  mount_uploader :image, ImageUploader

  def self.recent_posts(show_hidden = false)
    clause = show_hidden ? {} : { show_in_list: true }
    self.where(clause).order('id desc').first(3)
  end

  # Is post editable by given user?
  #
  # @param [User] user or nil for anonymous user
  # @return [Bool]
  def editable_by?(user)
    user.is_a?(User) && (self.user == user || user.has_role?(:posts_manager))
  end

  # Post is visible to user?
  #
  # @param [User] user
  # @return [Bool]
  def visible_to?(user)
    user.nil? || user.is_a?(User)
  end

  # Get the name of post author
  #
  # @return [String]
  def author_name
    user.login
  end

  # Get text preview for list of posts
  #
  # @return [String]
  def preview
    lead || first_passage
  end

  # Get the first passage from body
  #
  # @return [String]
  def first_passage
    body.split("\n").first
  end

  # Get title for view
  #
  # @return [String]
  def parsed_title
    title
  end

  def toggle_visibility!
    self.lead = self.first_passage if self.lead.blank?
    self.show_in_list = !self.show_in_list?
    save
  end
end
