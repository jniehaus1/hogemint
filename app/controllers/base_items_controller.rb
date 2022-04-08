class BaseItemsController < ApplicationController
  before_action :check_session_pw, except: [:new_session, :login]

  # I know it's bad, and I just don't care right now.
  # Will implement devise in the future.
  def login
    if params[:password] == ENV["SESSION_PW"]
      session[:pw] = "sexy-beast"
      redirect_to new_base_item_url
    else
      redirect_to "new_session"
    end
  end

  def new_session; end

  def new
    @base_item = BaseItem.new
  end

  def create; end

  def show; end

  def check_session_pw
    redirect_to :new_session if session[:pw] != "sexy-beast"
  end

  private

  def base_item_params
    params.require(:base_item).permit(:owner, :image)
  end
end
