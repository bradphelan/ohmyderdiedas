class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    can :manage, TrainingSet, :user_id => user.id

    can :manage, NounTrainingSet do |nts|
      nts.training_set.user_id == user.id
    end
  end
end
