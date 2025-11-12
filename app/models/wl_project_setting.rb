# frozen_string_literal: true

class WlProjectSetting < ActiveRecord::Base
  belongs_to :project

  validates :project_id, presence: true, uniqueness: true

  # Serialize the filtered_group_ids as JSON array
  serialize :filtered_group_ids, type: Array, coder: JSON

  # Serialize container_tracker_ids as JSON array
  serialize :container_tracker_ids, type: Array, coder: JSON

  # Override getters to ensure arrays are returned
  def filtered_group_ids
    super || []
  end

  def container_tracker_ids
    super || []
  end

  # Get or create settings for a project
  def self.for_project(project)
    find_or_create_by(project_id: project.id) do |setting|
      setting.group_filter_mode = 'all'
      setting.filtered_group_ids = []
      setting.container_tracker_ids = []
    end
  end

  # Check if a tracker is configured as a container
  def container_tracker?(tracker_id)
    return false if container_tracker_ids.blank?
    container_tracker_ids.include?(tracker_id.to_i)
  end

  # Get list of container trackers
  def container_trackers
    return [] if container_tracker_ids.blank?
    Tracker.where(id: container_tracker_ids)
  end

  # Get list of task trackers (non-containers)
  def task_trackers
    container_ids = container_tracker_ids.presence || []
    Tracker.where.not(id: container_ids)
  end
end
