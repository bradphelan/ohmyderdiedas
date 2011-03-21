class AddScoreToNounTrainingSet < ActiveRecord::Migration
  class NounTrainingSet < ActiveRecord::Base
  end

  def self.up
    add_column :noun_training_sets, :score, :integer, :default => 0
    NounTrainingSet.all.each do |nt|
      pp nt
      nt.score = 0
      nt.save!
    end

  end

  def self.down
  end
end
