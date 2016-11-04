class Food < ActiveRecord::Base
  # has_many :entries
  # has_many :users, :through => :entries
  # has_one :entry
  validates :brand, :presence => {:message => "Brand name required"}
  validates :name, :presence => {:message => "Food name required"}
  validates :serving_type, :presence => {:message => "Serving type required"}
  validates :serving_size, :presence => {:message => "Serving size required"}
  validates :serving_size, :numericality => { :greater_than_or_equal_to => 0, :message => "Serving size invalid amount" }
  validates :calories, :presence => {:message => "Calories required"}
  validates :calories, :numericality => { :greater_than_or_equal_to => 0, :message => "Calories invalid amount" }
  validates :fat, :presence => {:message => "Fat required"}
  validates :fat, :numericality => { :greater_than_or_equal_to => 0, :message => "Fat invalid amount" }
  validates :protein, :presence => {:message => "Protein required"}
  validates :protein, :numericality => { :greater_than_or_equal_to => 0, :message => "Protein invalid amount" }
end
