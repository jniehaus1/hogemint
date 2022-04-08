module Vips
  class Compile
    def initialize(item)
      @item = item
    end

    def gif
      image_binary = Paperclip.io_adapters.for(@item.image).read
      meme_image = Vips::Image.new_from_buffer(image_binary, "")
      target_size = 466 # Take from template

      scale = [target_size.to_f / meme_image.width, target_size.to_f / meme_image.height].min
      meme_image = meme_image.resize(scale, kernel: :nearest) # resize to fit a inside target_size by target_size box
      rgba = meme_image.bandjoin(255)
      x_coord = ((451 - rgba.width) / 2) + 86
      y_coord = ((466 - rgba.height) / 2) + 188
      rgba_embed = rgba.embed(x_coord, y_coord, 625, 1000)

      gif = Vips::Image.new_from_file("data/pics/template_galaxy.gif", access: :sequential, n: -1)

      # image.height will be for all frames -- we want the height of one page. If
      # page-height is missing, default to image height
      page_height = if gif.get_typeof("page-height") != 0
                      gif.get("page-height")
                    else
                      gif.height
                    end

      # we now know the number of pages in the animation
      n_loaded_pages = gif.height / page_height
      pages = Array.new(n_loaded_pages - 1)
      n_loaded_pages.times do |i|
        pages[i] = gif.crop(0, i * page_height, gif.width, page_height)
      end

      overlay = rmagick_overlay

      pages = pages.map do |f|
        f = f.composite(rgba_embed, "over")
        f.composite(overlay, "over")
      end

      newgif = Vips::Image.arrayjoin(pages, { across: 1 })
      newgif.write_to_buffer ".gif", optimize_gif_frames: true, optimize_gif_transparency: true, format: "gif"
    end

    def preview
      image_binary = Paperclip.io_adapters.for(@item.image).read
      meme_image = Vips::Image.new_from_buffer(image_binary, "")
      target_size = meme_image.height > meme_image.width ? 466 : 451

      scale = [target_size.to_f / meme_image.width, target_size.to_f / meme_image.height].min
      meme_image = meme_image.resize(scale, kernel: :nearest) # resize to fit a inside target_size by target_size box
      rgba = meme_image.bandjoin(255)
      x_coord = ((451 - rgba.width) / 2) + 86
      y_coord = ((466 - rgba.height) / 2) + 188
      rgba_embed = rgba.embed(x_coord, y_coord, 625, 1000)

      gif = Vips::Image.new_from_file("data/pics/template_galaxy.gif", access: :sequential, n: -1)

      # image.height will be for all frames -- we want the height of one page. If
      # page-height is missing, default to image height
      page_height = if gif.get_typeof("page-height") != 0
                      gif.get("page-height")
                    else
                      gif.height
                    end

      page = gif.crop(0, 0, gif.width, page_height) # Grab first image of gif
      page = page.composite(rgba_embed, "over")      # Add picture
      page = page.composite(rmagick_overlay, "over") # Add text

      StringIO.new(page.write_to_buffer ".png")
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
      flavor_width  = 537
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
