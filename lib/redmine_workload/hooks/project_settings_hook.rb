# frozen_string_literal: true

module RedmineWorkload
  module Hooks
    class ProjectSettingsHook < Redmine::Hook::ViewListener
      def view_projects_settings_members_table_header(context = {})
        return '' unless context[:project]
        
        project = context[:project]
        
        # Only show for users with permission and when workload plugin is enabled for project
        return '' unless User.current.allowed_to?(:manage_project_workload_settings, project)
        return '' unless project.module_enabled?(:workload)
        return '' unless Setting.plugin_redmine_workload['menu_scope'] == 'project'
        
        content_tag(:div, class: 'contextual') do
          link_to(l(:label_workload_project_settings), 
                  project_wl_project_setting_path(project),
                  class: 'icon icon-settings')
        end
      end
    end
  end
end