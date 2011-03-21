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
      noun = Noun.create_from_string(params['word'])
      if @training_set.nouns.where(:word => noun.word, :gender=>noun.gender).count > 0 
        raise "#{noun} has allready been added"
      else
        noun.training_sets.push @training_set
      end
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
    if params[:word] && params[:gender]
      previous_word = Noun.where(:word=>params[:word], :gender=>params[:gender]).first
      correct_answer = params.fetch :correct_answer, true
      score = if correct_answer then 1 else -2 end
      join = previous_word.noun_training_sets.where(:training_set_id => @set.id).first
      join.score = [[join.score + score, BOUNDARY].min, -BOUNDARY].max
      join.save!
    end

    respond_to do |format|
      format.json do
        render :json => rand_word, :layout => false
      end
    end

  end

  private

  def all_words
    Noun.includes(:noun_training_sets).where(NounTrainingSet.arel_table[:training_set_id].eq(@set.id))
  end

  def rand_word
    words = all_words
    words[rand(words.size)]
  end
end
