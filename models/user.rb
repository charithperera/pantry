class User < ActiveRecord::Base
  has_secure_password
  has_many :entries
  has_many :daily_stats
  has_many :foods, :through => :entries
end
