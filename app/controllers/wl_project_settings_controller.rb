# frozen_string_literal: true

class WlProjectSettingsController < ApplicationController
  before_action :find_project
  before_action :authorize_settings

  def show
    @wl_project_setting = WlProjectSetting.for_project(@project)
    @trackers = Tracker.sorted.all
  end

  def update
    @wl_project_setting = WlProjectSetting.for_project(@project)

    if @wl_project_setting.update(project_setting_params)
      flash[:notice] = l(:notice_successful_update)
      redirect_to project_settings_path(@project, tab: 'workload')
    else
      @trackers = Tracker.sorted.all
      render :show
    end
  end

  private

  def find_project
    @project = Project.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def authorize_settings
    render_403 unless User.current.allowed_to?(:manage_project_workload_settings, @project) ||
                      User.current.admin?
  end

  def project_setting_params
    params.require(:wl_project_setting).permit(
      :group_filter_mode,
      filtered_group_ids: [],
      container_tracker_ids: []
    )
  end
end
