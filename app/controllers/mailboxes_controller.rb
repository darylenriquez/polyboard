class MailboxesController < ApplicationController
  before_action :authenticate_user!
  before_filter :find_mailbox, only: [:edit, :show, :update]
  before_filter :build_mailbox, only: [:new, :create]

  def index
    @mailboxes = Mailbox.all
  end
  
  def new
  end
  
  def create
    if @mailbox.valid?
      @mailbox.save!

      redirect_to @mailbox
    else
      render :new
    end
  end

  def show
  end
  
  def edit
  end
  
  def update
    @mailbox.name = mailbox_params[:name]
    @mailbox.description = mailbox_params[:description]
    @mailbox.cover_photo = mailbox_params[:cover_photo] unless mailbox_params[:cover_photo].blank?

    if @mailbox.valid?
      @mailbox.save!

      redirect_to @mailbox
    else
      render :edit
    end
  end
  
  private
  def mailbox_params
    params.require(:mailbox).permit(:name, :cover_photo, :description) rescue {}
  end
  
  def find_mailbox
    @mailbox = Mailbox.find(params[:id])
  end
  
  def build_mailbox
    @mailbox = Mailbox.new(mailbox_params.merge(created_by_id: current_user.id))
  end
end
