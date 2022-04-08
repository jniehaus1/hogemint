class BasicController < ApplicationController
  def main
    @item = Item.new
  end
end
