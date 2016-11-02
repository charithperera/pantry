class Entry < ActiveRecord::Base
  belongs_to :user
  belongs_to :food
  # belongs_to :food
end
