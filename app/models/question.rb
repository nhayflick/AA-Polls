class Question < ActiveRecord::Base
  belongs_to :poll
  <<-SQL
    SELECT polls.*
    FROM polls
    WHERE polls.id = poll_id
  SQL

  has_many :choices, :dependent => :destroy
  <<-SQL
    SELECT choices.*
    FROM choices 
    WHERE choices.question_id = id
  SQL

  has_many :responses, :through => :choices
  <<-SQL
    SELECT responses.*
    FROM responses JOIN choices ON (responses.choice_id = choice.id)
    WHERE choices.question_id = id
  SQL

  attr_accessible :body, :poll_id

  validates :poll, presence: true
  validates :body, presence: true, length: { :maximum => 255 }

  def answer_for_user(user_id)
    self.responses.where("user_id = ?", user_id)
  end

  def has_answered_this_question?(user_id)
    self.responses.where("user_id = ?", user_id).count > 0
  end

  def add_choice(choice_body)
    Choice.create!(body: choice_body, question_id: self.id)
  end
end
