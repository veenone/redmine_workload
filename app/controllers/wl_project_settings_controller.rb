# frozen_string_literal: true

class WlProjectSettingsController < ApplicationController
  before_action :find_project
  before_action :authorize

  def show
    @wl_project_setting = WlProjectSetting.for_project(@project)
    @groups = Group.givable.order(:lastname)
  end

  def update
    @wl_project_setting = WlProjectSetting.for_project(@project)
    @groups = Group.givable.order(:lastname)

    if @wl_project_setting.update(project_setting_params)
      flash[:notice] = l(:notice_settings_updated)
      redirect_to project_wl_project_setting_path(@project)
    else
      flash.now[:error] = l(:error_settings_update_failed)
      render :show
    end
  end

  private

  def find_project
    @project = Project.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def authorize
    unless User.current.allowed_to?(:manage_project_workload_settings, @project)
      deny_access
    end
  end

  def project_setting_params
    params.require(:wl_project_setting).permit(:group_filter_mode, filtered_group_ids: [])
  end
end