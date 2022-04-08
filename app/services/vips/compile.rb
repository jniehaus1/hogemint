module Vips
  class Compile
    def initialize(item)
      @item = item
    end

    def preview
      page = template.crop(0, 0, template.width, page_height)  # Grab first image of gif
      page = page.composite(resize_and_alpha, "over")          # Add picture
      page = page.composite(rmagick_overlay, "over")           # Add text

      StringIO.new(page.write_to_buffer ".png")
    end

    def gif
      pages = is_gif? ? from_animated_image : from_static_image

      newgif = Vips::Image.arrayjoin(pages, { across: 1 })
      StringIO.new(newgif.write_to_buffer ".gif", optimize_gif_frames: true, optimize_gif_transparency: true, format: "gif")
    end

    def from_static_image
      # Load template into separate pages
      n_loaded_pages = template.height / page_height
      pages = Array.new(n_loaded_pages)
      n_loaded_pages.times do |i|
        pages[i] = template.crop(0, i * page_height, template.width, page_height)
      end

      overlay = rmagick_overlay
      rgba_embed = resize_and_alpha

      pages.map do |f|
        f = f.composite(rgba_embed, "over")
        f.composite(overlay, "over")
      end
    end

    def from_animated_image
      # Load template into separate pages
      n_loaded_pages = template.height / page_height
      gif_pages = Array.new(n_loaded_pages)
      n_loaded_pages.times do |i|
        gif_pages[i] = template.crop(0, i * page_height, template.width, page_height)
      end

      overlay = rmagick_overlay
      upload_pages = resize_and_alpha_gif

      # Repeats the user uploaded gif as many times as possible before truncating non-matching frames
      factor    = gif_pages.count / upload_pages.count
      remainder = gif_pages.count % upload_pages.count

      k = 0
      factor.times do
        upload_pages.size.times do |j|
          gif_pages[k] = gif_pages[k].composite(upload_pages[j], "over")
          gif_pages[k] = gif_pages[k].composite(overlay, "over")
          k += 1
        end
      end

      remainder.times do |i|
        gif_pages[k] = gif_pages[k].composite(upload_pages[i], "over")
        gif_pages[k] = gif_pages[k].composite(overlay, "over")
        k += 1
      end

      return gif_pages
    end

    def resize_and_alpha
      meme_image = Vips::Image.new_from_buffer(image_binary, "")

      target_size = meme_image.height > meme_image.width ? 466 : 451
      scale = [target_size.to_f / meme_image.width, target_size.to_f / meme_image.height].min
      meme_image = meme_image.resize(scale, kernel: :cubic) # resize to fit a inside target_size by target_size box

      rgba = (meme_image.bands == 3) ? meme_image.bandjoin(255) : meme_image # Add alpha layer if 3 band image
      x_coord = ((451 - rgba.width) / 2) + 86
      y_coord = ((466 - rgba.height) / 2) + 188
      rgba.embed(x_coord, y_coord, 625, 1000)
    end

    def is_gif?
      @item.image_content_type == "image/gif"
    end

    def resize_and_alpha_gif
      meme_gif = Vips::Image.gifload_buffer(image_binary, access: :sequential, n: -1)
      page_height = meme_gif.get("page-height")
      num_pages = meme_gif.height / page_height

      target_size = page_height > meme_gif.width ? 466 : 451
      scale = [target_size.to_f / meme_gif.width, target_size.to_f / page_height].min

      pages = Array.new(num_pages)
      num_pages.times do |i|
        pages[i] = meme_gif.crop(0, i * page_height, meme_gif.width, page_height)
        pages[i] = pages[i].resize(scale, kernel: :cubic)
      end

      x_coord = ((451 - pages[0].width) / 2) + 86
      y_coord = ((466 - pages[0].height) / 2) + 188
      num_pages.times do |i|
        pages[i] = pages[i].embed(x_coord, y_coord, 625, 1000)
      end

      return pages
    end

    def image_binary
      Paperclip.io_adapters.for(@item.image).read
    end

    def page_height
      # image.height will be for all frames -- we want the height of one page. If
      # page-height is missing, default to image height
      @page_height ||= template.get_typeof("page-height") != 0 ? template.get("page-height") : template.height
    end

    def template
      @template ||= Vips::Image.new_from_file("data/pics/template_galaxy.gif", access: :sequential, n: -1)
    end

    def rmagick_overlay
      im3 = Magick::Image.new(625, 1000) { self.background_color = "transparent" }

      ##
      # Title Text
      title_width = 400
      title_height = 70
      title_x_offset = 98
      title_y_offset = 65

      title_container = Magick::Image.read("label:#{@item.title}") {
        self.font = 'data/fonts/times-new-roman.ttf'
        self.stroke = 'transparent'
        self.fill   = '#FAFAFA'
        self.background_color = 'transparent'
        self.size = "#{title_width}x#{title_height}"
        self.gravity = Magick::WestGravity
      }.first

      im3.composite!(title_container, title_x_offset, title_y_offset, Magick::OverCompositeOp)

      ##
      # flavor text dimensions
      flavor_width  = 500
      flavor_height = 251
      flavor_x_offset = 70
      flavor_y_offset = 710

      flavor_container = Magick::Image.read("caption:#{@item.flavor_text}") {
        self.font = 'data/fonts/times-new-roman.ttf'
        self.pointsize = 26
        self.stroke = 'transparent'
        self.fill   = '#FAFAFA'
        self.background_color = 'transparent'
        self.size = "#{flavor_width}x#{flavor_height}"
      }.first

      im3.composite!(flavor_container, flavor_x_offset, flavor_y_offset, Magick::OverCompositeOp)

      ##
      # URI
      uri_width = 520
      uri_height = 50
      uri_x_offset = 80
      uri_y_offset = 870

      uri_container = Magick::Image.read("caption:#{@item.uri}") {
        self.font = 'data/fonts/times-new-roman.ttf'
        self.pointsize = 26
        self.stroke = 'transparent'
        self.fill   = '#FAFAFA'
        self.background_color = 'transparent'
        self.size = "#{uri_width}x#{uri_height}"
      }.first

      im3.composite!(uri_container, uri_x_offset, uri_y_offset, Magick::OverCompositeOp)
      im3.format = "PNG"

      # Creates a file-like object that can be handled by Paperclip
      Vips::Image.new_from_buffer(im3.to_blob, "")
    end
  end
end
