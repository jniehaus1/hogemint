module ApplicationHelper
  def item_index_link
    ENV["PRINTER_IS_LIVE"] == "true" ? items_url : test_items_url
  end

  def meme_image_url(item)
    return "" unless item.meme_card.present?
    return fix_s3_link(item.meme_card)
  end

  def fix_s3_link(attachment)
    return nil unless attachment.present?
    attachment.url.sub("//","").gsub("#{ENV["AWS_S3_BUCKET"]}/","")
  end
end
