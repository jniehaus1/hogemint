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

  def processing_html(item)
    return nil if !item.processing

    return "<small>The image shown is a preview. The server is compiling your gif and it will be available in a short time.</small>".html_safe
  end
end
