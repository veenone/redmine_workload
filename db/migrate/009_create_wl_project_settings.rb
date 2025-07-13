# frozen_string_literal: true

class CreateWlProjectSettings < ActiveRecord::Migration[6.1]
  def change
    create_table :wl_project_settings do |t|
      t.integer :project_id, null: false
      t.string :group_filter_mode, default: 'all', null: false
      t.text :filtered_group_ids
      t.timestamps null: false
    end

    add_index :wl_project_settings, :project_id, unique: true
    add_foreign_key :wl_project_settings, :projects
  end
end