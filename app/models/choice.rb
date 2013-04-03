class Choice < ActiveRecord::Base
  
  attr_accessible :body, :question_id

  belongs_to :question
  # <<-SQL
  # SELECT questions.*
  # FROM questions WHERE questions.id = question_id
  # SQL

  has_many :responses, :dependent => :destroy
  # <<-SQL
  # SELECT responses.*
  # FROM responses WHERE responses.choice_id = id
  # SQL

  has_one :poll, :through => :question
  # <<-SQL
  # SELECT polls.*
  # FROM polls JOIN questions
  # ON questions.poll_id = polls.id
  # WHERE questions.id = question_id
  # SQL

  validates :body, presence: true, length: { :maximum => 255 }
  validates :question, presence: true 
end
