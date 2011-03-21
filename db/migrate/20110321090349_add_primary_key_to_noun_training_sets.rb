class AddPrimaryKeyToNounTrainingSets < ActiveRecord::Migration
  class NounTrainingSet < ActiveRecord::Base
  end

  def self.up
    change_table :noun_training_sets do |t|
      t.column :id, :primary_key
      NounTrainingSet.reset_column_information
      NounTrainingSet.all.each_with_index do |o, i|
        o.id = i + 1 # Database id's don't like being zero
        o.save!
      end
    end
  end

  def self.down
    remove_column :noun_training_sets, :id
  end
end
