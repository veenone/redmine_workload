# frozen_string_literal: true

class AddViewAllUsersPreference < ActiveRecord::Migration[6.1]
  def up
    # Add user preference for default view all users setting
    # This will be stored in the user_preferences table automatically by Redmine
    # when users save their preferences
  end

  def down
    # No action needed as this uses Redmine's built-in user preferences system
  end
end