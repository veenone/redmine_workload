# frozen_string_literal: true

class CreateWlIssueAllocations < ActiveRecord::Migration[5.2]
  def up
    create_table :wl_issue_allocations do |t|
      t.references :issue, type: :integer, null: false, foreign_key: true
      t.date :allocation_date, null: false
      t.float :hours, null: false, default: 0.0
      t.references :created_by, type: :integer, null: false
      t.timestamps
    end

    add_index :wl_issue_allocations, [:issue_id, :allocation_date], unique: true, name: 'index_wl_issue_allocations_on_issue_and_date'
  end

  def down
    remove_index :wl_issue_allocations, name: 'index_wl_issue_allocations_on_issue_and_date', if_exists: true if table_exists?(:wl_issue_allocations)
    drop_table :wl_issue_allocations, if_exists: true
  end
end
