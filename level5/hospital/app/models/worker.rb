class Worker < ApplicationRecord
  has_many :shifts

  STATUSES = ["medic","interne","interim"]

  validates :first_name, presence: true, length: { maximum: 60 }, uniqueness: true
  validates :status, presence: true, length: { maximum: 60 }
  validate :is_valid_status?

  private
  def is_valid_status?
    unless STATUSES.include?(status)
      errors.add(:status, 'unknown status. Please pick one in the list')
    end
  end

end
