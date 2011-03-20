class NounTrainingSet < ActiveRecord::Migration
  def self.up
    create_table :noun_training_sets, :id => false do |t|
      t.timestamps
      t.references :noun
      t.references :training_set
    end
  end

  def self.down
    drop_table :noun_training_set
  end
end
