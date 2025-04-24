# frozen_string_literal: true

def addWaterCausticsEffect(fog_name = "caustic1", opacity = 16)
  $game_map.fog_name = fog_name
  $game_map.fog_hue = 0
  $game_map.fog_opacity = opacity
  #$game_map.fog_blend_type = @parameters[4]
  $game_map.fog_zoom = 200
  $game_map.fog_sx = 2
  $game_map.fog_sy = 2

  $game_map.setFog2(fog_name, -3, 0, opacity,)
end

def stopWaterCausticsEffect()
  $game_map.fog_opacity = 0
  $game_map.eraseFog2()
end

def clear_all_images()
  for i in 1..99
    # echoln i.to_s + " : " + $game_screen.pictures[i].name
    $game_screen.pictures[i].erase
  end
end


def playPokeFluteAnimation
  # return if $player.outfit != 0
  # $game_player.setDefaultCharName("players/pokeflute", 0, false)
  # Graphics.update
  # Input.update
  # pbUpdateSceneMap
end

def restoreDefaultCharacterSprite(charset_number = 0)
  meta = GameData::Metadata.get_player($player.character_ID)
  $game_player.setDefaultCharName(nil, 0, false)
  $game_player.character_name = meta[1]
  Graphics.update
  Input.update
  pbUpdateSceneMap
end

# if need to play animation from event route
def playAnimation(animationId, x, y)
  return if !$scene.is_a?(Scene_Map)
  $scene.spriteset.addUserAnimation(animationId, x, y, true)
end