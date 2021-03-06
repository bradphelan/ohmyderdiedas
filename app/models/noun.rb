class Noun < ActiveRecord::Base
  validates :word, :presence => true
  validates :gender, :presence => true
  has_many :noun_training_sets
  has_many :training_sets, :through => :noun_training_sets

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

    Noun.where(:gender => gender, :word => word).each do |w|
      return w
    end

    Noun.create! :gender => gender, :word => word
  end

  def as_json(options=nil)
    super(options).merge({ :article => article })
  end


  def article
    g = case gender
    when "m"
      "der"
    when "f"
      "die"
    when "n"
      "das"
    end
  end

  def to_s
    "#{article.capitalize} #{word.capitalize}"
  end
end
