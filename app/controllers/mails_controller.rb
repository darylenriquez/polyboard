# TODO: Implement ajax for speed
class MailsController < ApplicationController
  before_filter :set_token_and_gmail

  # TODO: Merge this with show
  def search
    @selected_item  = {messages: [], headers: nil, labels: []}

    @result = @gmail.list_user_messages('me', q: params[:search])
    @items  = {}

    @gmail.batch do |g|
      unless params[:thread_id].blank?
        g.get_user_message('me', params[:thread_id]) do | message, res |
          @selected_item[:headers] = message.payload.headers.inject({}){|r, h| r.merge(h.name => h.value)}
          @selected_item[:labels]  = message.label_ids

          @selected_item[:messages] = [message]
        end
      end

      @result.messages.each do |m|
        g.get_user_message('me', m.id, fields: "id,labelIds,payload/headers,snippet") do | message, res |
          @items[m.id] = if message.blank?
            {} # Sometimes this happens
          else
            headers = message.payload.headers.inject({}){|r, h| r.merge(h.name => h.value)}

            { message_id: message.id, labels: message.label_ids, sender: headers["From"], snippet: message.snippet }
          end
        end
      end
    end
    
    render action: :show
  end

  def show
    @selected_item  = {messages: [], headers: nil, labels: []}
    @thread_result    = @gmail.list_user_threads('me')

    @threads  = @thread_result.threads
    @items    = {}

    @gmail.batch do |g|
      unless params[:thread_id].blank?
        g.get_user_thread('me', params[:thread_id]) do | threads, res |
          @selected_item[:messages] = threads.messages rescue []
        end

        g.get_user_message('me', params[:thread_id]) do | message, res |
          @selected_item[:headers] = message.payload.headers.inject({}){|r, h| r.merge(h.name => h.value)}
          @selected_item[:labels]  = message.label_ids
        end
      end

      @threads.each do |thread|
        g.get_user_message('me', thread.id, fields: "id,labelIds,payload/headers,snippet") do | message, res |
          @items[thread.id] = if message.blank?
            {} # Sometimes this happens
          else
            headers = message.payload.headers.inject({}){|r, h| r.merge(h.name => h.value)}

            { message_id: message.id, labels: message.label_ids, sender: headers["From"], snippet: thread.snippet }
          end
        end
      end
    end
  end
  
  def compose
  end
  
  def send_message
    composed_mail = mail_from_params(mail_params)
    sent_message  = @gmail.send_user_message('me', upload_source: StringIO.new(composed_mail.to_s), content_type: 'message/rfc822')

    if sent_message.label_ids.blank?
      redirect_to request.referer
    else
      redirect_to action: :search, search: "label:sent", mailbox_id: params[:mailbox_id], id: @token.id, thread_id: sent_message.id
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

    # redirect_to action: :show, thread_id: mail_params[:thread_id], mailbox_id: params[:mailbox_id], id: @token.id
    redirect_to request.referer
  end
  
  def download
    file = @gmail.get_user_message_attachment("me", params[:m_id], params[:f_id])

    stream = file.data
    send_data(stream, :type=>"text/csv", :filename => "#{Time.current.to_i}_#{params[:filename]}")
  end

  private # ======================================================
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
