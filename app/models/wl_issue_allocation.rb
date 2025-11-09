# frozen_string_literal: true

class WlIssueAllocation < ActiveRecord::Base
  belongs_to :issue
  belongs_to :created_by, class_name: 'User', foreign_key: 'created_by_id'

  validates :issue_id, :allocation_date, :hours, :created_by_id, presence: true
  validates :allocation_date, date: true
  validates :hours, numericality: { greater_than_or_equal_to: 0 }
  validates :allocation_date, uniqueness: { scope: :issue_id, message: "already has an allocation for this issue" }
  validate :allocation_date_within_issue_range

  after_save :clearCache
  after_destroy :clearCache

  # Clear the workload cache when allocations change
  def clearCache
    Rails.cache.clear
  end

  # Get allocations for an issue within a date range
  def self.for_issue_in_range(issue, date_range)
    where(issue_id: issue.id, allocation_date: date_range)
      .order(:allocation_date)
  end

  # Get all allocations for an issue
  def self.for_issue(issue)
    where(issue_id: issue.id)
      .order(:allocation_date)
  end

  # Get allocation hours for a specific issue and date
  def self.hours_for(issue, date)
    find_by(issue_id: issue.id, allocation_date: date)&.hours || 0.0
  end

  # Check if an issue has manual allocations
  def self.has_allocations?(issue)
    where(issue_id: issue.id).exists?
  end

  # Bulk update or create allocations for an issue
  def self.bulk_upsert(issue, allocations_hash, created_by_user)
    transaction do
      allocations_hash.each do |date, hours|
        hours_float = hours.to_f

        allocation = find_or_initialize_by(issue_id: issue.id, allocation_date: date)

        if hours_float <= 0
          allocation.destroy if allocation.persisted?
        else
          allocation.hours = hours_float
          allocation.created_by_id = created_by_user.id
          allocation.save!
        end
      end
    end
  end

  # Delete allocations with zero hours
  def self.cleanup_zero_allocations
    where(hours: 0).destroy_all
  end

  # Calculate total allocated hours for an issue
  def self.total_hours_for_issue(issue)
    where(issue_id: issue.id).sum(:hours)
  end

  private

  # Validate that allocation date is within issue's start/end date range (if set)
  def allocation_date_within_issue_range
    return unless issue && allocation_date

    if issue.start_date && allocation_date < issue.start_date
      errors.add(:allocation_date, "cannot be before issue start date (#{issue.start_date})")
    end

    if issue.due_date && allocation_date > issue.due_date
      errors.add(:allocation_date, "cannot be after issue due date (#{issue.due_date})")
    end
  end
end
