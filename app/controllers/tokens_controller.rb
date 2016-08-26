class TokensController < ApplicationController
  before_action :authenticate_user!
  before_filter :set_mailbox

  def create
    origin_uri    = URI.parse(request.env["omniauth.origin"])
    origin_params = Rails.application.routes.recognize_path(origin_uri.path)

    if request.env['omniauth.auth'].blank?
      if request.env["omniauth.error.type"] && request.env["omniauth.error.type"] == :access_denied
        flash[:warning] = "Oh! you changed your mind."
      else
        flash[:error] = "An error occured! Please try again later"
      end
    else
      @auth   = request.env['omniauth.auth']['credentials']
      @info   = request.env['omniauth.auth']['info']
      @token  = Token.find_or_initialize_by(email: @info['email'])
    

      if @auth['token'].present?
        refresh_token = @auth['refresh_token']

        if @token.persisted? && @token.mailbox_id.present? && @token.mailbox_id.to_s != origin_params[:id]
          # TODO: Add message about failure
          flash[:warning] = "Email is already connected to other mailbox: #{@token.mailbox.try(:name)}"
        else
          if @token.refresh_token.blank? && refresh_token.blank?
            flash[:error] = "Unfortunately, we were not able to acquire the required information. We suggest that you revoke access of this app in gmail security page then try adding this account again"
          else
            @token.access_token   = @auth['token']
            @token.refresh_token  = refresh_token unless refresh_token.blank?
            @token.token_type     = Token::GOOGLE_TOKEN
            @token.expires_at     = Time.at(@auth['expires_at']).to_datetime
            @token.user_id        = current_user.id
            @token.mailbox_id     = origin_params[:id]

            @token.save!
          end
        end
      else
        flash[:error] = "An error occured! Cannot find token. Please try again later"
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