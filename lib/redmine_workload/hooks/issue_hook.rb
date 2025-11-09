# frozen_string_literal: true

module RedmineWorkload
  module Hooks
    class IssueHook < Redmine::Hook::ViewListener
      # Add link to manage issue allocations in issue sidebar
      def view_issues_show_details_bottom(context = {})
        issue = context[:issue]
        return '' unless issue

        # Check if user can manage allocations for this issue
        return '' unless User.current.allowed_to_globally?(:manage_issue_allocations) ||
                        User.current.allowed_to?(:manage_issue_allocations, issue.project) ||
                        User.current.admin?

        link = context[:hook_caller].link_to(
          context[:hook_caller].l(:workload_issue_allocation_menu),
          { controller: 'wl_issue_allocations', action: 'index', issue_id: issue.id },
          class: 'icon icon-time'
        )

        content_tag(:p, link).html_safe
      end

      private

      def content_tag(name, content, options = {})
        "<#{name}#{options.map { |k, v| " #{k}=\"#{v}\"" }.join}>#{content}</#{name}>"
      end
    end
  end
end
