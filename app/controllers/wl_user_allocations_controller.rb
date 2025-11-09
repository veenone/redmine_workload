# frozen_string_literal: true

class WlUserAllocationsController < ApplicationController
  include RedmineWorkload::WlUserDataFinder

  helper :workloads

  before_action :authorize_global, only: %i[create update destroy bulk_update]
  before_action :find_user_workload_data
  before_action :set_date_range, only: %i[index new edit]

  def index
    @is_allowed = User.current.allowed_to_globally?(:edit_user_allocations)
    @user = params[:user_id] ? User.find(params[:user_id]) : User.current

    # Only allow users to view their own allocations unless they have admin rights
    unless @user.id == User.current.id || User.current.admin?
      render_403
      return
    end

    @wl_user_allocations = WlUserAllocation.for_user_in_range(@user, @date_range)
    @allocations_by_date = @wl_user_allocations.index_by(&:allocation_date)
  end

  def new
    @user = User.current
  end

  def edit
    @wl_user_allocation = WlUserAllocation.find(params[:id])

    # Only allow users to edit their own allocations unless they have admin rights
    unless @wl_user_allocation.user_id == User.current.id || User.current.admin?
      render_403
      return
    end
  end

  def create
    @wl_user_allocation = WlUserAllocation.new(wl_user_allocation_params)
    @wl_user_allocation.user_id = User.current.id

    respond_to do |format|
      if @wl_user_allocation.save
        format.html do
          flash[:notice] = l(:notice_user_allocation_saved)
          redirect_to action: 'index'
        end
        format.json { render json: @wl_user_allocation, status: :created }
      else
        format.html { render action: 'new' }
        format.json { render json: @wl_user_allocation.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @wl_user_allocation = WlUserAllocation.find(params[:id])

    # Only allow users to update their own allocations unless they have admin rights
    unless @wl_user_allocation.user_id == User.current.id || User.current.admin?
      render_403
      return
    end

    respond_to do |format|
      if @wl_user_allocation.update(wl_user_allocation_params)
        format.html do
          flash[:notice] = l(:notice_user_allocation_saved)
          redirect_to action: 'index'
        end
        format.json { render json: @wl_user_allocation }
      else
        format.html { render action: 'edit' }
        format.json { render json: @wl_user_allocation.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @wl_user_allocation = WlUserAllocation.find(params[:id])

    # Only allow users to delete their own allocations unless they have admin rights
    unless @wl_user_allocation.user_id == User.current.id || User.current.admin?
      render_403
      return
    end

    @wl_user_allocation.destroy
    respond_to do |format|
      format.html do
        flash[:notice] = l(:notice_user_allocation_deleted)
        redirect_to action: 'index'
      end
      format.json { head :no_content }
    end
  end

  # Bulk update allocations for multiple days
  def bulk_update
    user_id = params[:user_id] || User.current.id

    # Only allow users to update their own allocations unless they have admin rights
    unless user_id.to_i == User.current.id || User.current.admin?
      render_403
      return
    end

    user = User.find(user_id)
    allocations = params[:allocations] || {}

    errors = []

    ActiveRecord::Base.transaction do
      allocations.each do |date_str, hours|
        next if hours.blank? || hours.to_f == 0

        begin
          date = Date.parse(date_str)
          allocation = WlUserAllocation.find_or_initialize_by(user_id: user.id, allocation_date: date)
          allocation.hours = hours.to_f

          unless allocation.save
            errors << "#{date}: #{allocation.errors.full_messages.join(', ')}"
          end
        rescue ArgumentError => e
          errors << "Invalid date: #{date_str}"
        end
      end

      # Delete allocations with zero hours
      WlUserAllocation.where(user_id: user.id, hours: 0).destroy_all
    end

    respond_to do |format|
      if errors.empty?
        format.html do
          flash[:notice] = l(:notice_user_allocations_saved)
          redirect_to action: 'index', user_id: user.id
        end
        format.json { render json: { success: true }, status: :ok }
      else
        format.html do
          flash[:error] = errors.join('<br/>').html_safe
          redirect_to action: 'index', user_id: user.id
        end
        format.json { render json: { errors: errors }, status: :unprocessable_entity }
      end
    end
  end

  private

  def wl_user_allocation_params
    params.require(:wl_user_allocation).permit(:user_id, :allocation_date, :hours, :description)
  end

  def set_date_range
    today = Date.today
    @first_day = params[:first_day] ? Date.parse(params[:first_day]) : today - 10
    @last_day = params[:last_day] ? Date.parse(params[:last_day]) : today + 50
    @date_range = @first_day..@last_day
  rescue ArgumentError
    @first_day = today - 10
    @last_day = today + 50
    @date_range = @first_day..@last_day
  end
end
