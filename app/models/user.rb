class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :trackable

  has_many :created_mailboxes, class_name: 'Mailbox', foreign_key: :created_by_id
  has_many :tokens

  has_attached_file :avatar, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: "/images/:style/missing.png"
  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\Z/

  validates :username, presence: true, uniqueness: true
  validates :password, length: {minimum: 5, maximum: 120}, confirmation: true, presence: true, on: :create
  validates :password, length: {minimum: 5, maximum: 120}, confirmation: true, on: :update, allow_blank: true
end
