# frozen_string_literal: true

require File.expand_path('redmine_workload/extensions/user_patch', __dir__)
require File.expand_path('redmine_workload/hooks/after_plugins_loaded_hook', __dir__)
require File.expand_path('redmine_workload/hooks/issue_hook', __dir__)
require File.expand_path('redmine_workload/hooks/project_settings_hook', __dir__)
require File.expand_path('redmine_workload/group_workload_preparer', __dir__)
require File.expand_path('redmine_workload/user_workload_preparer', __dir__)
require File.expand_path('redmine_workload/wl_calculation_restrictions', __dir__)
require File.expand_path('redmine_workload/wl_csv_exporter', __dir__)
require File.expand_path('redmine_workload/wl_date_tools', __dir__)
require File.expand_path('redmine_workload/wl_issue_query', __dir__)
require File.expand_path('redmine_workload/wl_issue_state', __dir__)
require File.expand_path('redmine_workload/wl_user_data_finder', __dir__)
require File.expand_path('redmine_workload/wl_user_data_defaults', __dir__)

# Simple Rails related methods
module RedmineWorkload
  # Check whether Redmine is running postgresql database
  def self.postgresql?
    # Rails 6.1+ uses DatabaseConfigurations object
    # Rails < 6.1 uses a simple hash
    if ActiveRecord::Base.configurations.respond_to?(:configs_for)
      # Rails 6.1+ API
      config = ActiveRecord::Base.configurations.configs_for(env_name: Rails.env).first
      config&.adapter == 'postgresql'
    else
      # Rails < 6.1 API
      ActiveRecord::Base.configurations[Rails.env]['adapter'] == 'postgresql'
    end
  rescue StandardError
    # Fallback: try using connection_db_config (available in Rails 6.1+)
    begin
      ActiveRecord::Base.connection_db_config.adapter == 'postgresql'
    rescue StandardError
      # Last resort: check connection adapter class
      ActiveRecord::Base.connection.adapter_name.downcase == 'postgresql'
    end
  end
end
