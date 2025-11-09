# frozen_string_literal: true

class WlIssueAllocationsController < ApplicationController
  before_action :find_issue
  before_action :authorize_manage_allocations
  before_action :set_date_range, only: %i[index]

  def index
    @wl_issue_allocations = WlIssueAllocation.for_issue_in_range(@issue, @date_range)
    @allocations_by_date = @wl_issue_allocations.index_by(&:allocation_date)
    @estimated_remaining = calculate_estimated_remaining(@issue)

    # Group dates by week for horizontal display
    @weeks = group_dates_by_week(@date_range)
  end

  def bulk_update
    allocations = params[:allocations] || {}
    errors = []

    begin
      WlIssueAllocation.bulk_upsert(@issue, allocations, User.current)

      flash[:notice] = l(:notice_issue_allocations_saved)
      redirect_to action: 'index', issue_id: @issue.id
    rescue ActiveRecord::RecordInvalid => e
      flash[:error] = e.message
      redirect_to action: 'index', issue_id: @issue.id
    end
  end

  def destroy
    @wl_issue_allocation = WlIssueAllocation.find(params[:id])

    unless can_manage_issue_allocations?(@issue)
      render_403
      return
    end

    @wl_issue_allocation.destroy
    respond_to do |format|
      format.html do
        flash[:notice] = l(:notice_issue_allocation_deleted)
        redirect_to action: 'index', issue_id: @issue.id
      end
      format.json { head :no_content }
    end
  end

  # Reset allocations back to automatic distribution
  def reset
    WlIssueAllocation.where(issue_id: @issue.id).destroy_all

    flash[:notice] = l(:notice_issue_allocations_reset)
    redirect_to action: 'index', issue_id: @issue.id
  end

  # Auto-distribute remaining hours across working days
  def auto_distribute
    unless @issue.start_date && @issue.due_date && @issue.estimated_hours
      flash[:error] = l(:error_issue_missing_dates_or_estimate)
      redirect_to action: 'index', issue_id: @issue.id
      return
    end

    # Check if issue is assigned
    unless @issue.assigned_to
      flash[:error] = l(:error_issue_not_assigned)
      redirect_to action: 'index', issue_id: @issue.id
      return
    end

    remaining_hours = calculate_estimated_remaining(@issue)
    date_range = [Date.today, @issue.start_date].max..@issue.due_date

    # Get working days for the assigned user
    working_days = RedmineWorkload::WlDateTools.working_days_in_time_span(
      date_range,
      @issue.assigned_to
    )

    if working_days.empty?
      flash[:error] = l(:error_no_working_days_in_range)
      redirect_to action: 'index', issue_id: @issue.id
      return
    end

    hours_per_day = remaining_hours / working_days.count.to_f
    allocations = {}

    working_days.each do |day|
      allocations[day.to_s] = hours_per_day.round(2)
    end

    begin
      WlIssueAllocation.bulk_upsert(@issue, allocations, User.current)
      flash[:notice] = l(:notice_issue_allocations_auto_distributed,
                         hours: remaining_hours.round(2),
                         days: working_days.count,
                         per_day: hours_per_day.round(2))
      redirect_to action: 'index', issue_id: @issue.id
    rescue ActiveRecord::RecordInvalid => e
      flash[:error] = e.message
      redirect_to action: 'index', issue_id: @issue.id
    end
  end

  private

  def find_issue
    @issue = Issue.find(params[:issue_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def authorize_manage_allocations
    unless can_manage_issue_allocations?(@issue)
      render_403
    end
  end

  def can_manage_issue_allocations?(issue)
    # Allow if user has manage_issue_allocations permission globally
    # or if they are a project manager/admin for this issue's project
    User.current.allowed_to_globally?(:manage_issue_allocations) ||
      User.current.allowed_to?(:manage_issue_allocations, issue.project) ||
      User.current.admin?
  end

  def set_date_range
    if @issue.start_date && @issue.due_date
      # Use issue dates as default range
      @first_day = params[:first_day] ? Date.parse(params[:first_day]) : [@issue.start_date, Date.today].min
      @last_day = params[:last_day] ? Date.parse(params[:last_day]) : @issue.due_date
    else
      # Fallback to a default range
      today = Date.today
      @first_day = params[:first_day] ? Date.parse(params[:first_day]) : today
      @last_day = params[:last_day] ? Date.parse(params[:last_day]) : today + 30
    end
    @date_range = @first_day..@last_day
  rescue ArgumentError
    today = Date.today
    @first_day = today
    @last_day = today + 30
    @date_range = @first_day..@last_day
  end

  def calculate_estimated_remaining(issue)
    return 0.0 unless issue.estimated_hours

    issue.estimated_hours * ((100.0 - issue.done_ratio) / 100.0)
  end

  def group_dates_by_week(date_range)
    weeks = []
    current_week = []
    current_week_number = nil

    date_range.each do |date|
      week_number = date.cweek
      year = date.cwyear

      # Start a new week if week number changes
      if current_week_number != [year, week_number]
        weeks << current_week unless current_week.empty?
        current_week = []
        current_week_number = [year, week_number]
      end

      current_week << date
    end

    # Add the last week
    weeks << current_week unless current_week.empty?

    weeks
  end
end
