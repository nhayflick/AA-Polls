class Poll < ActiveRecord::Base
  
  attr_accessible :creator_id, :title, :team_id

  belongs_to :creator, class_name: "User"
  # <<-SQL
  # SELECT users.*
  # FROM users
  # WHERE creator_id = users.id
  # SQL

  belongs_to :team
  # <<-SQL
  # SELECT teams.*
  # FROM teams
  # WHERE team_id = teams.id
  # SQL

  has_many :questions, :dependent => :destroy
  # <<-SQL
  # SELECT questions.*
  # FROM questions
  # WHERE questions.id = question_id
  # SQL

  has_many :choices, :through => :questions
  # <<-SQL
  # SELECT choices.*
  # FROM choices JOIN questions ON (choices.question_id=questions.id)
  # WHERE questions.id = question_id 
  # SQL

  has_many :responses, :through => :choices
  # <<-SQL
  # SELECT responses.*
  # FROM responses JOIN choices ON (responses.choice_id = choice.id)
  # JOIN questions ON (choices.question_id=questions.id)
  # WHERE questions.id = question_id 
  # SQL

  validates :creator, presence: true
  validates :title, presence: true, length: { :maximum => 255 }
  validates :team, presence: true, :unless => :no_team?

  def no_team?
    team_id.nil?
  end

  def can_user_answer?(user)
    team_id.nil? || team_id == user.team_id
  end

  def add_question(question_body)
    Question.create!(body: question_body, poll_id: self.id)
  end

end
