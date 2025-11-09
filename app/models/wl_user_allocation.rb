class WlUserAllocation < ActiveRecord::Base
  unloadable

  belongs_to :user

  validates :user_id, :allocation_date, :hours, presence: true
  validates :allocation_date, date: true
  validates :hours, numericality: { greater_than_or_equal_to: 0 }
  validates :allocation_date, uniqueness: { scope: :user_id, message: "already has an allocation for this user" }

  after_save :clearCache
  after_destroy :clearCache

  # Clear the workload cache when allocations change
  def clearCache
    Rails.cache.clear
  end

  # Get allocations for a user within a date range
  def self.for_user_in_range(user, date_range)
    where(user_id: user.id, allocation_date: date_range)
      .order(:allocation_date)
  end

  # Get all allocations within a date range
  def self.in_range(date_range)
    where(allocation_date: date_range)
      .order(:allocation_date)
  end

  # Get allocation hours for a specific user and date
  def self.hours_for(user, date)
    find_by(user_id: user.id, allocation_date: date)&.hours || 0.0
  end

  # Bulk update or create allocations for a user
  def self.bulk_upsert(user, allocations_hash)
    allocations_hash.each do |date, hours|
      next if hours.to_f <= 0

      allocation = find_or_initialize_by(user_id: user.id, allocation_date: date)
      allocation.hours = hours.to_f
      allocation.save
    end
  end

  # Delete allocations with zero hours
  def self.cleanup_zero_allocations
    where(hours: 0).destroy_all
  end
end
