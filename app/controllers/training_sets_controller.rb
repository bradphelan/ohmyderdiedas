class TrainingSetsController < ApplicationController
  def index
    @sets = TrainingSet.where :user_id => current_user.id
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
    redirect_to training_sets_path
  end
end
