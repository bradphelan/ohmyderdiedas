class AddNameToTrainingSet < ActiveRecord::Migration
  class TrainingSet < ActiveRecord::Base
  end

  def self.up
    add_column :training_sets, :name, :string
    TrainingSet.all.each_with_index do |s,i|
      s.name = "set #{i}"
    end
  end

  def self.down
    remove_column :training_sets, :name
  end
end
