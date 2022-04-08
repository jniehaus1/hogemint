class Admin::DashboardsController < ApplicationController
  before_action :authenticate_user!

  def dashboard
    @sales = Sale.all.order(id: :desc)
    render "admins/dashboard"
  end
end
