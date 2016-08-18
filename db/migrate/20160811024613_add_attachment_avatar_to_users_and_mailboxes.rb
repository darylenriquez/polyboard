class AddAttachmentAvatarToUsersAndMailboxes < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.attachment :avatar
    end

    change_table :mailboxes do |t|
      t.attachment :cover_photo
    end
  end

  def self.down
    remove_attachment :users, :avatar
    remove_attachment :mailboxes, :cover_photo
  end
end
