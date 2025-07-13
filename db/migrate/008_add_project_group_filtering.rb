# frozen_string_literal: true

class AddProjectGroupFiltering < ActiveRecord::Migration[6.1]
  def up
    # This migration is now obsolete as project group filtering
    # has been moved to project-level settings (see migration 009)
    # No action needed
  end

  def down
    # No action needed
  end
end