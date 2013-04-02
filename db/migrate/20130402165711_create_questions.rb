class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.integer :poll_id, :null => false
      t.string :body, :null => false

      t.timestamps
    end
  end
end
