class CreateTrainingSets < ActiveRecord::Migration
  def self.up
    create_table :training_sets do |t|
      t.timestamps
      t.references :user
      t.string :tags 
    end
  end

  def self.down
    drop_table :training_sets
  end
end
