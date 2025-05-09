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

def get_spritecharacter_for_event(event_id)
  for sprite in $scene.spriteset.character_sprites
    if sprite.character.id == event_id
      return sprite
    end
  end
end

def pbBitmap(path)
  if !pbResolveBitmap(path).nil?
    bmp = RPG::Cache.load_bitmap_path(path)
    bmp.storedPath = path
  else
    p "Image located at '#{path}' was not found!" if $DEBUG
    bmp = Bitmap.new(1, 1)
  end
  return bmp
end

def addShinyStarsToGraphicsArray(imageArray, xPos, yPos, shinyBody, shinyHead, debugShiny, srcx = nil, srcy = nil, width = nil, height = nil,
                                 showSecondStarUnder = false, showSecondStarAbove = false)
  color = debugShiny ? Color.new(0, 0, 0, 255) : nil
  imageArray.push(["Graphics/Pictures/shiny", xPos, yPos, srcx, srcy, width, height, color])
  if shinyBody && shinyHead
    if showSecondStarUnder
      yPos += 15
    elsif showSecondStarAbove
      yPos -= 15
    else
      xPos -= 15
    end
    imageArray.push(["Graphics/Pictures/shiny", xPos, yPos, srcx, srcy, width, height, color])
  end
end

def pbCheckPokemonIconFiles(speciesID, egg = false, dna = false)
  if egg
    bitmapFileName = sprintf("Graphics/Icons/iconEgg")
    return pbResolveBitmap(bitmapFileName)
  else
    bitmapFileName = _INTL("Graphics/Pokemon/Icons/{1}", speciesID)
    ret = pbResolveBitmap(bitmapFileName)
    return ret if ret
  end
  ret = pbResolveBitmap("Graphics/Icons/iconDNA.png")
  return ret if ret
  return pbResolveBitmap("Graphics/Icons/iconDNA.png")
end

def pbPokemonIconFile(pokemon)
  bitmapFileName = pbCheckPokemonIconFiles(pokemon.species, pokemon.isEgg?)
  return bitmapFileName
end