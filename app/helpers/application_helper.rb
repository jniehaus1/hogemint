module ApplicationHelper
  def item_index_link
    ENV["PRINTER_IS_LIVE"] == "true" ? items_url : test_items_url
  end
end
