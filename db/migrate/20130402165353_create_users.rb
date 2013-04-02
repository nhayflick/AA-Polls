class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :username, :null => false
      t.integer :team_id

      t.timestamps
    end
  end
end
