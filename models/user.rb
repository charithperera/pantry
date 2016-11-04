class User < ActiveRecord::Base
  validates :email, :presence => {:message => "Email is required."}
  validates :email, :uniqueness => {:message => "Email has already been registered."}
  validates :password, :confirmation => {:message => "Passwords do not match."}
  validates :password_confirmation, :presence => {:message => "Please confirm password."}

  has_secure_password
  has_many :entries
  has_many :daily_stats
  # has_many :foods
  # has_many :foods, :through => :entries
end
