class TrainingSetsController < ApplicationController
  def index
    @sets = TrainingSet.where :user_id => current_user.id
  end

  def show
    @set = TrainingSet.find(params[:id])
    respond_to do |format|
      format.html do
      end
    end
  end

  before_filter :set_page

  def set_page
    @page = "page_sets_manage"
  end

  def new
    @set = TrainingSet.new :user => current_user
  end

  def create
    @set = TrainingSet.create! params[:training_set].merge(:user=>current_user)
    redirect_to edit_training_set_path(@set)
  end

  def edit
    @set = TrainingSet.find(params[:id])
  end

  def update
    @set = TrainingSet.find(params[:id])
    @set.name = params[:training_set][:name]
    @set.save!
    redirect_to edit_training_set_path
  end

  def words
    @set = TrainingSet.find(params[:id])
    respond_to do |format|
      format.json do
        render :json => @set.nouns(current_user)
      end
    end
  end

  def new_word
    begin
      @training_set = TrainingSet.find(params[:id])
      noun = @training_set.create_noun_from_string params['word']
    rescue Exception => e
      Rails.logger.error e
      @error = e.to_s
    end
    respond_to do |format|
      format.json do
        if @error
          render :text => @error, :layout => false, :status => :unprocessable_entity
        else
          render :json => noun.to_json, :layout => false
        end
      end
    end
  end

  BOUNDARY = 10

  def random_word
    @set = TrainingSet.find(params[:id])

    # Update the score for the previous
    # word if it is available
    if params['word'] && params['gender']
      previous_word = Noun.where(:word=>params[:word], :gender=>params[:gender]).first
      previous_ts   = previous_word.noun_training_sets.where(
        :training_set_id => @set.id, 
        :noun_id => previous_word.id
      ).first
      previous_ts.score += if params['correct_answer'] then 1 else -2 end
      previous_ts.save!
    end

    respond_to do |format|
      format.json do
        ts = rand_word
        word   = ts.noun
        word_json = word.as_json
        # TODO fix score
        #word_json.merge!({ :score => word.noun_training_sets[0].score })
        word_json.merge!({ :score => ts.score })
        render :json => word_json, :layout => false
      end
    end

  end

  private

  def all_training_set_nouns
    @set.noun_training_sets(:include => :nouns)
  end


  def rand_word
    # Use a normal distribution to select the sample
    # set size
    limit = self.class.gauss_rand(5, 5, :min => 8).round
    words = @set.noun_training_sets.order('score ASC').limit(limit).all

    # Use a uniform distribution to select the word from that
    words[rand(words.size)]

  end

  # Box Mueller Method Of Gaussian Random number generation
  def self.gauss_rand(mu, sigma, options = {})
    u1 = rand
    u2 = rand
    z1 = Math.sqrt(-2 * Math.log(u1)) * Math.sin(2 * Math::PI * u2);
    x1 = mu + z1 * sigma;

    if options[:min]
      x1 = [options[:min], x1].max
    end

    if options[:max]
      x1 = [options[:max], x1].min
    end

    x1

  end
  
end

class Array
  def random_weighted
    s = self.sort do |a,b|
      (yield a) <=> (yield b)
    end

    total = s.map do |i|
        yield i
    end.sum
    
    running_total = 0
    index = rand(total) + 1

    # TODO this is slow. Need a binary sort
    # we assume it is already sorted in descending order, although I suppose order does not matter
    s.each do |item|
      running_total += yield item
      return item if index <= running_total
    end
    
    # it is possible to arrive here if all the elements had weight of zero.  Handle this:
    return self[rand(s.size)]
  end
end

