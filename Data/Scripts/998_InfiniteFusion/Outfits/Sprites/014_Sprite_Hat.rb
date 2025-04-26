class Sprite_Hat < Sprite_Wearable
  def initialize(player_sprite, filename, action, viewport, relative_z=2)
    super
    @relative_z = relative_z
  end
end