# frozen_string_literal: true

module RedmineWorkload
  module Patches
    module ProjectsHelperPatch
      def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
          alias_method :project_settings_tabs_without_workload, :project_settings_tabs
          alias_method :project_settings_tabs, :project_settings_tabs_with_workload
        end
      end

      module InstanceMethods
        def project_settings_tabs_with_workload
          tabs = project_settings_tabs_without_workload
          
          # Add workload settings tab if conditions are met
          if @project&.module_enabled?(:workload) &&
             Setting.plugin_redmine_workload['menu_scope'] == 'project' &&
             User.current.allowed_to?(:manage_project_workload_settings, @project)
            
            workload_tab = {
              name: 'workload',
              action: :manage_project_workload_settings,
              partial: 'wl_project_settings/tab',
              label: :label_workload_settings
            }
            
            tabs << workload_tab
          end
          
          tabs
        end
      end
    end
  end
end

# Apply the patch
unless ProjectsHelper.included_modules.include?(RedmineWorkload::Patches::ProjectsHelperPatch)
  ProjectsHelper.send(:include, RedmineWorkload::Patches::ProjectsHelperPatch)
end