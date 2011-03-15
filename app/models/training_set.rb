class TrainingSet < ActiveRecord::Base

  belongs_to :user
  validates :user, :presence => true

  def nouns(user)
    Noun.tagged_with tags.split(/,/).map(&:strip), :any => true, :owned_by => user
  end

end
