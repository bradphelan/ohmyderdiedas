class Noun < ActiveRecord::Base
  validates :word, :presence => true
  validates :gender, :presence => true
  acts_as_taggable_on :tags

  ARTICLES = %w(der die das)

  def self.create_from_string str
    str = str.downcase.split
    article = str[0]
    word = str[1]

    gender = case article
    when "der"
      "m"
    when "die"
      "f"
    when "das"
      "n"
    else
      raise "'#{article}' is not a valid article"
    end

    Noun.create! :gender => gender, :word => word
  end

  def to_s
    g = case gender
    when "m"
      "der"
    when "f"
      "die"
    when "n"
      "das"
    end
    "#{g.capitalize} #{word.capitalize}"
  end
end
