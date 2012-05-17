class User
  include Mongoid::Document
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  ## Database authenticatable
  field :email,              :type => String, :null => false, :default => ""
  field :encrypted_password, :type => String, :null => false, :default => ""

  ## Recoverable
  field :reset_password_token,   :type => String
  field :reset_password_sent_at, :type => Time

  ## Rememberable
  field :remember_created_at, :type => Time

  ## Trackable
  field :sign_in_count,      :type => Integer, :default => 0
  field :current_sign_in_at, :type => Time
  field :last_sign_in_at,    :type => Time
  field :current_sign_in_ip, :type => String
  field :last_sign_in_ip,    :type => String

  ## Encryptable
  # field :password_salt, :type => String

  ## Confirmable
  # field :confirmation_token,   :type => String
  # field :confirmed_at,         :type => Time
  # field :confirmation_sent_at, :type => Time
  # field :unconfirmed_email,    :type => String # Only if using reconfirmable

  ## Lockable
  # field :failed_attempts, :type => Integer, :default => 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token,    :type => String # Only if unlock strategy is :email or :both
  # field :locked_at,       :type => Time

  ## Token authenticatable
  field :authentication_token, :type => String

  field :admin,     :type => Boolean
  field :nickname,  :type => String
  field :birthdate, :type => Date
  field :gender,    :type => String
  
  has_many :prescriptions

  attr_accessible :email, :password, :password_confirmation, :remember_me, :birthdate, :nickname, :gender

  def self.find_for_facebook_oauth(access_token, signed_in_resource=nil)
    data = access_token.extra.raw_info
    logger.warn  data.inspect
    if data.birthday
      m, d, y = data.birthday.split("/")
      birthday = data.birthday ? Date.parse("#{y}-#{m}-#{d}") : nil
    else
      birthday = nil
    end
    username = data.username ? data.username : nil
    gender   = data.gender   ? data.gender   : nil 
    logger.warn  data.username
    logger.warn  username

    if user = User.where(:email => data.email).first
      # Update user info if need be
      user.nickname  ||= username    if username
      user.birthdate ||= birthday    if birthday
      user.gender    ||= data.gender if gender
      user.save
      user
    else # Create a user with a stub password. 
      password = Devise.friendly_token[0,20]
      User.create!(:email => data.email, :password => password, :password_confirmation => password, :gender => gender, :nickname => username, :birthdate => birthday) 
    end
  end
end
