require 'net/http'
require 'multi_json'

class Token < ApplicationRecord
  belongs_to :mailbox
  belongs_to :user
  
  validate :email_should_be_in_one_mailbox

  GOOGLE_TOKEN = 1

  def to_params
    { refresh_token: refresh_token, client_id: ENV['CLIENT_ID'], client_secret: ENV['CLIENT_SECRET'], grant_type: "refresh_token" }
  end

  def request_token_from_google
    url = URI(GMAIL_TOKEN_URL)
    Net::HTTP.post_form(url, self.to_params)
  end

  def refresh!
    response = request_token_from_google
    data = JSON.parse(response.body)

    unless data['access_token'].nil?
      update_attributes({
        access_token: data['access_token'],
        expires_at: Time.now + (data['expires_in'].to_i).seconds
      })
    end
  end

  def expired?
    expires_at < Time.now
  end

  def fresh_token
    refresh! if expired?
    access_token
  end

  def as_credential
    Google::Auth::UserRefreshCredentials.new(to_options)
  end

  def as_client
    OAuth2::Client.new(ENV['CLIENT_ID'], ENV['CLIENT_SECRET'], to_options)
  end

  def to_options
    {
      client_id: ENV['CLIENT_ID'],
      client_secret: ENV['CLIENT_SECRET'],
      scope: "email",
      access_token: fresh_token,
      refresh_token: refresh_token,
      expires_at: expires_at
    }
  end
  
  private
  def email_should_be_in_one_mailbox
    errors.add(:email, "already managed in other mailbox") unless Token.where(email: email).where.not(mailbox_id: mailbox_id).count.zero?
  end
end