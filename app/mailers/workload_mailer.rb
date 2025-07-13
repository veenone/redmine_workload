# frozen_string_literal: true

class WorkloadMailer < Mailer
  
  # Send notification about workload-affecting issue changes
  def workload_issue_notification(user, issue, action)
    @issue = issue
    @action = action
    @user = user
    @project = issue.project
    @workload_url = workload_url_for_user(user, issue)
    
    redmine_headers 'Project' => @project.identifier,
                    'Issue-Id' => @issue.id,
                    'Issue-Author' => @issue.author.login
    redmine_headers 'Issue-Assignee' => @issue.assigned_to.login if @issue.assigned_to
    message_id @issue
    references @issue
    
    subject = case action
              when :created
                l(:mail_subject_workload_issue_created, 
                  project: @project.name, 
                  id: @issue.id, 
                  subject: @issue.subject)
              when :updated
                l(:mail_subject_workload_issue_updated, 
                  project: @project.name, 
                  id: @issue.id, 
                  subject: @issue.subject)
              else
                l(:mail_subject_workload_issue_changed, 
                  project: @project.name, 
                  id: @issue.id, 
                  subject: @issue.subject)
              end
    
    mail(to: user.mail, subject: subject)
  end
  
  private
  
  # Generate workload URL for the specific user and context
  def workload_url_for_user(user, issue)
    if Setting.plugin_redmine_workload['menu_scope'] == 'project'
      # Project-scoped workload URL
      url_for(controller: 'workloads', action: 'index', project_id: issue.project.identifier, only_path: false)
    else
      # Global workload URL
      url_for(controller: 'workloads', action: 'index', only_path: false)
    end
  end
end