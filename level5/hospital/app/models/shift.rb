class Shift < ApplicationRecord
  belongs_to :worker

  validates :worker_id, presence: true
  validates :start_date, presence: true, uniqueness: { message: "Cannot create several shifts on the same date." }
  validate :is_valid_date?

  private
  def is_valid_date?
    unless start_date.is_a?(Date)
      errors.add(:start_date, 'Wrong date format')
    end
  end


end
