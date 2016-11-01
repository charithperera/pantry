require 'pry'
require 'active_record'
require_relative 'db_config'
require_relative 'models/food'
require_relative 'models/user'
require_relative 'models/entry'

u1 = User.new
u1.email = "test@test.com"
u1.password_digest = "somethng"
u1.save

u2 = User.new
u2.email = "test@test.com"
u2.password_digest = "somethng"
u2.save

f1 = Food.new
f1.save
f2 = Food.new
f2.save

binding.pry
