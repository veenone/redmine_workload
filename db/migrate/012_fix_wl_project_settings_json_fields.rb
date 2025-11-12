# frozen_string_literal: true

class FixWlProjectSettingsJsonFields < ActiveRecord::Migration[5.2]
  def up
    # Update empty strings to NULL
    execute <<-SQL
      UPDATE wl_project_settings
      SET filtered_group_ids = NULL
      WHERE filtered_group_ids = '' OR filtered_group_ids IS NULL
    SQL

    execute <<-SQL
      UPDATE wl_project_settings
      SET container_tracker_ids = NULL
      WHERE container_tracker_ids = '' OR container_tracker_ids IS NULL
    SQL
  end

  def down
    # No need to revert
  end
end
