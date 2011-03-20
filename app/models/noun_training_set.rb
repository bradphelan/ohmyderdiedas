class NounTrainingSet < ActiveRecord::Base
  belongs_to :noun
  belongs_to :training_set
end
