class Mailbox < ApplicationRecord
  has_many :tokens
  belongs_to :created_by, class_name: 'User', foreign_key: :created_by_id

  has_attached_file :cover_photo, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: "/images/:style/missing.png"
  validates_attachment_content_type :cover_photo, content_type: /\Aimage\/.*\Z/

  validates :name, presence: true, uniqueness: true
end
