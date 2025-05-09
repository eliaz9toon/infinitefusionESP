def getAllCurrentlyRoamingPokemon
  currently_roaming = []
  Settings::ROAMING_SPECIES.each_with_index do |data, i|
    next if !GameData::Species.exists?(data[0])
    next if data[2] > 0 && !$game_switches[data[2]] # Isn't roaming
    next if $PokemonGlobal.roamPokemon[i] == true # Roaming Pokémon has been caught
    currently_roaming << i
  end
  return currently_roaming
end

def track_pokemon()
  currently_roaming = getAllCurrentlyRoamingPokemon()
  echoln currently_roaming
  weather_data = []
  mapinfos = $RPGVX ? load_data("Data/MapInfos.rvdata") : load_data("Data/MapInfos.rxdata")
  currently_roaming.each do |roamer_id|
    map_id = $PokemonGlobal.roamPosition[roamer_id]
    map_name = mapinfos[map_id].name
    weather_type = Settings::ROAMING_SPECIES[roamer_id][6]
    case weather_type
    when :Storm
      forecast_msg = _INTL("An unusual \\c[6]thunderstorm\\c[0] has been detected around \\c[6]{1}", map_name)
    when :StrongWinds
      forecast_msg = _INTL("Unusually \\c[9]strong winds\\c[0] have been detected around \\c[9]{1}", map_name)
    when :Sunny
      forecast_msg = _INTL("Unusually \\c[10]harsh sunlight\\c[0] has been detected around \\c[10]{1}", map_name)
    end
    weather_data << forecast_msg if forecast_msg && !weather_data.include?(forecast_msg)
  end
  weather_data << _INTL("No unusual weather patterns have been detected.") if weather_data.empty?
  weather_data.each do |message|
    Kernel.pbMessage(message)
  end
end
# frozen_string_literal: true

def getHiddenPowerName(pokemon)
  hiddenpower = pbHiddenPower(pokemon)
  hiddenPowerType = hiddenpower[0]

  echoln hiddenPowerType
  if Settings::TRIPLE_TYPES.include?(hiddenPowerType)
    return "Neutral"
  end
  return PBTypes.getName(hiddenPowerType)
end

# Returns if the current map is an outdoor map
def isOutdoor()
  current_map = $game_map.map_id
  map_metadata = GameData::MapMetadata.try_get(current_map)
  return map_metadata && map_metadata.outdoor_map
end

def qmarkMaskCheck()
  if $player.seen_qmarks_sprite
    unless hasHat?(HAT_QMARKS)
      obtainHat(HAT_QMARKS)
      obtainClothes(CLOTHES_GLITCH)
    end
  end
end

def giveJigglypuffScribbles(possible_versions = [1,2,3,4])
  selected_scribbles_version = possible_versions.sample
  case selected_scribbles_version
  when 1
    scribbles_id= HAT_SCRIBBLES1
  when 2
    scribbles_id= HAT_SCRIBBLES2
  when 3
    scribbles_id= HAT_SCRIBBLES3
  when 4
    scribbles_id= HAT_SCRIBBLES4
  end
  return if !scribbles_id

  if !hasHat?(scribbles_id)
    $player.unlocked_hats << scribbles_id
  end
  putOnHat(scribbles_id,true,true)
end


# chance: out of 100
def lilypadEncounter(pokemon, minLevel, maxLevel, chance = 10)
  minLevel, maxLevel = [minLevel, maxLevel].minmax
  level = rand(minLevel..maxLevel)

  event = $game_map.events[@event_id]
  return if !event
  if rand(0..100) <= chance
    pbWildBattle(pokemon, level)
  else
    playAnimation(Settings::GRASS_ANIMATION_ID, event.x, event.y)
  end
  event.erase
end


def calculate_pokemon_weight(pokemon, nerf = 0)

  base_weight = pokemon.weight
  ivs = []
  pokemon.iv.each { |iv|
    ivs << iv[1]
  }
  level = pokemon.level
  # Ensure IVs is an array of 6 values and level is between 1 and 100
  raise "IVs array must have 6 values" if ivs.length != 6
  raise "Level must be between 1 and 100" unless (1..100).include?(level)

  # Calculate the IV Factor
  iv_sum = ivs.sum
  iv_factor = (iv_sum.to_f / 186) * 30 * 10

  # Calculate the Level Factor
  level_factor = (level.to_f / 100) * 5 * 10

  # Calculate the weight
  weight = base_weight * (1 + (iv_factor / 100) + (level_factor / 100))
  weight -= base_weight
  # Enforce the weight variation limits
  max_weight = base_weight * 4.00 # 400% increase
  min_weight = base_weight * 0.5 # 50% decrease

  # Cap the weight between min and max values
  weight = [[weight, min_weight].max, max_weight].min
  weight -= nerf if weight - nerf > min_weight
  return weight.round(2) # Round to 2 decimal places
end

# nerf: remove x kg from each generated pokemon
def generate_weight_contest_entries(species, level, resultsVariable, nerf = 0)
  # echoln "Generating Pokemon"
  pokemon1 = pbGenerateWildPokemon(species, level) # Pokemon.new(species,level)
  pokemon2 = pbGenerateWildPokemon(species, level) # Pokemon.new(species,level)
  new_weights = []
  new_weights << calculate_pokemon_weight(pokemon1, nerf)
  new_weights << calculate_pokemon_weight(pokemon2, nerf)
  echoln new_weights
  echoln "(nerfed by -#{nerf})"
  pbSet(resultsVariable, new_weights.max)
end


# time in seconds
def idleHatEvent(hatId, time, switchToActivate = nil)
  map = $game_map.map_id
  i = 0
  while i < (time / 5) do
    # /5 because we update 5 times per second
    return if $game_map.map_id != map
    i += 1
    pbWait(4)
    i = 0 if $game_player.moving?
    echoln i
  end
  $game_switches[switchToActivate] = true if switchToActivate
  obtainHat(hatId)
end



def obtainStarter(starterIndex = 0)
  if ($game_switches[SWITCH_RANDOM_STARTERS])
    starter = obtainRandomizedStarter(starterIndex)
  else
    startersList = Settings::KANTO_STARTERS
    if $game_switches[SWITCH_JOHTO_STARTERS]
      startersList = Settings::JOHTO_STARTERS
    elsif $game_switches[SWITCH_HOENN_STARTERS]
      startersList = Settings::HOENN_STARTERS
    elsif $game_switches[SWITCH_SINNOH_STARTERS]
      startersList = Settings::SINNOH_STARTERS
    elsif $game_switches[SWITCH_KALOS_STARTERS]
      startersList = Settings::KALOS_STARTERS
    end
    starter = startersList[starterIndex]
  end
  return GameData::Species.get(starter)
end

def isPostgame?()
  return $game_switches[SWITCH_BEAT_THE_LEAGUE]
end

def constellation_add_star(pokemon)
  star_variables = get_constellation_variable(pokemon)

  pbSEPlay("GUI trainer card open", 80)
  nb_stars = pbGet(star_variables)
  pbSet(star_variables, nb_stars + 1)
end


def get_constellation_variable(pokemon)
  case pokemon
  when :IVYSAUR;
    return VAR_CONSTELLATION_IVYSAUR
  when :WARTORTLE;
    return VAR_CONSTELLATION_WARTORTLE
  when :ARCANINE;
    return VAR_CONSTELLATION_ARCANINE
  when :MACHOKE;
    return VAR_CONSTELLATION_MACHOKE
  when :RAPIDASH;
    return VAR_CONSTELLATION_RAPIDASH
  when :GYARADOS;
    return VAR_CONSTELLATION_GYARADOS
  when :ARTICUNO;
    return VAR_CONSTELLATION_ARTICUNO
  when :MEW;
    return VAR_CONSTELLATION_MEW
    # when :POLITOED;   return  VAR_CONSTELLATION_POLITOED
    # when :URSARING;   return  VAR_CONSTELLATION_URSARING
    # when :LUGIA;      return  VAR_CONSTELLATION_LUGIA
    # when :HOOH;       return  VAR_CONSTELLATION_HOOH
    # when :CELEBI;     return  VAR_CONSTELLATION_CELEBI
    # when :SLAKING;    return  VAR_CONSTELLATION_SLAKING
    # when :JIRACHI;    return  VAR_CONSTELLATION_JIRACHI
    # when :TYRANTRUM;  return  VAR_CONSTELLATION_TYRANTRUM
    # when :SHARPEDO;   return  VAR_CONSTELLATION_SHARPEDO
    # when :ARCEUS;     return  VAR_CONSTELLATION_ARCEUS
  end
end


def getNextLunarFeatherHint()
  nb_feathers = pbGet(VAR_LUNAR_FEATHERS)
  case nb_feathers
  when 0
    return "Find the first feather in the northernmost dwelling in the port of exquisite sunsets..."
  when 1
    return "Amidst a nursery for Pokémon youngsters, the second feather hides, surrounded by innocence."
  when 2
    return "Find the next one in the inn where water meets rest"
  when 3
    return "Find the next one inside the lone house in the city at the edge of civilization."
  when 4
    return "The final feather lies back in the refuge for orphaned Pokémon..."
  else
    return "Lie in the bed... Bring me the feathers..."
  end
end

def apply_concert_lighting(light, duration = 1)
  tone = Tone.new(0, 0, 0)
  case light
  when :GUITAR_HIT
    tone = Tone.new(-50, -100, -50)
  when :VERSE_1
    tone = Tone.new(-90, -110, -50)
  when :VERSE_2_LIGHT
    tone = Tone.new(-40, -80, -30)
  when :VERSE_2_DIM
    tone = Tone.new(-60, -100, -50)
  when :CHORUS_1
    tone = Tone.new(0, -80, -50)
  when :CHORUS_2
    tone = Tone.new(0, -50, -80)
  when :CHORUS_3
    tone = Tone.new(0, -80, -80)
  when :CHORUS_END
    tone = Tone.new(-68, 0, -102)
  when :MELOETTA_1
    tone = Tone.new(-60, -50, 20)
  end
  $game_screen.start_tone_change(tone, duration)
end

def playMeloettaBandMusic()
  unlocked_members = []
  unlocked_members << :DRUM if $game_switches[SWITCH_BAND_DRUMMER]
  unlocked_members << :AGUITAR if $game_switches[SWITCH_BAND_ACOUSTIC_GUITAR]
  unlocked_members << :EGUITAR if $game_switches[SWITCH_BAND_ELECTRIC_GUITAR]
  unlocked_members << :FLUTE if $game_switches[SWITCH_BAND_FLUTE]
  unlocked_members << :HARP if $game_switches[SWITCH_BAND_HARP]

  echoln unlocked_members
  echoln (unlocked_members & [:DRUM, :AGUITAR, :EGUITAR, :FLUTE, :HARP])

  track = "band/band_1"
  if unlocked_members == [:DRUM, :AGUITAR, :EGUITAR, :FLUTE, :HARP]
    track = "band/band_full"
  else
    if unlocked_members.include?(:FLUTE)
      track = "band/band_5a"
    elsif unlocked_members.include?(:HARP)
      track = "band/band_5b"
    else
      if unlocked_members.include?(:EGUITAR) && unlocked_members.include?(:AGUITAR)
        track = "band/band_4"
      elsif unlocked_members.include?(:AGUITAR)
        track = "band/band_3a"
      elsif unlocked_members.include?(:EGUITAR)
        track = "band/band_3b"
      elsif unlocked_members.include?(:DRUM)
        track = "band/band_2"
      end
    end
  end
  echoln track
  pbBGMPlay(track)
end

def regirock_steel_move_boulder()

  switches_position = [
    [16, 21], [18, 21], [20, 21], [22, 21],
    [16, 23], [22, 23],
    [16, 25], [18, 25], [20, 25], [22, 25]
  ]
  boulder_event = get_self
  old_x = boulder_event.x
  old_y = boulder_event.y
  stepped_off_switch = switches_position.find { |position| position[0] == old_x && position[1] == old_y }

  pbPushThisBoulder()
  boulder_event = get_self

  if stepped_off_switch
    switch_event = $game_map.get_event_at_position(old_x, old_y, [boulder_event.id])
    echoln switch_event.id if switch_event
    pbSEPlay("Entering Door", nil, 80)
    pbSetSelfSwitch(switch_event.id, "A", false) if switch_event
  end

  stepped_on_switch = switches_position.find { |position| position[0] == boulder_event.x && position[1] == boulder_event.y }
  if stepped_on_switch
    switch_event = $game_map.get_event_at_position(boulder_event.x, boulder_event.y, [boulder_event.id])
    echoln switch_event.id if switch_event
    pbSEPlay("Entering Door")
    pbSetSelfSwitch(switch_event.id, "A", true) if switch_event
  end
end


KANTO_DARKNESS_STAGE_1 = [
  50, # Lavender town
  409, # Route 8
  351, # Route 9 (east)
  495, # Route 9 (west)
  154, # Route 10
  108, # Saffron city
  1, # Cerulean City
  387, # Cerulean City (race)
  106, # Route 4
  8, # Route 24
  9, # Route 25
  400, # Pokemon Tower
  401, # Pokemon Tower
  402, # Pokemon Tower
  403, # Pokemon Tower
  467, # Pokemon Tower
  468, # Pokemon Tower
  469, # Pokemon Tower
  159, # Route 12
  349, # Rock tunnel
  350, # Rock tunnel
  512, # Rock tunnel (outdoor)
  12, # Route 5

]
KANTO_DARKNESS_STAGE_2 = [
  95, # Celadon city
  436, # Celadon city dept store (roof)
  143, # Route 23
  167, # Crimson city
  413, # Route 7
  438, # Route 16
  146, # Route 17
  106, # Route 4
  19, # Vermillion City
  36, # S.S. Anne deck
  16, # Route 6
  437, # Route 13
  155, # Route 11
  140, # Diglett cave
  398, # Diglett cave
  399, # Diglett cave
]
KANTO_DARKNESS_STAGE_3 = [
  472, # Fuchsia city
  445, # Safari Zone 1
  484, # Safari Zone 2
  485, # Safari Zone 3
  486, # Safari Zone 4
  487, # Safari Zone 5
  444, # Route 15
  440, # Route 14
  712, # Creepy house
  517, # Route 18
  57, # Route 19
  227, # Route 19 (underwater)
  56, # Route 19 (surf race)
  58, # Route 20
  480, # Route 20 underwater 1
  228, # Route 20 underwater 2
  98, # Cinnabar island
  58, # Route 21
  827, # Mt. Moon summit
]
KANTO_DARKNESS_STAGE_4 = KANTO_OUTDOOR_MAPS

def darknessEffectOnCurrentMap()
  return if !$game_switches
  return if !$game_switches[SWITCH_KANTO_DARKNESS]
  return darknessEffectOnMap($game_map.map_id)
end

def darknessEffectOnMap(map_id)
  return if !$game_switches
  return if !$game_switches[SWITCH_KANTO_DARKNESS]
  return if !KANTO_OUTDOOR_MAPS.include?(map_id)
  dark_maps = []
  dark_maps += KANTO_DARKNESS_STAGE_1 if $game_switches[SWITCH_KANTO_DARKNESS_STAGE_1]
  dark_maps += KANTO_DARKNESS_STAGE_2 if $game_switches[SWITCH_KANTO_DARKNESS_STAGE_2]
  dark_maps += KANTO_DARKNESS_STAGE_3 if $game_switches[SWITCH_KANTO_DARKNESS_STAGE_3]
  dark_maps = KANTO_OUTDOOR_MAPS if $game_switches[SWITCH_KANTO_DARKNESS_STAGE_4]
  return dark_maps.include?(map_id)
end

def apply_darkness()
  $PokemonTemp.darknessSprite = DarknessSprite.new
  darkness = $PokemonTemp.darknessSprite
  darkness.radius = 276
  while darkness.radius > 64
    Graphics.update
    Input.update
    pbUpdateSceneMap
    darkness.radius -= 4
  end
  $PokemonGlobal.flashUsed = false
  $PokemonTemp.darknessSprite.dispose
  Events.onMapSceneChange.trigger(self, $scene, true)
end

def isInMtMoon()
  mt_moon_maps = [102, 103, 105, 496, 104]
  return mt_moon_maps.include?($game_map.map_id)
end

def getMtMoonDirection()
  maps_east = [380, # Pewter city
               490, # Route 3
               303, # indigo plateau
               145, # Route 26
               147, # Route 27
  ]
  maps_south = [
    8, # Route 24
    9, # Route 25
    143, # Route 23
    167, # Crimson city
  ]
  maps_west = [
    106, # route 4
    1, # cerulean
    495, # route 9
    351, # route 9
    10 # cerulean cape
  ]
  return 2 if maps_south.include?($game_map.map_id)
  return 4 if maps_west.include?($game_map.map_id)
  return 6 if maps_east.include?($game_map.map_id)
  return 8 # north (most maps)
end



def Kernel.setRocketPassword(variableNum)
  abilityIndex = rand(233)
  speciesIndex = rand(PBSpecies.maxValue - 1)

  word1 = PBSpecies.getName(speciesIndex)
  word2 = GameData::Ability.get(abilityIndex).name
  password = _INTL("{1}'s {2}", word1, word2)
  pbSet(variableNum, password)
end

def obtainBadgeMessage(badgeName)
  Kernel.pbMessage(_INTL("\\me[Badge get]{1} obtained the {2}!", $player.name, badgeName))
end


def getFossilsGuyTeam(level)
  base_poke_evolution_level = 20
  fossils_evolution_level_1 = 30
  fossils_evolution_level_2 = 50

  fossils = []
  base_poke = level <= base_poke_evolution_level ? :B88H109 : :B89H110
  team = []
  team << Pokemon.new(base_poke, level)

  # Mt. Moon fossil
  if $game_switches[SWITCH_PICKED_HELIC_FOSSIL]
    fossils << :KABUTO if level < fossils_evolution_level_1
    fossils << :KABUTOPS if level >= fossils_evolution_level_1
  elsif $game_switches[SWITCH_PICKED_DOME_FOSSIL]
    fossils << :OMANYTE if level < fossils_evolution_level_1
    fossils << :OMASTAR if level >= fossils_evolution_level_1
  end

  # S.S. Anne fossil
  if $game_switches[SWITCH_PICKED_LILEEP_FOSSIL]
    fossils << :ANORITH if level < fossils_evolution_level_1
    fossils << :ARMALDO if level >= fossils_evolution_level_1

  elsif $game_switches[SWITCH_PICKED_ANORITH_FOSSIL]
    fossils << :LILEEP if level < fossils_evolution_level_1
    fossils << :CRADILY if level >= fossils_evolution_level_1
  end
  # Celadon fossil
  if $game_switches[SWITCH_PICKED_ARMOR_FOSSIL]
    fossils << :CRANIDOS if level < fossils_evolution_level_2
    fossils << :RAMPARDOS if level >= fossils_evolution_level_2

  elsif $game_switches[SWITCH_PICKED_SKULL_FOSSIL]
    fossils << :SHIELDON if level < fossils_evolution_level_2
    fossils << :BASTIODON if level >= fossils_evolution_level_2
  end

  skip_next = false
  for index in 0..fossils.length
    if index == fossils.length - 1
      team << Pokemon.new(fossils[index], level)
    else
      if skip_next
        skip_next = false
        next
      end
      head_poke = fossils[index]
      body_poke = fossils[index + 1]
      if head_poke && body_poke
        newPoke = getFusionSpecies(dexNum(body_poke), dexNum(head_poke))
        team << Pokemon.new(newPoke, level)
        skip_next = true
      end
    end
  end
  return team
end

# tradedPoke = pbGet(154)
# party=[tradedPoke]
# customTrainerBattle("Eusine",
#                     :MYSTICALMAN,
#                     party,
#                     tradedPoke.level,
#                     "Okay, okay I'll give it back!" )
def fossilsGuyBattle(level = 20, end_message = "")
  team = getFossilsGuyTeam(level)
  customTrainerBattle("Miguel",
                      :SUPERNERD,
                      team,
                      level,
                      end_message
  )

end

def isOnPinkanIsland()
  return false
end

def generateSimpleTrainerParty(teamSpecies, level)
  team = []
  for species in teamSpecies
    poke = Pokemon.new(species, level)
    team << poke
  end
  return team
end

def generateEggGroupTeam(eggGroup)
  teamComplete = false
  generatedTeam = []
  while !teamComplete
    species = rand(PBSpecies.maxValue)
    if getPokemonEggGroups(species).include?(eggGroup)
      generatedTeam << species
    end
    teamComplete = generatedTeam.length == 3
  end
  return generatedTeam
end