# frozen_string_literal: true

require File.expand_path('redmine_workload/extensions/user_patch', __dir__)
require File.expand_path('redmine_workload/hooks/after_plugins_loaded_hook', __dir__)
require File.expand_path('redmine_workload/hooks/issue_notification_hook', __dir__)
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
    if ActiveRecord::Base.configurations.respond_to?(:configs_for)
      # Rails 6.1+
      config = ActiveRecord::Base.configurations.configs_for(env_name: Rails.env, name: 'primary')
      config&.adapter == 'postgresql'
    elsif ActiveRecord::Base.configurations.respond_to?(:default_hash)
      # Rails 6.0
      ActiveRecord::Base.configurations.default_hash(Rails.env)['adapter'] == 'postgresql'
    else
      # Rails 5.x and older
      ActiveRecord::Base.configurations[Rails.env]['adapter'] == 'postgresql'
    end
  end
end
