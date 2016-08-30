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
  
  def form_parts(message)
    result = {}

    if message.payload.parts.blank?
      result.merge!(decode_parts(message.payload))
    else
      message.payload.parts.each { |part| result.merge!(decode_parts(part)) }
    end

    result.except!(:text) if result.key?(:text) && result.key?(:html)

    result
  end

  def decode_parts(part)
    headers = headers_to_hash(part.headers)
    
    if headers["Content-Type"].starts_with?("text/html")
      {html: part.body.data.force_encoding("utf-8")}
    elsif headers["Content-Type"].starts_with?("text/plain")
      {text: part.body.data.force_encoding("utf-8")}
    elsif headers["Content-Disposition"] && headers["Content-Disposition"].starts_with?("attachment")
      {file: {attachment_id: part.body.attachment_id, filename: part.filename}}
    else
      {}
    end
  end
end
