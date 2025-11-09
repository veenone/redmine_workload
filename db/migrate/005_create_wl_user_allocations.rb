class CreateWlUserAllocations < ActiveRecord::Migration[5.2]
  def change
    create_table :wl_user_allocations do |t|
      t.references :user, null: false, foreign_key: true
      t.date :allocation_date, null: false
      t.float :hours, null: false, default: 0.0
      t.string :description
      t.timestamps
    end

    add_index :wl_user_allocations, [:user_id, :allocation_date], unique: true, name: 'index_wl_user_allocations_on_user_and_date'
  end
end
