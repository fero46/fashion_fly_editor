module FashionFlyEditor
  class Subscription < ActiveRecord::Base
    belongs_to :collection
    belongs_to :subscriber, :polymorphic => true
  end
end
