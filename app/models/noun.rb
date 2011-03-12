class Noun < ActiveRecord::Base
  validates :word, :presence => true
  validates :gender, :presence => true
  acts_as_taggable_on :tags
end
