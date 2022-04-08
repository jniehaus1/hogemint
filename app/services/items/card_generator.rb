module Items
  class CardGenerator
    include ApplicationService

    def initialize(item)
      @item = item
    end

    def call
      im = Magick::Image.from_blob(@item.image.download)
      im = im[0].resize_to_fit(560,579) # Template size
      im_template = Magick::Image.read("data/pics/template_nasa.jpg")

      x_coord = ((560 - im.columns.to_i) / 2) + 94
      y_coord = ((579 - im.rows.to_i) / 2) + 211
      im3 = im_template[0].composite(im, x_coord, y_coord, Magick::OverCompositeOp)

      title = Magick::Draw.new

      title.annotate(im3, 469,51,98,70, serial_no) {
        self.font = 'data/fonts/Crashnumberinggothic-MAjp.ttf'
        self.fill = 'white'
        self.stroke = 'transparent'
        self.pointsize = 60
        self.font_weight = Magick::BoldWeight
        self.gravity = Magick::NorthWestGravity
      }

      t = Tempfile.new
      t.binmode
      t.write(im3.to_blob)
      t.rewind

      @item.meme_card.attach(io: t, filename: "#{@item.uri}.jpg", content_type: "image/jpeg")
    end

    private

    def serial_no
      num = @item.id.to_s
      num = num.rjust(8, '0')
      num[0..3] + "-" + num[4..7]
    end
  end
end
