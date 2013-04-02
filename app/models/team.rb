class Team < ActiveRecord::Base
  attr_accessible :name

  validates :name, presence: true, uniqueness: true, length: { :maximum => 255 }
end
