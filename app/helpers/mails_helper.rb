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
end
