class Comment < ApplicationRecord
  belongs_to :ticket

  ROLES = %w[customer agent].freeze

  validates :author_name, presence: true
  validates :author_role, presence: true, inclusion: { in: ROLES }
  validates :body, presence: true

  scope :chronological, -> { order(created_at: :asc) }
  scope :public_messages, -> { where(internal_note: false) }
  scope :internal_notes, -> { where(internal_note: true) }

  def customer?
    author_role == "customer"
  end

  def agent?
    author_role == "agent"
  end
end
