module MailboxesHelper
  def is_mailbox_present?
    @mailbox.present? && @mailbox.persisted?
  end
end
