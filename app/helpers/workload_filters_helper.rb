# frozen_string_literal: true

module WorkloadFiltersHelper
  def user_options_for_select(usersToShow, selectedUsers)
    result = ''
    return unless usersToShow

    usersToShow.each do |user|
      selected = selectedUsers.include?(user) ? 'selected="selected"' : ''

      result += "<option value=\"#{h(user.id)}\" #{selected}>#{h(user.name)}</option>"
    end

    result.html_safe
  end

  def group_options_for_select(groupsToShow, selectedGroups)
    result = ''
    return unless groupsToShow

    groupsToShow.each do |group|
      selected = selectedGroups.include?(group) ? 'selected="selected"' : ''

      result += "<option value=\"#{h(group&.id)}\" #{selected}>#{h(group.lastname)}</option>"
    end

    result.html_safe
  end

  def project_group_filtering_info
    return unless params[:project_id].present?
    
    project = Project.find_by(id: params[:project_id])
    return unless project
    
    setting = WlProjectSetting.for_project(project)
    return unless setting.should_filter_groups?
    
    group_names = setting.filtered_groups.pluck(:lastname)
    return if group_names.empty?
    
    case setting.group_filter_mode
    when 'include'
      content_tag(:div, class: 'flash notice') do
        content_tag(:strong, l(:label_group_filtering_active)) + ': ' +
        l(:text_including_groups, count: group_names.size, groups: group_names.join(', '))
      end
    when 'exclude'
      content_tag(:div, class: 'flash notice') do
        content_tag(:strong, l(:label_group_filtering_active)) + ': ' +
        l(:text_excluding_groups, count: group_names.size, groups: group_names.join(', '))
      end
    end
  end
end
