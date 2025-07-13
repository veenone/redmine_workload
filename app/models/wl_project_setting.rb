# frozen_string_literal: true

##
# Model for storing project-specific workload settings
#
class WlProjectSetting < ActiveRecord::Base
  belongs_to :project

  validates :project_id, presence: true, uniqueness: true
  validates :group_filter_mode, inclusion: { in: %w[all include exclude] }

  serialize :filtered_group_ids, type: Array

  def self.for_project(project)
    find_or_create_by(project: project) do |setting|
      setting.group_filter_mode = 'all'
      setting.filtered_group_ids = []
    end
  end

  def filtered_groups
    return Group.none if group_filter_mode == 'all' || filtered_group_ids.blank?

    Group.where(id: filtered_group_ids)
  end

  def should_filter_groups?
    group_filter_mode != 'all' && filtered_group_ids.present?
  end
end