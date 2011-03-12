class TrainingSet < ActiveRecord::Base

  belongs_to :user
  validates :user, :presence => true
  acts_as_tagger

  def nouns
    Noun.tagged_with tags.split(/,/).map(&:strip)
  end

end
