class Spriteset_Global
  ###################
  #Overwritten methods
  # #################
  def initialize
    @map_id = $game_map&.map_id || 0
    @follower_sprites = FollowerSprites.new(Spriteset_Map.viewport)
    @playersprite = Sprite_Player.new(Spriteset_Map.viewport, $game_player)
    @weather = RPG::Weather.new(Spriteset_Map.viewport)
    @picture_sprites = []
    (1..100).each do |i|
      @picture_sprites.push(Sprite_Picture.new(@@viewport2, $game_screen.pictures[i]))
    end
    @timer_sprite = Sprite_Timer.new
    update
  end

end

