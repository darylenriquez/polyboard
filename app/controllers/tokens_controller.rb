class TokensController < ApplicationController
  before_filter :set_mailbox

  def create
    @auth   = request.env['omniauth.auth']['credentials']
    @info   = request.env['omniauth.auth']['info']
    @token  = Token.find_or_initialize_by(email: @info['email'])
    @origin = request.env["omniauth.origin"]

    if @auth['token'].present?
      refresh_token = @auth['refresh_token'] || @auth['token']
      origin_uri    = URI.parse(@origin)
      origin_params = Rails.application.routes.recognize_path(origin_uri.path)

      if @token.persisted? && @token.mailbox_id.present? && @token.mailbox_id.to_s != origin_params[:id]
        # TODO: Add message about failure
        flash[:notice] = "Email is already connected to other mailbox: #{@token.mailbox.try(:name)}"
      else
        @token.access_token   = @auth['token']
        @token.refresh_token  = refresh_token
        @token.token_type     = Token::GOOGLE_TOKEN
        @token.expires_at     = Time.at(@auth['expires_at']).to_datetime
        @token.user_id        = current_user.id
        @token.mailbox_id     = origin_params[:id]

        @token.save!
      end
    end
    
    

    redirect_to controller: :mailboxes, action: :show, id: origin_params[:id]
  end

  def update
  end
  
  private
  def set_mailbox
    
  end
end