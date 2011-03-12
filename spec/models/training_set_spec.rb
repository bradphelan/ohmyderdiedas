require 'spec_helper'

describe TrainingSet do
  before do
    @user = User.create! \
       :email => "brad@cow.com", 
       :password => "password", 
       :password_confirmation => "password"
     


    @noun1 = Noun.create! :word => 'Katze', :gender => 'f'
    @noun2 = Noun.create! :word => 'Mann', :gender => 'm'
    @noun3 = Noun.create! :word => 'Kind', :gender => 'n'

    @noun1.tag_list = 'animals, lesson1'
    @noun1.save!

    @noun2.tag_list = 'people, lesson1'
    @noun2.save!

    @noun3.tag_list = 'people, lesson2'
    @noun3.save!

    @ts1 = TrainingSet.create! :user => @user 
    @ts2 = TrainingSet.create! :user => @user 

    @ts1.tags = 'lesson1'
    @ts2.tags = 'lesson2'
  end

  describe "#nouns" do
    before do
    end
    it "should retrieve tagged nouns" do

      [@noun1, @noun2].each do |n|
        @ts1.nouns.should include n
      end

      @ts2.nouns.should include @noun3
    end
  end

end
