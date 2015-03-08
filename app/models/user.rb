class User < ActiveRecord::Base
  ROLE_ANYONE    = 0
  ROLE_EDITOR    = 1
  ROLE_MODERATOR = 2
  ROLE_DECENT    = 4
  ROLE_ADMINISTRATOR = 5

  GENDER_FEMALE = 0
  GENDER_MALE   = 1

  has_many :entries, dependent: :restrict_with_exception
  has_many :codes, dependent: :destroy
  has_many :comments, dependent: :nullify
  has_many :user_tags, dependent: :destroy
  has_many :deeds, dependent: :destroy
  has_many :user_roles, dependent: :destroy
  belongs_to :language

  has_secure_password

  validates_uniqueness_of :login
  validates_uniqueness_of :email, allow_nil: true
  validates_format_of :login, with: /\A[a-z0-9_]{1,30}\z/
  validate :email_should_be_reasonable
  before_validation :normalize_login, :normalize_email

  mount_uploader :avatar, AvatarUploader

  def self.genders_for_select
    prefix  = 'activerecord.attributes.user.enums.genders.'
    genders = [[I18n.t('not_selected'), '']]
    genders << [I18n.t(prefix + 'female'), GENDER_FEMALE]
    genders << [I18n.t(prefix + 'male'), GENDER_MALE]
    genders
  end

  def moderator?
    has_role? :moderator
  end

  def editor?
    has_role? :posts_manager
  end

  def decent?
    entries_count >= 5
  end

  def has_role?(role)
    via_mask  = role.is_a?(Integer) ? roles_mask & role == role : false
    via_roles = (role.is_a?(String) || role.is_a?(Symbol)) ? UserRole.exists_for_user?(role.to_s, self) : false

    via_mask | via_roles
  end

  def can_receive_letters?
    mail_confirmed? && allow_mail? && !email.blank?
  end

  def email_confirmation
    Code::Confirmation.code_for_user(self) unless mail_confirmed? || email.blank?
  end

  def password_recovery
    Code::Recovery.code_for_user(self) unless email.blank?
  end

  def should_use_gravatar?
    use_gravatar? && !email.blank? && mail_confirmed?
  end

  def gravatar_image(size)
    image = Digest::MD5.hexdigest(email.downcase)
    "http://www.gravatar.com/avatar/#{image}?s=#{size}&d=identicon"
  end

  def roles=(roles)
    roles.each do |role, flag|
      user_role = UserRole.role_for_user(role, self)
      if flag.to_i > 0
        UserRole.create!(user: self, role: role.to_s) if user_role.nil?
      else
        user_role.destroy unless user_role.nil?
      end
    end
  end

  def gender_string
    case gender
      when GENDER_MALE
        I18n.t 'activerecord.attributes.user.enums.genders.male'
      when GENDER_FEMALE
        I18n.t 'activerecord.attributes.user.enums.genders.female'
      else
        I18n.t 'not_selected'
    end
  end

  protected

  def normalize_login
    login.downcase!
  end

  def normalize_email
    email.downcase! unless email.nil?
  end

  def email_should_be_reasonable
    unless email.nil? || email =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/
      errors.add(:email, I18n.t('activerecord.errors.models.user.attributes.email.unreasonable'))
    end
  end
end
