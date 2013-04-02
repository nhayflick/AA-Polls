class CreatePolls < ActiveRecord::Migration
  def change
    create_table :polls do |t|
      t.integer :creator_id, :null => false
      t.string :title, :null => false
      t.integer :team_id

      t.timestamps
    end
  end
end
