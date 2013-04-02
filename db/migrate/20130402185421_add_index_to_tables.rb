class AddIndexToTables < ActiveRecord::Migration
  def change
  	add_index :choices, :question_id
  	add_index :polls, :creator_id
  	add_index :polls, :team_id
  	add_index :questions, :poll_id
  	add_index :responses, :user_id
  	add_index :responses, :choice_id
  	add_index :teams, :name, :unique => true
  	add_index :users, :username, :unique => true
  	add_index :users, :team_id
  end
end
