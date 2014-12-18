class CreateScopes < ActiveRecord::Migration
  def change
    create_table :scopes do |t|

      t.timestamps
    end
  end
end
