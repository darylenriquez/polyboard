class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    @mailboxes = Mailbox.includes(:tokens)
  end
end
