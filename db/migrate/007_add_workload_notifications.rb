# frozen_string_literal: true

class AddWorkloadNotifications < ActiveRecord::Migration[6.1]
  def up
    # Add workload notification settings to plugin settings
    # This will be stored in the settings table automatically by Redmine
    # when administrators configure the plugin
  end

  def down
    # No action needed as this uses Redmine's built-in settings system
  end
end