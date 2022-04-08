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
      title_width = 469
      title_height = 70
      title_x_offset = 98
      title_y_offset = 75

      text_container = Magick::Image.read("label:#{@item.title}") {
        self.font = 'Times-New-Roman'
        self.stroke = 'transparent'
        self.fill   = '#FAFAFA'
        self.background_color = 'transparent'
        self.size = "#{title_width}x#{title_height}"
      }.first

      im3.composite!(text_container, title_x_offset, title_y_offset, Magick::OverCompositeOp)

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
