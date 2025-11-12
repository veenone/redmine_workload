# frozen_string_literal: true

module RedmineWorkload
  module Hooks
    class ProjectSettingsHook < Redmine::Hook::ViewListener
      def view_project_settings_tabs(context)
        project = context[:project]

        return unless User.current.allowed_to?(:manage_project_workload_settings, project) ||
                      User.current.admin?

        {
          name: 'workload',
          partial: 'wl_project_settings/settings_tab',
          label: :workload_title
        }
      end
    end
  end
end
