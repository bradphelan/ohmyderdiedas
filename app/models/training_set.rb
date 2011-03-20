class TrainingSet < ActiveRecord::Base

  belongs_to :user
  validates :user, :presence => true

  has_many :noun_training_sets
  has_many :nouns, :through=> :noun_training_sets

end
