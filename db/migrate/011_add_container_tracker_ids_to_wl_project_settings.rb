# frozen_string_literal: true

class AddContainerTrackerIdsToWlProjectSettings < ActiveRecord::Migration[5.2]
  def up
    add_column :wl_project_settings, :container_tracker_ids, :text, if_not_exists: true
  end

  def down
    remove_column :wl_project_settings, :container_tracker_ids, if_exists: true
  end
end
