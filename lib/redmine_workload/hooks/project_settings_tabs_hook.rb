# frozen_string_literal: true

module RedmineWorkload
  module Hooks
    class ProjectSettingsTabsHook < Redmine::Hook::ViewListener
      def view_projects_settings_members_table_header(context = {})
        # This hook allows us to add content to project settings
        ''
      end

      # Add workload settings tab to project settings
      def view_project_settings_tabs(context = {})
        project = context[:project]
        controller = context[:controller]
        
        # Only show tab if workload module is enabled and user has permission
        return '' unless project&.module_enabled?(:workload)
        return '' unless Setting.plugin_redmine_workload['menu_scope'] == 'project'
        return '' unless User.current.allowed_to?(:manage_project_workload_settings, project)
        
        # Add workload tab to the tabs array
        tabs = controller.instance_variable_get(:@tabs) || []
        
        workload_tab = {
          name: 'workload',
          action: :manage_project_workload_settings,
          partial: 'wl_project_settings/tab',
          label: :label_workload_settings
        }
        
        tabs << workload_tab
        controller.instance_variable_set(:@tabs, tabs)
        
        ''
      end
    end
  end
end