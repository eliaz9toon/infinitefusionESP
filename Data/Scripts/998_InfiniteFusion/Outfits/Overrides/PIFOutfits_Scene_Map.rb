# frozen_string_literal: true

class Scene_Map
  def reset_player_sprite
    @spritesetGlobal.playersprite.updateBitmap
  end
end
