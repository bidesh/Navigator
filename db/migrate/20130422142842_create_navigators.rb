class CreateNavigators < ActiveRecord::Migration
  def change
    create_table :navigators do |t|

      t.timestamps
    end
  end
end
