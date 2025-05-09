ItemHandlers::UseInBattle.add(:POKEDOLL, proc { |item, battler, battle|
  battle.decision = 3
  battle.pbDisplayPaused(_INTL("Got away safely!"))
})

ItemHandlers::UseFromBag.add(:LANTERN, proc { |item|
  if useLantern()
    next 1
  else
    next 0
  end
})

ItemHandlers::UseInField.add(:LANTERN, proc { |item|
  Kernel.pbMessage(_INTL("#{$player.name} used the lantern."))
  if useLantern()
    next 1
  else
    next 0
  end
})

def useLantern()
  darkness = $PokemonTemp.darknessSprite
  if !darkness || darkness.disposed? || $PokemonGlobal.flashUsed
    Kernel.pbMessage(_INTL("It's already illuminated..."))
    return false
  end
  Kernel.pbMessage(_INTL("The Lantern illuminated the area!"))
  darkness.radius += 176
  $PokemonGlobal.flashUsed = true
  while darkness.radius < 176
    Graphics.update
    Input.update
    pbUpdateSceneMapd
    darkness.radius += 4
  end
  return true
end

ItemHandlers::UseFromBag.add(:TELEPORTER, proc { |item|
  if useTeleporter()
    next 1
  else
    next 0
  end
})

ItemHandlers::UseInField.add(:TELEPORTER, proc { |item|
  if useTeleporter()
    next 1
  else
    next 0
  end
})

def useTeleporter()
  if HiddenMoveHandlers.triggerCanUseMove(:TELEPORT, 0, true)
    Kernel.pbMessage(_INTL("Teleport to where?", $player.name))
    ret = pbBetterRegionMap(-1, true, true)
    return false unless ret
    ###############################################
    if ret
      $PokemonTemp.flydata = ret
    end
    # scene = PokemonRegionMapScene.new(-1, false)
    # screen = PokemonRegionMap.new(scene)
    # ret = screen.pbStartFlyScreen
    # if ret
    #   $PokemonTemp.flydata = ret
    # end
  end

  if !$PokemonTemp.flydata
    return false
  else
    Kernel.pbMessage(_INTL("{1} used the teleporter!", $player.name))
    pbFadeOutIn(99999) {
      Kernel.pbCancelVehicles
      $game_temp.player_new_map_id = $PokemonTemp.flydata[0]
      $game_temp.player_new_x = $PokemonTemp.flydata[1]
      $game_temp.player_new_y = $PokemonTemp.flydata[2]
      $PokemonTemp.flydata = nil
      $game_temp.player_new_direction = 2
      $scene.transfer_player
      $game_map.autoplay
      $game_map.refresh
    }
    pbEraseEscapePoint
    return true
  end
end

ItemHandlers::UseInBattle.add(:POKEDOLL, proc { |item, battler, battle|
  battle.decision = 3
  battle.pbDisplayPaused(_INTL("Got away safely!"))
})

ItemHandlers::UseFromBag.add(:LANTERN, proc { |item|
  darkness = $PokemonTemp.darknessSprite
  if !darkness || darkness.disposed?
    Kernel.pbMessage(_INTL("The cave is already illuminated."))
    next false
  end
  Kernel.pbMessage(_INTL("The Lantern illuminated the area!"))
  $PokemonGlobal.flashUsed = true
  darkness.radius += 176
  while darkness.radius < 176
    Graphics.update
    Input.update
    pbUpdateSceneMap
    darkness.radius += 4
  end
  next true
})



ItemHandlers::UseOnPokemon.add(:ROCKETMEAL, proc { |item, quantity, pokemon, scene|
  next pbHPItem(pokemon, 100, scene)
})

ItemHandlers::BattleUseOnPokemon.add(:ROCKETMEAL, proc { |item, pokemon, battler, scene|
  next pbBattleHPItem(pokemon, battler, 100, scene)
})

ItemHandlers::UseOnPokemon.add(:FANCYMEAL, proc { |item, quantity, pokemon, scene|
  next pbHPItem(pokemon, 100, scene)
})

ItemHandlers::BattleUseOnPokemon.add(:FANCYMEAL, proc { |item, pokemon, battler, scene|
  next pbBattleHPItem(pokemon, battler, 100, scene)
})

ItemHandlers::UseOnPokemon.add(:COFFEE, proc { |item, quantity, pokemon, scene|
  next pbHPItem(pokemon, 50, scene)
})

ItemHandlers::BattleUseOnPokemon.add(:COFFEE, proc { |item, pokemon, battler, scene|
  next pbBattleHPItem(pokemon, battler, 50, scene)
})

ItemHandlers::UseOnPokemon.add(:RAGECANDYBAR, proc { |item, quantity, pokemon, scene|
  if pokemon.level <= 1
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  else
    pbChangeLevel(pokemon, pokemon.level - 1, scene)
    scene.pbHardRefresh
    next true
  end
})

ItemHandlers::UseOnPokemon.add(:INCUBATOR, proc { |item, quantity, pokemon, scene|
  if pokemon.egg?
    if pokemon.eggsteps <= 1
      scene.pbDisplay(_INTL("The egg is already ready to hatch!"))
      next false
    else
      scene.pbDisplay(_INTL("Incubating..."))
      scene.pbDisplay(_INTL("..."))
      scene.pbDisplay(_INTL("..."))
      scene.pbDisplay(_INTL("Your egg is ready to hatch!"))
      pokemon.eggsteps = 1
      next true
    end
  else
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
})

ItemHandlers::UseOnPokemon.add(:MISTSTONE, proc { |item, quantity, pokemon, scene|
  next false if pokemon.egg?
  if pbForceEvo(pokemon)
    next true
  else
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
})

ItemHandlers::UseFromBag.add(:DEBUGGER, proc { |item|
  Kernel.pbMessage(_INTL("[{1}]The debugger should ONLY be used if you are stuck somewhere because of a glitch.", Settings::GAME_VERSION_NUMBER))
  if Kernel.pbConfirmMessageSerious(_INTL("Innapropriate use of this item can lead to unwanted effects and make the game unplayable. Do you want to continue?"))
    $game_player.cancelMoveRoute()
    Kernel.pbStartOver(false)
    pbCommonEvent(COMMON_EVENT_FIX_GAME)
    Kernel.pbMessage(_INTL("Please report the glitch on the game's Discord, in the #bug-reports channel."))
    openUrlInBrowser(Settings::DISCORD_URL)
    next 1
  else
    next 0
  end
})

def useSleepingBag()
  currentSecondsValue = pbGet(UnrealTime::EXTRA_SECONDS)
  choices = ["1 hour", "6 hours", "12 hours", "24 hours", "Cancel"]
  choice = Kernel.pbMessage("Sleep for how long?", choices, choices.length)
  echoln choice
  return 0 if choice == choices.length - 1
  oldDay = getDayOfTheWeek()
  timeAdded = 0
  case choice
  when 0
    timeAdded = 3600
  when 1
    timeAdded = 21600
  when 2
    timeAdded = 43200
  when 3
    timeAdded = 86400
  end
  pbSet(UnrealTime::EXTRA_SECONDS, currentSecondsValue + timeAdded)
  pbSEPlay("Sleep", 100)
  pbFadeOutIn {
    Kernel.pbMessage(_INTL("{1} slept for a while...", $player.name))
  }
  time = pbGetTimeNow.strftime("%I:%M %p")
  newDay = getDayOfTheWeek()
  if newDay != oldDay
    Kernel.pbMessage(_INTL("The current time is now {1} on {2}.", time, newDay.downcase.capitalize))
  else
    Kernel.pbMessage(_INTL("The current time is now {1}.", time))
  end
  return 1
end

ItemHandlers::UseFromBag.add(:SLEEPINGBAG, proc { |item|
  mapMetadata = GameData::MapMetadata.try_get($game_map.map_id)
  if !mapMetadata || !mapMetadata.outdoor_map
    Kernel.pbMessage(_INTL("Can't use that here..."))
    next 0
  end
  next useSleepingBag()
})

ItemHandlers::UseInField.add(:SLEEPINGBAG, proc { |item|
  mapMetadata = GameData::MapMetadata.try_get($game_map.map_id)
  if !mapMetadata || !mapMetadata.outdoor_map
    Kernel.pbMessage(_INTL("Can't use that here..."))
    next 0
  end
  next useSleepingBag()
})

ItemHandlers::UseFromBag.add(:ROCKETUNIFORM, proc { |item|
  next useRocketUniform()
})

ItemHandlers::UseInField.add(:ROCKETUNIFORM, proc { |item|
  next useRocketUniform()
})

ItemHandlers::UseFromBag.add(:FAVORITEOUTFIT, proc { |item|
  next useFavoriteOutfit()
})

ItemHandlers::UseInField.add(:FAVORITEOUTFIT, proc { |item|
  next useFavoriteOutfit()
})

ItemHandlers::UseInField.add(:EMERGENCYWHISTLE, proc { |item|
  if isOnPinkanIsland()
    pbCommonEvent(COMMON_EVENT_PINKAN_WHISTLE)
    $scene.reset_map(true)
    updatePinkanBerryDisplay()
    next 1
  end
  next 0
})

ItemHandlers::UseFromBag.add(:EMERGENCYWHISTLE, proc { |item|
  if isOnPinkanIsland()
    pbCommonEvent(COMMON_EVENT_PINKAN_WHISTLE)
    $scene.reset_map(true)
    updatePinkanBerryDisplay()
    next 1
  end
  next 0
})

ItemHandlers::UseFromBag.add(:ODDKEYSTONE, proc { |item|
  TOTAL_SPIRITS_NEEDED = 108
  nbSpirits = pbGet(VAR_ODDKEYSTONE_NB)
  if nbSpirits == 107
    Kernel.pbMessage(_INTL("The Odd Keystone appears to be moving on its own."))
    Kernel.pbMessage(_INTL("Voices can be heard whispering from it..."))
    Kernel.pbMessage(_INTL("Just... one... more..."))
  elsif nbSpirits < TOTAL_SPIRITS_NEEDED
    nbNeeded = TOTAL_SPIRITS_NEEDED - nbSpirits
    Kernel.pbMessage(_INTL("Voices can be heard whispering from the Odd Keystone..."))
    Kernel.pbMessage(_INTL("Bring... us... {1}... spirits", nbNeeded.to_s))
  else
    Kernel.pbMessage(_INTL("The Odd Keystone appears to be moving on its own."))
    Kernel.pbMessage(_INTL("It seems as if some poweful energy is trying to escape from it."))
    if (Kernel.pbMessage("Let it out?", ["No", "Yes"], 0)) == 1
      pbWildBattle(:SPIRITOMB, 27)
      pbSet(VAR_ODDKEYSTONE_NB, 0)
    end
    next 1
  end
})

def useFavoriteOutfit()
  cmd_switch = isWearingFavoriteOutfit() ? "Take off favorite outfit" : "Switch to favorite outfit"
  cmd_mark_favorite = "Mark current outfit as favorite"
  cmd_cancel = "Cancel"

  options = [cmd_switch, cmd_mark_favorite, cmd_cancel]
  choice = optionsMenu(options)
  if options[choice] == cmd_switch
    switchToFavoriteOutfit()
  elsif options[choice] == cmd_mark_favorite
    pbSEPlay("shiny", 80, 100)
    $player.favorite_clothes= $player.clothes
    $player.favorite_hat = $player.hat
    $player.favorite_hat2=$player.hat2
    pbMessage(_INTL("Your favorite outfit was updated!"))
  end
end

def switchToFavoriteOutfit()
  if !$player.favorite_clothes && !$player.favorite_hat && !$player.favorite_hat2
    pbMessage(_INTL("You can mark clothes and hats as your favorites in the outfits menu and use this to quickly switch to them!"))
    return 0
  end

  if isWearingFavoriteOutfit()
    if (Kernel.pbConfirmMessage("Remove your favorite outfit?"))
      last_worn_clothes_is_favorite = $player.last_worn_outfit == $player.favorite_clothes
      last_worn_hat_is_favorite = $player.last_worn_hat == $player.favorite_hat
      last_worn_hat2_is_favorite = $player.last_worn_hat2 == $player.favorite_hat2
      if (last_worn_clothes_is_favorite && last_worn_hat_is_favorite && last_worn_hat2_is_favorite)
        $player.last_worn_outfit = getDefaultClothes()
      end
      playOutfitChangeAnimation()
      putOnClothes($player.last_worn_outfit, true) #if $player.favorite_clothes
      putOnHat($player.last_worn_hat, true,false) #if $player.favorite_hat
      putOnHat($player.last_worn_hat2, true,true) #if $player.favorite_hat2

    else
      return 0
    end

  else
    if (Kernel.pbConfirmMessage("Put on your favorite outfit?"))
      echoln "favorite clothes: #{$player.favorite_clothes}, favorite hat: #{$player.favorite_hat}, favorite hat2: #{$player.favorite_hat2}"

      playOutfitChangeAnimation()
      putOnClothes($player.favorite_clothes, true) if $player.favorite_clothes
      putOnHat($player.favorite_hat, true, false) if $player.favorite_hat
      putOnHat($player.favorite_hat2, true, true) if $player.favorite_hat2
    else
      return 0
    end
  end
end

def useRocketUniform()
  return 0 if !$game_switches[SWITCH_JOINED_TEAM_ROCKET]
  if isWearingTeamRocketOutfit()
    if (Kernel.pbConfirmMessage("Remove the Team Rocket uniform?"))
      if ($player.last_worn_outfit == CLOTHES_TEAM_ROCKET_MALE || $player.last_worn_outfit == CLOTHES_TEAM_ROCKET_FEMALE) && $player.last_worn_hat == HAT_TEAM_ROCKET
        $player.last_worn_outfit = getDefaultClothes()
      end
      playOutfitChangeAnimation()
      putOnClothes($player.last_worn_outfit, true)
      putOnHat($player.last_worn_hat, true)
    else
      return 0
    end
  else
    if (Kernel.pbConfirmMessage("Put on the Team Rocket uniform?"))
      playOutfitChangeAnimation()
      gender = pbGet(VAR_TRAINER_GENDER)
      if gender == GENDER_MALE
        putOnClothes(CLOTHES_TEAM_ROCKET_MALE, true)
      else
        putOnClothes(CLOTHES_TEAM_ROCKET_FEMALE, true)
      end
      putOnHat(HAT_TEAM_ROCKET, true)
      #$scene.reset_map(true)
    end
  end
  return 1
end

def useDreamMirror
  visitedMap = $PokemonGlobal.visitedMaps[pbGet(226)]
  map_name = visitedMap ? Kernel.getMapName(pbGet(226)).to_s : "an unknown location"

  Kernel.pbMessage(_INTL("You peeked into the Dream Mirror..."))

  Kernel.pbMessage(_INTL("You can see a faint glimpse of {1} in the reflection.", map_name))
end

def useStrangePlant
  if darknessEffectOnCurrentMap()
    Kernel.pbMessage(_INTL("The strange plant appears to be glowing."))
    $scene.spriteset.addUserSprite(LightEffect_GlowPlant.new($game_player))
  else
    Kernel.pbMessage(_INTL("It had no effect"))
  end

end

# DREAMMIRROR
ItemHandlers::UseFromBag.add(:DREAMMIRROR, proc { |item|
  useDreamMirror
  next 1
})

ItemHandlers::UseInField.add(:DREAMMIRROR, proc { |item|
  useDreamMirror
  next 1
})

# STRANGE PLANT
ItemHandlers::UseFromBag.add(:STRANGEPLANT, proc { |item|
  useStrangePlant()
  next 1
})

ItemHandlers::UseInField.add(:STRANGEPLANT, proc { |item|
  useStrangePlant()
  next 1
})

ItemHandlers::UseFromBag.add(:MAGICBOOTS, proc { |item|
  if $DEBUG
    if Kernel.pbConfirmMessageSerious(_INTL("Take off the Magic Boots?"))
      $DEBUG = false
    end
  else
    if Kernel.pbConfirmMessageSerious(_INTL("Put on the Magic Boots?"))
      Kernel.pbMessage(_INTL("Debug mode is now active."))
      $game_switches[ENABLED_DEBUG_MODE_AT_LEAST_ONCE] = true # got debug mode (for compatibility)
      $DEBUG = true
    end
  end
  next 1
})

def pbForceEvo(pokemon)
  newspecies = getEvolvedSpecies(pokemon)
  return false if newspecies == -1
  if newspecies > 0
    evo = PokemonEvolutionScene.new
    evo.pbStartScreen(pokemon, newspecies)
    evo.pbEvolution
    evo.pbEndScreen
  end
  return true
end

def getEvolvedSpecies(pokemon)
  return pbCheckEvolutionEx(pokemon) { |pokemon, evonib, level, poke|
    next pbMiniCheckEvolution(pokemon, evonib, level, poke, true)
  }
end

#(copie de fixEvolutionOverflow dans FusionScene)
def getCorrectEvolvedSpecies(pokemon)
  if pokemon.species >= NB_POKEMON
    body = getBasePokemonID(pokemon.species)
    head = getBasePokemonID(pokemon.species, false)
    ret1 = -1; ret2 = -1
    for form in pbGetEvolvedFormData(body)
      retB = yield pokemon, form[0], form[1], form[2]
      break if retB > 0
    end
    for form in pbGetEvolvedFormData(head)
      retH = yield pokemon, form[0], form[1], form[2]
      break if retH > 0
    end
    return ret if ret == retB && ret == retH
    return fixEvolutionOverflow(retB, retH, pokemon.species)
  else
    for form in pbGetEvolvedFormData(pokemon.species)
      newspecies = form[2]
    end
    return newspecies;
  end

end

#########################
##  DNA SPLICERS  #######
#########################

ItemHandlers::UseOnPokemon.add(:INFINITESPLICERS, proc { |item, pokemon, scene|
  next true if pbDNASplicing(pokemon, scene, item)
  next false
})

ItemHandlers::UseOnPokemon.add(:DNASPLICERS, proc { |item, pokemon, scene|
  next true if pbDNASplicing(pokemon, scene, item)
  next false
})

ItemHandlers::UseInField.add(:DNASPLICERS, proc { |item|
  fusion_success = useSplicerFromField(item)
  next 3 if fusion_success
  next false
})

ItemHandlers::UseInField.add(:SUPERSPLICERS, proc { |item|
  fusion_success = useSplicerFromField(item)
  next 3 if fusion_success
  next false
})

ItemHandlers::UseInField.add(:INFINITESPLICERS, proc { |item|
  fusion_success = useSplicerFromField(item)
  next true if fusion_success
  next false
})

ItemHandlers::UseInField.add(:INFINITESPLICERS2, proc { |item|
  fusion_success = useSplicerFromField(item)
  next true if fusion_success
  next false
})

def isSuperSplicersMechanics(item)
  return [:SUPERSPLICERS, :INFINITESPLICERS2].include?(item)
end

def useSplicerFromField(item)
  scene = PokemonParty_Scene.new
  scene.pbStartScene($player.party, "Select a Pokémon")
  screen = PokemonPartyScreen.new(scene, $player.party)
  chosen = screen.pbChoosePokemon("Select a Pokémon")
  pokemon = $player.party[chosen]
  fusion_success = pbDNASplicing(pokemon, scene, item)
  screen.pbEndScene
  scene.dispose
  return fusion_success
end

ItemHandlers::UseOnPokemon.add(:DNAREVERSER, proc { |item, quantity, pokemon, scene|
  if !pokemon.isFusion?
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  if Kernel.pbConfirmMessageSerious(_INTL("Should {1} be reversed?", pokemon.name))
    reverseFusion(pokemon)
    scene.pbRefreshAnnotations(proc { |p| pbCheckEvolution(p, item) > 0 })
    scene.pbRefresh
    next true
  end

  next false
})

def reverseFusion(pokemon)
  if pokemon.owner.name  == "RENTAL"
    pbMessage(_INTL("You cannot reverse a rental pokémon!"))
    return
  end

  body = getBasePokemonID(pokemon.species, true)
  head = getBasePokemonID(pokemon.species, false)
  newspecies = (head) * Settings::NB_POKEMON + body

  body_exp = pokemon.exp_when_fused_body
  head_exp = pokemon.exp_when_fused_head

  pokemon.exp_when_fused_body = head_exp
  pokemon.exp_when_fused_head = body_exp

  pokemon.head_shiny, pokemon.body_shiny = pokemon.body_shiny, pokemon.head_shiny
  # play animation
  pbFadeOutInWithMusic(99999) {
    fus = PokemonEvolutionScene.new
    fus.pbStartScreen(pokemon, newspecies, true)
    fus.pbEvolution(false, true)
    fus.pbEndScreen
  }
end

ItemHandlers::UseOnPokemon.add(:INFINITEREVERSERS, proc { |item, quantity, pokemon, scene|
  if !pokemon.isFusion?
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  if Kernel.pbConfirmMessageSerious(_INTL("Should {1} be reversed?", pokemon.name))
    body = getBasePokemonID(pokemon.species, true)
    head = getBasePokemonID(pokemon.species, false)
    newspecies = (head) * Settings::NB_POKEMON + body

    body_exp = pokemon.exp_when_fused_body
    head_exp = pokemon.exp_when_fused_head

    pokemon.exp_when_fused_body = head_exp
    pokemon.exp_when_fused_head = body_exp

    # play animation
    pbFadeOutInWithMusic(99999) {
      fus = PokemonEvolutionScene.new
      fus.pbStartScreen(pokemon, newspecies, true)
      fus.pbEvolution(false, true)
      fus.pbEndScreen
      scene.pbRefreshAnnotations(proc { |p| pbCheckEvolution(p, item) > 0 })
      scene.pbRefresh
    }
    next true
  end

  next false
})

def calculateUnfuseLevelOldMethod(pokemon, supersplicers)
  if pokemon.level > 1
    if supersplicers
      lev = pokemon.level * 0.9
    else
      lev = pokemon.obtain_method == 2 ? pokemon.level * 0.65 : pokemon.level * 0.75
    end
  else
    lev = 1
  end
  return lev.floor
end

def drawFusionPreviewText(viewport, text, x, y)
  label_base_color = Color.new(248, 248, 248)
  label_shadow_color = Color.new(104, 104, 104)
  overlay = BitmapSprite.new(Graphics.width, Graphics.height, viewport).bitmap
  textpos = [[text, x, y, 0, label_base_color, label_shadow_color]]
  pbDrawTextPositions(overlay, textpos)
end

def drawPokemonType(pokemon_id, x_pos = 192, y_pos = 264)
  width = 66

  viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
  viewport.z = 1000001

  overlay = BitmapSprite.new(Graphics.width, Graphics.height, viewport).bitmap

  pokemon = GameData::Species.get(pokemon_id)
  typebitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/types"))
  type1_number = GameData::Type.get(pokemon.type1).id_number
  type2_number = GameData::Type.get(pokemon.type2).id_number
  type1rect = Rect.new(0, type1_number * 28, 64, 28)
  type2rect = Rect.new(0, type2_number * 28, 64, 28)
  if pokemon.type1 == pokemon.type2
    overlay.blt(x_pos + (width / 2), y_pos, typebitmap.bitmap, type1rect)
  else
    overlay.blt(x_pos, y_pos, typebitmap.bitmap, type1rect)
    overlay.blt(x_pos + width, y_pos, typebitmap.bitmap, type2rect)
  end
  return viewport
end



def returnItemsToBag(pokemon, poke2)

  it1 = pokemon.item
  it2 = poke2.item
  if it1 != nil
    $PokemonBag.pbStoreItem(it1, 1)
  end
  if it2 != nil
    $PokemonBag.pbStoreItem(it2, 1)
  end
  pokemon.item = nil
  poke2.item = nil
end


# easter egg for evolving shellder into slowbro's tail
ItemHandlers::UseOnPokemon.add(:SLOWPOKETAIL, proc { |item, quantity, pokemon, scene|
  echoln pokemon.species
  next false if pokemon.species != :SHELLDER
  pbFadeOutInWithMusic(99999) {
    evo = PokemonEvolutionScene.new
    evo.pbStartScreen(pokemon, :B90H80)
    evo.pbEvolution(false)
    evo.pbEndScreen
    scene.pbRefreshAnnotations(proc { |p| pbCheckEvolution(p, item) > 0 }) if scene.pbHasAnnotations?
    scene.pbRefresh
  }
  next true

})

ItemHandlers::UseOnPokemon.add(:POISONMUSHROOM, proc { |item, quantity, pokemon, scene|
  if pkmn.status != :POISON
    pkmn.status = :POISON
    scene.pbRefresh
    scene.pbDisplay(_INTL("{1} was poisoned from eating the mushroom.", pkmn.name))
  end
  next pbHPItem(pkmn, 10, scene)
})
ItemHandlers::BattleUseOnPokemon.add(:POISONMUSHROOM, proc { |item, pokemon, battler, choices, scene|
  if battler.status != :POISON
    battler.status = :POISON
    scene.pbRefresh
    scene.pbDisplay(_INTL("{1} was poisoned from eating the mushroom.", pokemon.name))
  end
  pbBattleHPItem(pokemon, battler, 10, scene)
})

ItemHandlers::UseOnPokemon.add(:TINYMUSHROOM, proc { |item, quantity, pokemon, scene|
  next pbHPItem(pkmn, 10, scene)
})
ItemHandlers::BattleUseOnPokemon.add(:TINYMUSHROOM, proc { |item, pokemon, battler, choices, scene|
  next pbBattleHPItem(pokemon, battler, 50, scene)
})
ItemHandlers::UseOnPokemon.add(:BIGMUSHROOM, proc { |item, quantity, pokemon, scene|
  next pbHPItem(pkmn, 10, scene)
})
ItemHandlers::BattleUseOnPokemon.add(:BIGMUSHROOM, proc { |item, pokemon, battler, choices, scene|
  next pbBattleHPItem(pokemon, battler, 50, scene)
})
ItemHandlers::UseOnPokemon.add(:BALMMUSHROOM, proc { |item, quantity, pokemon, scene|
  next pbHPItem(pkmn, 999, scene)
})
ItemHandlers::BattleUseOnPokemon.add(:BALMMUSHROOM, proc { |item, pokemon, battler, choices, scene|
  next pbBattleHPItem(pokemon, battler, 999, scene)
})

####EXP. ALL
# Methodes relative a l'exp sont pas encore la et pas compatibles
# avec cette version de essentials donc
# ca fait fuck all pour l'instant.
ItemHandlers::UseFromBag.add(:EXPALL, proc { |item|
  $PokemonBag.pbChangeItem(:EXPALL, :EXPALLOFF)
  Kernel.pbMessage(_INTL("The Exp All was turned off."))
  $game_switches[920] = false
  next 1 # Continue
})

ItemHandlers::UseFromBag.add(:EXPALLOFF, proc { |item|
  $PokemonBag.pbChangeItem(:EXPALLOFF, :EXPALL)
  Kernel.pbMessage(_INTL("The Exp All was turned on."))
  $game_switches[920] = true
  next 1 # Continue
})

ItemHandlers::BattleUseOnPokemon.add(:BANANA, proc { |item, pokemon, battler, scene|
  next pbBattleHPItem(pokemon, battler, 30, scene)
})
ItemHandlers::UseOnPokemon.add(:BANANA, proc { |item, quantity, pokemon, scene|
  next pbHPItem(pokemon, 30, scene)
})

ItemHandlers::BattleUseOnPokemon.add(:GOLDENBANANA, proc { |item, pokemon, battler, scene|
  next pbBattleHPItem(pokemon, battler, 50, scene)
})
ItemHandlers::UseOnPokemon.add(:GOLDENBANANA, proc { |item, quantity, pokemon, scene|
  next pbHPItem(pokemon, 50, scene)
})

ItemHandlers::UseOnPokemon.add(:TRANSGENDERSTONE, proc { |item, quantity, pokemon, scene|
  if pokemon.gender == 0
    pokemon.makeFemale
    scene.pbRefresh
    scene.pbDisplay(_INTL("The Pokémon became female!"))
    next true
  elsif pokemon.gender == 1
    pokemon.makeMale
    scene.pbRefresh
    scene.pbDisplay(_INTL("The Pokémon became male!"))

    next true
  else
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
})

# ItemHandlers::UseOnPokemon.add(:ABILITYCAPSULE, proc { |item, poke, scene|
#   abilityList = poke.getAbilityList
#   abil1 = 0; abil2 = 0
#   for i in abilityList
#     abil1 = i[0] if i[1] == 0
#     abil2 = i[1] if i[1] == 1
#   end
#   if poke.abilityIndex() >= 2 || abil1 == abil2
#     scene.pbDisplay(_INTL("It won't have any effect."))
#     next false
#   end
#   if Kernel.pbConfirmMessage(_INTL("Do you want to change {1}'s ability?",
#                                    poke.name))
#
#     if poke.abilityIndex() == 0
#       poke.setAbility(1)
#     else
#       poke.setAbility(0)
#     end
#     scene.pbDisplay(_INTL("{1}'s ability was changed!", poke.name))
#     next true
#   end
#   next false
#
# })

# NOT FULLY IMPLEMENTED
ItemHandlers::UseOnPokemon.add(:SECRETCAPSULE,proc { |item, quantity, pokemon, scene|
  abilityList = poke.getAbilityList
  numAbilities = abilityList[0].length

  if numAbilities <= 2
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  elsif abilityList[0].length <= 3
    if changeHiddenAbility1(abilityList, scene, poke)
      next true
    end
    next false
  else
    if changeHiddenAbility2(abilityList, scene, poke)
      next true
    end
    next false
  end
})

def changeHiddenAbility1(abilityList, scene, poke)
  abID1 = abilityList[0][2]
  msg = _INTL("Change {1}'s ability to {2}?", poke.name, PBAbilities.getName(abID1))
  if Kernel.pbConfirmMessage(_INTL(msg))
    poke.setAbility(2)
    abilName1 = PBAbilities.getName(abID1)
    scene.pbDisplay(_INTL("{1}'s ability was changed to {2}!", poke.name, PBAbilities.getName(abID1)))
    return true
  else
    return false
  end
end

def changeHiddenAbility2(abilityList, scene, poke)
  return false if !Kernel.pbConfirmMessage(_INTL("Change {1}'s ability?", poke.name))

  abID1 = abilityList[0][2]
  abID2 = abilityList[0][3]

  abilName2 = PBAbilities.getName(abID1)
  abilName3 = PBAbilities.getName(abID2)

  if (Kernel.pbMessage("Choose an ability.", [_INTL("{1}", abilName2), _INTL("{1}", abilName3)], 2)) == 0
    poke.setAbility(2)
    scene.pbDisplay(_INTL("{1}'s ability was changed to {2}!", poke.name, abilName2))
  else
    return false
  end
  poke.setAbility(3)
  scene.pbDisplay(_INTL("{1}'s ability was changed to {2}!", poke.name, abilName3))
  return true
end

ItemHandlers::UseOnPokemon.add(:ROCKETMEAL,proc { |item, quantity, pokemon, scene|
  next pbHPItem(pokemon, 100, scene)
})

ItemHandlers::BattleUseOnPokemon.add(:ROCKETMEAL, proc { |item, pokemon, battler, choices, scene|
  next pbBattleHPItem(pokemon, battler, 100, scene)
})

ItemHandlers::UseOnPokemon.add(:FANCYMEAL, proc { |item, quantity, pokemon, scene|
  next pbHPItem(pokemon, 100, scene)
})

ItemHandlers::BattleUseOnPokemon.add(:FANCYMEAL,proc { |item, pokemon, battler, choices, scene|
  next pbBattleHPItem(pokemon, battler, 100, scene)
})

ItemHandlers::UseOnPokemon.add(:RAGECANDYBAR, proc { |item, quantity, pokemon, scene|
  if pokemon.level <= 1
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  else
    pbChangeLevel(pokemon, pokemon.level - 1, scene)
    scene.pbHardRefresh
    next true
  end
})

ItemHandlers::UseOnPokemon.add(:INCUBATOR, proc { |item, quantity, pokemon, scene|
  if pokemon.egg?
    if pokemon.steps_to_hatch <= 1
      scene.pbDisplay(_INTL("The egg is already ready to hatch!"))
      next false
    else
      scene.pbDisplay(_INTL("Incubating..."))
      scene.pbDisplay(_INTL("..."))
      scene.pbDisplay(_INTL("..."))
      scene.pbDisplay(_INTL("Your egg is ready to hatch!"))
      pokemon.steps_to_hatch = 1
      next true
    end
  else
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
})

ItemHandlers::UseOnPokemon.add(:INCUBATOR_NORMAL, proc { |item, quantity, pokemon, scene|
  if pokemon.egg?
    steps = pokemon.steps_to_hatch
    steps = (steps / 1.5).ceil
    # steps -= 2000 / (pokemon.nbIncubatorsUsed + 1).ceil
    if steps <= 1
      pokemon.steps_to_hatch = 1
    else
      pokemon.steps_to_hatch = steps
    end
    scene.pbDisplay(_INTL("Incubating..."))
    scene.pbDisplay(_INTL("..."))
    scene.pbDisplay(_INTL("..."))
    scene.pbDisplay(_INTL("The egg is closer to hatching!"))

    # if pokemon.steps_to_hatch <= 1
    #   scene.pbDisplay(_INTL("Incubating..."))
    #   scene.pbDisplay(_INTL("..."))
    #   scene.pbDisplay(_INTL("..."))
    #   scene.pbDisplay(_INTL("The egg is ready to hatch!"))
    #   next false
    # else
    #   scene.pbDisplay(_INTL("Incubating..."))
    #   scene.pbDisplay(_INTL("..."))
    #   scene.pbDisplay(_INTL("..."))
    #   if pokemon.nbIncubatorsUsed >= 10
    #     scene.pbDisplay(_INTL("The egg is a bit closer to hatching"))
    #   else
    #     scene.pbDisplay(_INTL("The egg is closer to hatching"))
    #   end
    #   pokemon.incrIncubator()
    #   next true
    # end
  else
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
})

ItemHandlers::UseOnPokemon.add(:MISTSTONE, proc { |item, quantity, pokemon, scene|
  next false if pokemon.egg?
  if pbForceEvo(pokemon)
    next true
  else
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
})

def pbForceEvo(pokemon)
  evolutions = getEvolvedSpecies(pokemon)
  return false if evolutions.empty?
  # if multiple evolutions, pick a random one
  #(format of returned value is [[speciesNum, level]])
  newspecies = evolutions[rand(evolutions.length - 1)][0]
  return false if newspecies == nil
  evo = PokemonEvolutionScene.new
  evo.pbStartScreen(pokemon, newspecies)
  evo.pbEvolution
  evo.pbEndScreen
  return true
end

# format of returned value is [[speciesNum, evolutionMethod],[speciesNum, evolutionMethod],etc.]
def getEvolvedSpecies(pokemon)
  return GameData::Species.get(pokemon.species).get_evolutions(true)
end

#(copie de fixEvolutionOverflow dans FusionScene)
def getCorrectEvolvedSpecies(pokemon)
  if pokemon.species >= NB_POKEMON
    body = getBasePokemonID(pokemon.species)
    head = getBasePokemonID(pokemon.species, false)
    ret1 = -1; ret2 = -1
    for form in pbGetEvolvedFormData(body)
      retB = yield pokemon, form[0], form[1], form[2]
      break if retB > 0
    end
    for form in pbGetEvolvedFormData(head)
      retH = yield pokemon, form[0], form[1], form[2]
      break if retH > 0
    end
    return ret if ret == retB && ret == retH
    return fixEvolutionOverflow(retB, retH, pokemon.species)
  else
    for form in pbGetEvolvedFormData(pokemon.species)
      newspecies = form[2]
    end
    return newspecies;
  end

end

#########################
##  DNA SPLICERS  #######
#########################

ItemHandlers::UseOnPokemon.add(:INFINITESPLICERS, proc { |item, quantity, pokemon, scene|
  next true if pbDNASplicing(pokemon, scene, item)
  next false
})

ItemHandlers::UseOnPokemon.add(:INFINITESPLICERS2,proc { |item, quantity, pokemon, scene|
  next true if pbDNASplicing(pokemon, scene, item)
  next false
})

ItemHandlers::UseOnPokemon.add(:DNASPLICERS, proc { |item, quantity, pokemon, scene|
  next true if pbDNASplicing(pokemon, scene, item)
  next false
})

ItemHandlers::UseOnPokemon.add(:SUPERSPLICERS, proc { |item, quantity, pokemon, scene|
  next true if pbDNASplicing(pokemon, scene, item)
})




ItemHandlers::UseFromBag.add(:DEVONSCOPE, proc { |item|
  pbQuestlog()
  next 1
})

ItemHandlers::UseInField.add(:DEVONSCOPE, proc { |item|
  pbQuestlog()
})

# TRACKER (for roaming legendaries)
ItemHandlers::UseInField.add(:REVEALGLASS, proc { |item|
  track_pokemon()
  next true
})
ItemHandlers::UseFromBag.add(:REVEALGLASS, proc { |item|
  track_pokemon()
  next true
})


####EXP. ALL
# Methodes relative a l'exp sont pas encore la et pas compatibles
# avec cette version de essentials donc
# ca fait fuck all pour l'instant.
ItemHandlers::UseFromBag.add(:EXPALL, proc { |item|
  $PokemonBag.pbChangeItem(:EXPALL, :EXPALLOFF)
  Kernel.pbMessage(_INTL("The Exp All was turned off."))
  $game_switches[920] = false
  next 1 # Continue
})

ItemHandlers::UseFromBag.add(:EXPALLOFF, proc { |item|
  $PokemonBag.pbChangeItem(:EXPALLOFF, :EXPALL)
  Kernel.pbMessage(_INTL("The Exp All was turned on."))
  $game_switches[920] = true
  next 1 # Continue
})

ItemHandlers::BattleUseOnPokemon.add(:BANANA, proc { |item, pokemon, battler, scene|
  next pbBattleHPItem(pokemon, battler, 30, scene)
})
ItemHandlers::UseOnPokemon.add(:BANANA, proc { |item, quantity, pokemon, scene|
  next pbHPItem(pokemon, 30, scene)
})

ItemHandlers::BattleUseOnPokemon.add(:GOLDENBANANA, proc { |item, pokemon, battler, scene|
  next pbBattleHPItem(pokemon, battler, 50, scene)
})
ItemHandlers::UseOnPokemon.add(:GOLDENBANANA, proc { |item, pokemon, scene|
  next pbHPItem(pokemon, 50, scene)
})

ItemHandlers::UseInField.add(:BOXLINK, proc { |item|
  blacklisted_maps = [
    315, 316, 317, 318, 328, 343, # Elite Four
    776, 777, 778, 779, 780, 781, 782, 783, 784, # Mt. Silver
    722, 723, 724, 720, # Dream sequence
    304, 306, 307 # Victory road
  ]
  if blacklisted_maps.include?($game_map.map_id)
    Kernel.pbMessage("There doesn't seem to be any network coverage here...")
  else
    pbFadeOutIn {
      scene = PokemonStorageScene.new
      screen = PokemonStorageScreen.new(scene, $PokemonStorage)
      screen.pbStartScreen(0) # Boot PC in organize mode
    }
  end
  next 1
})