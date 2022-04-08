class BaseItemsController < ApplicationController
  before_action :check_session_pw

  # I know it's bad, and I just don't care right now.
  # Will implement devise in the future.
  def login

  end

  def check_session_pw
    redirect_to login if session[:pw] != "sexy-beast"
  end
end
