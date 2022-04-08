module Generations
  class Four
    MINT_ADDR = ENV["GEN_THREE_MINT_ADDRESS"].freeze

    def initialize(item:)
      @item = item
    end

    def generate_preview_card
      tmpfile = Tempfile.new
      tmpfile.binmode
      tmpfile.write(Paperclip.io_adapters.for(@item.image).read)
      tmpfile.rewind
      stringio = Vips::Compile.new(title: @item.title, flavor_text: @item.flavor_text, uri: @item.uri, file_path: tmpfile.path).preview_to_string
      # Paperclip
      return stringio
    ensure
      tmpfile.close
      tmpfile.unlink
    end

    def run_validations
      image_exists
      meme_is_unique
    end

    def image_exists
      return nil if @item.image.present?

      @item.errors.add(:base, "You must provide an image")
      throw(:abort)
    end

    def meme_is_unique
      image_hash = Digest::MD5.hexdigest(Paperclip.io_adapters.for(@item.image).read)
      return nil unless Item.find_by(image_hash: image_hash).present?

      @item.errors.add(:base, "Image has already been turned into a meme! Your image must be unique.")
      throw(:abort)
    end

    def run_after_create
      @item.meme_card = generate_preview_card
      @item.save

      # Generate animated card in sidekiq worker
      GravityWellWorker.perform_in(5.seconds, @item.id)
    end
  end
end
