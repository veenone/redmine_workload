# frozen_string_literal: true

module RedmineWorkload
  module Hooks
    class IssueNotificationHook < Redmine::Hook::Listener
      
      # Hook after issue creation to notify about workload impact
      def controller_issues_new_after_save(context = {})
        issue = context[:issue]
        return unless issue&.persisted?
        return unless workload_relevant?(issue)

        notify_workload_affected_users(issue, :created)
      end

      # Hook after issue update to notify about workload changes
      def controller_issues_edit_after_save(context = {})
        issue = context[:issue]
        return unless issue&.persisted?
        return unless workload_relevant?(issue)

        # Check if workload-relevant fields were changed
        if workload_fields_changed?(issue)
          notify_workload_affected_users(issue, :updated)
        end
      end

      private

      # Check if issue is relevant for workload calculations
      def workload_relevant?(issue)
        issue.assigned_to.present? && 
        issue.estimated_hours.present? && 
        issue.start_date.present? && 
        issue.due_date.present? &&
        !issue.closed?
      end

      # Check if workload-relevant fields were changed
      def workload_fields_changed?(issue)
        workload_fields = [:assigned_to_id, :estimated_hours, :start_date, :due_date, :status_id]
        workload_fields.any? { |field| issue.saved_change_to_attribute?(field) }
      end

      # Notify users affected by workload changes
      def notify_workload_affected_users(issue, action)
        return unless Setting.plugin_redmine_workload['enable_workload_notifications'] == 'checked'

        # Get affected users
        affected_users = get_affected_users(issue)
        
        affected_users.each do |user|
          next unless user.mail_notification_enabled?
          
          begin
            WorkloadMailer.workload_issue_notification(user, issue, action).deliver_later
          rescue => e
            Rails.logger.error "Failed to send workload notification: #{e.message}"
          end
        end
      end

      # Get users who should be notified about workload changes
      def get_affected_users(issue)
        users = []
        
        # Always notify the assigned user
        users << issue.assigned_to if issue.assigned_to.is_a?(User)
        
        # Notify group members if assigned to a group
        if issue.assigned_to.is_a?(Group)
          users.concat(issue.assigned_to.users.active)
        end
        
        # Notify project managers if they have workload view permissions
        project_managers = issue.project.users.joins(:members)
                               .where(members: { project_id: issue.project.id })
                               .where('members.id IN (?)', 
                                      Member.joins(:roles)
                                            .where(project_id: issue.project.id)
                                            .where(roles: { name: 'Manager' })
                                            .pluck(:id))
        
        users.concat(project_managers.to_a)
        
        # Remove duplicates and ensure users have workload permissions
        users.uniq.select do |user|
          user.allowed_to?(:view_all_workloads, nil, global: true) ||
          user.allowed_to?(:view_own_workloads, nil, global: true) ||
          user.allowed_to?(:view_project_workloads, issue.project)
        end
      end
    end
  end
end