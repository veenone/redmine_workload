# frozen_string_literal: true

##
# Presenter organising users to be used in views/workloads/_filers.erb.
#
class WlUserSelection
  attr_reader :groups

  ##
  # @param users [Array(User)] Selected user objects.
  # @param group_selection [WlGroupSelection] WlGroupSelection object.
  # @param user [User] A user object.
  # @param project [Project] A project object for project-scoped workloads.
  #
  # @note params[:user] is currently used for tests only!
  #
  def initialize(**params)
    self.users = params[:users] || []
    self.groups = params[:group_selection]
    self.selected_groups = groups&.selected
    self.user = define_user(params[:user])
    self.project = params[:project]
  end

  def all_selected
    selected_groups | selected
  end

  ##
  # Returns selected users when allowed to be viewed by the given user.
  #
  # @return [Array(User)] An array of user objects.
  def selected
    result = users_from_context & allowed_to_display
    return result unless result.empty?
    
    # If no specific users are selected, return default selection
    default_user_selection
  end

  ##
  # Prepares users to be used in filters
  # @return [Array(User)] An array of user objects.
  def allowed_to_display
    users_allowed_to_display.sort_by(&:lastname)
  end

  def all_user_ids
    all_users.map(&:id)
  end

  private

  attr_accessor :user, :users, :selected_groups, :project
  attr_writer :groups

  ##
  # Define the current user.
  #
  def define_user(user)
    user || User.current
  end

  ##
  # Returns the default user selection when no specific users are chosen.
  # This respects the "default_view_all_users" setting and user preferences.
  #
  def default_user_selection
    if project
      # Project context - check project permissions
      if (user.admin? || allowed_to?(:view_project_workloads)) && should_view_all_users?
        allowed_to_display
      else
        [user]
      end
    else
      # Global context - use existing logic
      if (user.admin? || allowed_to?(:view_all_workloads)) && should_view_all_users?
        allowed_to_display
      else
        [user]
      end
    end
  end

  ##
  # If groups are given the method will query those users having one of the given
  # groups as main group. If no groups are given the users_by_params will be
  # returned instead.
  #
  # @return [Array(User)] An array of user objects.
  #
  def users_from_context
    selected_users = users_of_groups | users_by_params
    return users_by_params if selected_groups.blank?

    selected_users.select do |user|
      selected_groups.map(&:id).include? user.main_group_id
    end
  end

  ##
  # Collects all users across all projects where the given user has the permission
  # to view the project workload.
  #
  # @param [User] An optional single user object. Default: User.current.
  # @return [Array(User)] Array of all users objects the current user may display.
  #
  def users_allowed_to_display
    if project
      # Project context - check project permissions
      return all_users if user.admin? || allowed_to?(:view_project_workloads)
      # For project context, fall back to current user only
      [user]
    else
      # Global context - use existing logic
      return all_users if user.admin? || allowed_to?(:view_all_workloads)

      result = group_members_allowed_to(:view_own_group_workloads)

      if result.blank?
        result = allowed_to?(:view_own_workloads) ? [user] : []
      end

      result.flatten.uniq
    end
  end

  def all_users
    all = User.joins(:groups).distinct
    return all.joins(:wl_user_data).active if selected_groups.present?

    all.active
  end

  ##
  # Get all active users of groups where the current user has a membership.
  #
  # @param permission [String|Symbol] Permission name.
  # @return [Array(User)] An array of user objects.
  #
  # @note user.groups does not return the user itself as group member!
  #
  def group_members_allowed_to(permission)
    return [] unless allowed_to?(permission)

    user.groups.map(&:users)
  end

  ##
  # Queries all active users as given by workload params.
  #
  # @return [Array(User)] An array of user objects.
  def users_by_params
    all_users.where(id: user_ids).to_a
  end

  ##
  # Collects all users belonging to selected groups if the user is still active.
  #
  # @return [Array(User)] An array of user objects.
  #
  def users_of_groups
    return [] if selected_groups.blank?

    result = selected_groups.map { |group| group.users.select(&:active?) }
    result.flatten!
    result.uniq
  end

  def user_ids
    users.map(&:to_i)
  end

  def allowed_to?(permission)
    if project
      user.allowed_to?(permission.to_sym, project)
    else
      user.allowed_to?(permission.to_sym, nil, global: true)
    end
  end

  def default_view_all_users?
    Setting.plugin_redmine_workload['default_view_all_users'] == 'checked'
  end

  def should_view_all_users?
    # Check user preference first, then fall back to global setting
    user_preference = user.pref[:workload_view_all_users]
    if user_preference.present?
      user_preference == 'true'
    else
      default_view_all_users?
    end
  end
end
