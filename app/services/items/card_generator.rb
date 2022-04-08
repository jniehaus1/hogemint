module Items
  class CardGenerator
    include ApplicationService

    def initialize(item)
      @item = item
    end

    def call
      im = Magick::Image.from_blob(@item.image.download)
      im = im[0].resize_to_fit(548,566) # Template size
      im_template = Magick::Image.read("data/pics/template_nasa_neon.jpg")

      x_coord = ((548 - im.columns.to_i) / 2) + 100
      y_coord = ((566 - im.rows.to_i) / 2) + 218
      im3 = im_template[0].composite(im, x_coord, y_coord, Magick::OverCompositeOp)

      ##
      # nasa_neon_template
      # title text dimensions
      title_width = 469
      title_height = 70
      title_x_offset = 98
      title_y_offset = 75

      title_container = Magick::Image.read("label:#{@item.title}") {
        self.font = 'Times-New-Roman'
        self.stroke = 'transparent'
        self.fill   = '#FAFAFA'
        self.background_color = 'transparent'
        self.size = "#{title_width}x#{title_height}"
      }.first

      im3.composite!(title_container, title_x_offset, title_y_offset, Magick::OverCompositeOp)

      ##
      # flavor text dimensions
      flavor_width  = 537
      flavor_height = 251
      flavor_x_offset = 105
      flavor_y_offset = 856

      flavor_container = Magick::Image.read("caption:#{@item.flavor_text}") {
        self.font = 'Times-New-Roman'
        self.pointsize = 30
        self.stroke = 'transparent'
        self.fill   = '#FAFAFA'
        self.background_color = 'transparent'
        self.size = "#{flavor_width}x#{flavor_height}"
      }.first

      im3.composite!(flavor_container, flavor_x_offset, flavor_y_offset, Magick::OverCompositeOp)

      ##
      # URI
      uri_width = 537
      uri_height = 50
      uri_x_offset = 105
      uri_y_offset = 1040

      uri_container = Magick::Image.read("caption:#{@item.uri}") {
        self.font = 'Times-New-Roman'
        self.pointsize = 30
        self.stroke = 'transparent'
        self.fill   = '#FAFAFA'
        self.background_color = 'transparent'
        self.size = "#{uri_width}x#{uri_height}"
      }.first

      im3.composite!(uri_container, uri_x_offset, uri_y_offset, Magick::OverCompositeOp)

      ##
      # Serial Number

      no_width = 153
      no_height = 25
      no_x_offset = 488
      no_y_offset = 795

      no_container = Magick::Image.read("caption:#{serial_no}") {
        self.font = 'data/fonts/nasalization-rg.ttf'
        self.pointsize = 22
        self.stroke = 'transparent'
        self.fill   = '#FAFAFA'
        self.background_color = 'transparent'
        self.size = "#{no_width}x#{no_height}"
      }.first

      im3.composite!(no_container, no_x_offset, no_y_offset, Magick::OverCompositeOp)

      t = Tempfile.new
      t.binmode
      t.write(im3.to_blob)
      t.rewind

      @item.meme_card.attach(io: t, filename: "#{@item.uri}.png", content_type: "image/png")
    end

    private

    def serial_no
      num = @item.id.to_s
      num = num.rjust(8, '0')
      num[0..3] + "-" + num[4..7]
    end
  end
end
