class User < ActiveRecord::Base
  attr_accessible :username, :team_id

  has_many :polls, foreign_key: "creator_id", :dependent => :destroy
  # <<-SQL
  # SELECT polls.*
  # FROM polls
  # WHERE polls.creator_id = id
  # SQL

  has_many :responses, :dependent => :destroy
  # <<-SQL
  # SELECT responses.*
  # FROM responses
  # WHERE responses.user_id = id
  # SQL

  belongs_to :team
  # <<-SQL
  # SELECT teams.*
  # FROM teams
  # WHERE teams.id = team_id
  # SQL

  validates :username, presence: true, uniqueness: true, 
    length: { :maximum => 255 }
  validates :team, presence: true, :unless => :no_team?

   def no_team?
    team_id.nil?
  end
end
