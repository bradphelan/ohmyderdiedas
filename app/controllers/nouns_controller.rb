# encoding: UTF-8
#     training_set_nouns GET    /training_sets/:training_set_id/nouns(.:format)          {:action=>"index", :controller=>"nouns"}
#                        POST   /training_sets/:training_set_id/nouns(.:format)          {:action=>"create", :controller=>"nouns"}
#  new_training_set_word GET    /training_sets/:training_set_id/nouns/new(.:format)      {:action=>"new", :controller=>"nouns"}
# edit_training_set_word GET    /training_sets/:training_set_id/nouns/:id/edit(.:format) {:action=>"edit", :controller=>"nouns"}
#      training_set_word GET    /training_sets/:training_set_id/nouns/:id(.:format)      {:action=>"show", :controller=>"nouns"}
#                        PUT    /training_sets/:training_set_id/nouns/:id(.:format)      {:action=>"update", :controller=>"nouns"}
#                        DELETE /training_sets/:training_set_id/nouns/:id(.:format)      {:action=>"destroy", :controller=>"nouns"}
# 

class NounsController < ApplicationController
  
  # TODO Add in auth later
  #
  load_and_authorize_resource :training_set
  load_and_authorize_resource :noun_training_set, 
    :parent => false,
    :class => NounTrainingSet,
    :through => :training_set, 
    :except => [:index, :new, :create]

  def new
    begin
      noun = @training_set.create_noun_from_string params['word']
    rescue Exception => e
      Rails.logger.error e
      @error = e.to_s
    end

    if @error
      render :text => @error, :layout => false, :status => :unprocessable_entity
    else
      render :json => noun.to_json, :layout => false
    end
  end

  def update

    @noun_training_set.score = params[:score]
    @noun_training_set.save!

    render :json => make_json(@noun_training_set), :layout => false

  end

  def index
    ts = all_training_set_nouns.map do |t|
      make_json t
    end
    render :json => ts, :layout => false, :status => 200
  end

  private

  def make_json nts
      w = nts.noun
      wj = w.as_json
      wj.merge!({ :id => nts.id, :score => nts.score, :error => false })
  end

  def all_training_set_nouns
    @training_set.noun_training_sets(:include => :nouns).order('score ASC')
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
