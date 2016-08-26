# TODO: Implement ajax for speed
class MailsController < ApplicationController
  before_filter :set_token_and_gmail

  def show
    @selected_item  = { messages: [], headers: nil, labels: [] }
    @items          = {}

    if !request.xhr? || (request.xhr? && (params[:target].blank? || params[:target] == 'APPEND_LIST'))
      @thread_result  = @gmail.list_user_threads('me', max_results: MAXIMUM_THREAD, page_token: params[:next_page_token], q: search_params)
      @threads        = @thread_result.threads || []

      unless @threads.length.zero?
        @gmail.batch do |g|
          retrieve_selected_message(g) unless params[:target] == 'APPEND_LIST'
          retrieve_threads_info(g)
        end
      end
    elsif request.xhr? && params[:target] == 'MESSAGE'
      retrieve_selected_message(@gmail)
    else
      raise ActionController::BadRequest
    end
  end
  
  def compose
  end
  
  def deliver
    composed_mail = mail_from_params(mail_params)
    sent_message  = @gmail.send_user_message('me', upload_source: StringIO.new(composed_mail.to_s), content_type: 'message/rfc822')

    if sent_message.label_ids.blank?
      redirect_to request.referer
    else
      redirect_to action: :show, label: "in:sent", mailbox_id: params[:mailbox_id], id: @token.id, thread_id: sent_message.thread_id
    end
  end

  # TODO: Check result before proceeding
  def update    
    composed_mail = mail_from_params(mail_params)
    encoded_mail  = Base64.encode64(composed_mail.to_s).tr('+', '-').tr('/', '_')

    url = URI(GMAIL_SEND_MAIL_URL)

    https = Net::HTTP.new(url.host, url.port)
    body  = { raw: encoded_mail, threadId: mail_params[:thread_id] }.to_json
    head  = { 'Content-Type' => 'application/json', access_token: @token.fresh_token }
    path  = "#{url.path}?access_token=#{@token.fresh_token}"

    https.use_ssl = true
    result = https.post("#{url.path}?access_token=#{@token.fresh_token}", body, head)

    
    if request.xhr?
      @selected_item  = { messages: [], headers: nil, labels: [] }
      retrieve_selected_message(@gmail)

      render action: :show
    else
      redirect_to request.referer
    end
  end
  
  def download
    file = @gmail.get_user_message_attachment("me", params[:m_id], params[:f_id])

    stream = file.data
    send_data(stream, :type=>"text/csv", :filename => "#{Time.current.to_i}_#{params[:filename]}")
  end

  private # ======================================================
  # TODO: validate params[:search]
  def search_params
    [params[:label], params[:search]].join(" ")
  end

  def retrieve_selected_message(gmail)
    unless params[:thread_id].blank?
      gmail.get_user_thread('me', params[:thread_id]) do | threads, res |
        @selected_item[:messages] = threads.messages rescue []
      end

      gmail.get_user_message('me', params[:thread_id]) do | message, res |
        @selected_item[:headers] = message.payload.headers.inject({}){|r, h| r.merge(h.name => h.value)}
        @selected_item[:labels]  = message.label_ids
      end
    end
  end

  def retrieve_threads_info(gmail)
    @threads.each do |thread|
      gmail.get_user_message('me', thread.id, fields: "id,labelIds,payload/headers,snippet") do | message, res |
        @items[thread.id] = if message.blank?
          {} # Sometimes this happens
        else
          headers = message.payload.headers.inject({}){|r, h| r.merge(h.name => h.value)}

          {
            message_id: message.id,
                labels: message.label_ids,
                sender: headers["From"],
               snippet: thread.snippet,
                  date: headers["Date"]
          }
        end
      end
    end
  end

  def mail_params
    params.require(:message).permit(:thread_id, :message, :message_id, :subject, :references, :to, files: []) rescue {}
  end

  def mail_from_params(values)
    mail = Mail.new

    mail[:from]  = @token.email
    mail[:to]    = values[:to]
    mail.subject = if values[:thread_id].blank?
      values[:subject]
    else
      values[:subject].starts_with?("Re:") ? values[:subject] : "Re:#{values[:subject]}"
    end

    unless values[:thread_id].blank?
      mail.header['References']   = "#{values[:references]} #{values[:message_id]}"
      mail.header['In-Reply-To']  = "#{values[:message_id]}"
    end
    
    mail.html_part do
      content_type "text/html; charset=\"UTF-8\""
      body "<div class='gmail_default'>#{values[:message]}</div>"
    end

    # File uploads
    values[:files].each{|file| mail.attachments[file.original_filename] = file.read } unless values[:files].blank?

    mail
  end
  
  def set_token_and_gmail
    @token = Token.find(params[:id])

    @gmail = Google::Apis::GmailV1::GmailService.new
    @gmail.authorization = @token.as_credential
  end
end
