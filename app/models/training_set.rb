class TrainingSet < ActiveRecord::Base

  belongs_to :user
  validates :user, :presence => true

  has_many :noun_training_sets
  has_many :nouns, :through=> :noun_training_sets

  def create_noun_from_string(string)
    Noun.transaction do
      Noun.create_from_string(string).tap do |noun|
        if self.nouns.where(:word => noun.word, :gender=>noun.gender).count > 0 
          raise "#{noun} has allready been added"
        else
          noun.training_sets.push self
        end
      end
    end
  end

  def can_be_accessed_by? user
    self.user == user
  end

end
