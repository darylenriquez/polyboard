module MailsHelper
  def label_class_name(labels)
    if labels.include?("IMPORTANT")
      "is-info"
    elsif labels.include?("SPAM")
      "is-danger"
    elsif labels.include?("UNREAD")
      "is-success"
    end
  end
  
  def is_current(thread_id)
    params[:thread_id] == thread_id
  end
  
  def path_params
    params.permit(:mailbox_id, :id, :thread_id, :search, :next_page_token, :label)
  end
  
  def formatted_date_ago(string_time)
    if time = string_time.to_time.in_time_zone rescue nil
      "#{time_ago_in_words(time)} (#{time.strftime('%B %d, %Y %I:%M:%S %p')})"
    end
  end

  def formatted_date(string_time)
    string_time.to_time.in_time_zone.strftime('%B %d, %Y %I:%M:%S %p') rescue nil
  end
end
