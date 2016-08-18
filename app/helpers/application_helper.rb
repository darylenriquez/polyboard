module ApplicationHelper
  def nav_class(key)
    'is-active' if controller.controller_name.to_sym == key
  end

  def tab_class(key)
    'is-active' if controller.action_name.to_sym == key
  end
  
  def mailboxes
    Mailbox.pluck(:name, :id)
  end
  
  def select_emails(messages, exclude = [])
    exclude = [exclude] unless exclude.is_a?(Array)
    emails  = messages.inject("") do |message_emails, message|
      headers = headers_to_hash(message.payload.headers)
      message_emails + "#{headers['From']} #{headers['To']} #{headers['Cc']}"
    end

    emails.tr("<>","").split.select{|str| is_valid_email?(str) }.uniq.map(&:strip) - exclude
  end
  
  def is_valid_email?(str)
    (str =~ VALID_EMAIL_REGEX) != nil
  end

  def headers_to_hash(headers)
    headers.inject({}){|r, h| r.merge(h.name => h.value)}
  end
end
