class InboxesController < ApplicationController
  def show
    @token = Token.where(id: params[:id], token_type: params[:mailbox_id]).first
  end
end
