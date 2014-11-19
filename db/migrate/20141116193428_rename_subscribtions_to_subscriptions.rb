class RenameSubscribtionsToSubscriptions < ActiveRecord::Migration
  def up
    rename_table :fashion_fly_editor_subscribtions, :fashion_fly_editor_subscriptions
  end

  def down
    rename_table :fashion_fly_editor_subscriptions, :fashion_fly_editor_subscribtions
  end
end
