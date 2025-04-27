# frozen_string_literal: true

module RPG
  module Cache
    def self.load_bitmap_path(path, hue = 0)
      cached = true
      ret = fromCache(path)
      if !ret
        if path == ""
          ret = BitmapWrapper.new(32, 32)
        else
          ret = BitmapWrapper.new(path)
        end
        @cache[path] = ret
        cached = false
      end
      if hue == 0
        ret.addRef if cached
        return ret
      end
      key = [path, hue]
      ret2 = fromCache(key)
      if ret2
        ret2.addRef
      else
        ret2 = ret.copy
        ret2.hue_change(hue)
        @cache[key] = ret2
      end
      return ret2
    end
  end
end