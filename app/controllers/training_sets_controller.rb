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

  def random_word

    respond_to do |format|
        
      if params[:word]
        @word = {:word => params[:word]}
      else @word = params[:word]
        @word = rand_word
      end

      format.html do
        render :index
      end

      format.json do
        puts @word.to_json
        render :json => @word, :layout => false
      end
    end

  end

  private

  def all_words
    # TODO.  This should go into memcache and be flushed
    # on update
    @set = TrainingSet.find(params[:id])
    @set.nouns(current_user)
  end

  def rand_word
    words = all_words
    words[rand(words.size)]
  end
end
