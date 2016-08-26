class Token < ApplicationRecord
  belongs_to :mailbox
  belongs_to :user

  validate :email_should_be_in_one_mailbox

  GOOGLE_TOKEN = 1

  def refresh!
    token_signet  = to_signet
    response_data = token_signet.fetch_access_token!

    unless response_data['access_token'].nil?
      data = { access_token: response_data['access_token'], expires_at: Time.now + (response_data['expires_in'].to_i).seconds}
      update_attributes(data)
    end
  end

  def expired?
    expires_at < Time.now
  end
  
  def to_signet
    client = Signet::OAuth2::Client.new(({token_credential_uri:  GMAIL_TOKEN_URL}).merge(to_options))
  end

  def to_options
    {
          client_id: ENV['CLIENT_ID'],
      client_secret: ENV['CLIENT_SECRET'],
              scope: "email",
       access_token: access_token,
      refresh_token: refresh_token,
         expires_at: expires_at
    }
  end
  
  private
  def email_should_be_in_one_mailbox
    errors.add(:email, "already managed in other mailbox") unless Token.where(email: email).where.not(mailbox_id: mailbox_id).count.zero?
  end
end