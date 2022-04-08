module ApplicationHelper
  def item_index_link
    ENV["PRINTER_IS_LIVE"] == "true" ? items_url : test_items_url
  end

  def fix_s3_link(attachment)
    return nil unless attachment.present?
    attachment.url.sub("//","").gsub("#{ENV["AWS_S3_BUCKET"]}/","")
  end
end
