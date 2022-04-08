class StaticsController < ApplicationController
  def faq
    render "static/faq"
  end

  def guide
    render "static/guide"
  end
end
