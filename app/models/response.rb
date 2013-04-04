class Response < ActiveRecord::Base
  
  attr_accessible :choice_id, :user_id

  belongs_to :user
  # <<-SQL
  #   SELECT users.*
  #   FROM users
  #   WHERE users.id = user_id
  # SQL

  belongs_to :choice
  # <<-SQL
  #   SELECT choices.*
  #   FROM choices
  #   WHERE choices.id = choice_id
  # SQL

  has_one :poll, :through => :choice
  # <<-SQL
  #   SELECT polls.*
  #   FROM polls JOIN questions ON (questions.poll_id = poll.id)
  #   JOIN choices ON (choices.question_id = questions.id)
  #   WHERE choices.id = choice_id
  #   LIMIT 1
  # SQL

  has_one :question, :through => :choice
  # <<-SQL
  #   SELECT questions.*
  #   FROM questions JOIN choices ON (choices.question_id = questions.id)
  #   WHERE choices.id = choice_id
  #   LIMIT 1
  # SQL

  validates :choice, :user, presence: true
  validate :cannot_answer_own_poll, :user_in_team, 
    :one_user_response_per_question
 
  # REV: Looks right to me!
  def cannot_answer_own_poll
    if poll.creator_id == user_id
      errors[:user_id] << "can't answer your own poll"
    end
  end

  def user_in_team
    if poll.team_id && poll.team_id != user.team_id
      errors[:user_id] << "only team members can answer this poll"
    end
  end

  def one_user_response_per_question
    existing_response = question.answer_for_user(user_id)
    unless existing_response.empty? || existing_response.first.id == id
      errors[:user_id] << "only one answer per user allowed"
    end
  end
end
