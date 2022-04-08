class TestItem < Item
  # override
  def owner_is_unique
    true # Warn
  end

  # override
  def meme_is_unique
    true # Warn
  end

  # override
  def printer_is_live
    true
  end
end
