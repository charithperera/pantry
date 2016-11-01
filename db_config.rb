require 'active_record'

options = {
  adapter: 'postgresql',
  database: 'pantry'
}

ActiveRecord::Base.establish_connection(options)
