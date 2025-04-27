# frozen_string_literal: true
class IconSprite
  def setBitmapDirectly(bitmap)
    oldrc = self.src_rect
    clearBitmaps()
    @name = ""
    return if bitmap == nil
    @_iconbitmap = bitmap
    # for compatibility
    #
    self.bitmap = @_iconbitmap ? @_iconbitmap.bitmap : nil
    self.src_rect = oldrc
  end
end
