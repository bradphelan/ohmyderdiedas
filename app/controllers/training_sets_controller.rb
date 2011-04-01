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

  
end

