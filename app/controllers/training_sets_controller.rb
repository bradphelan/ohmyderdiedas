class TrainingSetsController < ApplicationController

  load_and_authorize_resource :message => "Unable to access training set."
  skip_authorize_resource :only => [:index, :new, :create]

  def index
  end

  before_filter :set_page
  def set_page
    @page = "page_sets_manage"
  end

  def new
  end

  def create
    @training_set.save!
    redirect_to edit_training_set_path(@training_set)
  end

  def edit
  end

  def update
    @training_set.name = params[:training_set][:name]
    @training_set.save!
    redirect_to edit_training_set_path
  end

  def words
    respond_to do |format|
      format.json do
        render :json => @training_set.nouns(current_user)
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
    # Update the score for the previous
    # word if it is available
=begin
    if params['word'] && params['gender']
      previous_word = Noun.where(:word=>params[:word], :gender=>params[:gender]).first
      previous_ts   = previous_word.noun_training_sets.where(
        :training_set_id => @training_set.id, 
        :noun_id => previous_word.id
      ).first
      previous_ts.score += if not params['error'] then 1 else -2 end
      previous_ts.save!
    end
=end

    size = params['number'].to_i
    respond_to do |format|
      format.json do
        ts = rand_words(size).map do |t|
          w = t.noun
          wj = w.as_json
          wj.merge!({ :id => t.id, :score => t.score, :error => false })
          wj
        end
        render :json => ts, :layout => false
      end
    end

  end

  private

  def all_training_set_nouns
    @training_set.noun_training_sets(:include => :nouns)
  end


  def rand_words number
    @training_set.noun_training_sets(:include => :nouns).order('score ASC').limit(number).all
  end

  def rand_word
    # Use a normal distribution to select the sample
    # set size
    limit = self.class.gauss_rand(5, 5, :min => 8).round
    words = @training_set.noun_training_sets.order('score ASC').limit(limit).all

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

