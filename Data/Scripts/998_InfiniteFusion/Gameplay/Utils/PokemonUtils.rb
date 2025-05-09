
def replaceFusionSpecies(pokemon, speciesToChange, newSpecies)
  currentBody = pokemon.species_data.get_body_species_symbol()
  currentHead = pokemon.species_data.get_head_species_symbol()
  should_update_body = currentBody == speciesToChange
  should_update_head = currentHead == speciesToChange

  echoln speciesToChange
  echoln currentBody
  echoln currentHead

  return if !should_update_body && !should_update_head

  newSpeciesBody = should_update_body ? newSpecies : currentBody
  newSpeciesHead = should_update_head ? newSpecies : currentHead

  newSpecies = getFusionSpecies(newSpeciesBody, newSpeciesHead)
  echoln newSpecies.id_number
  pokemon.species = newSpecies
end

def changeSpeciesSpecific(pokemon, newSpecies)
  pokemon.species = newSpecies
  $player.pokedex.set_seen(newSpecies)
  $player.pokedex.set_owned(newSpecies)
end


def setPokemonMoves(pokemon, move_ids = [])
  moves = []
  move_ids.each { |move_id|
    moves << Pokemon::Move.new(move_id)
  }
  pokemon.moves = moves
end


def getGenericPokemonCryText(pokemonSpecies)
  case pokemonSpecies
  when 25
    return "Pika!"
  when 16, 17, 18, 21, 22, 144, 145, 146, 227, 417, 418, 372 # birds
    return "Squawk!"
  when 163, 164
    return "Hoot!" # owl
  else
    return "Guaugh!"
  end
end


def Kernel.getPlateType(item)
  return :FIGHTING if item == PBItems::FISTPLATE
  return :FLYING if item == PBItems::SKYPLATE
  return :POISON if item == PBItems::TOXICPLATE
  return :GROUND if item == PBItems::EARTHPLATE
  return :ROCK if item == PBItems::STONEPLATE
  return :BUG if item == PBItems::INSECTPLATE
  return :GHOST if item == PBItems::SPOOKYPLATE
  return :STEEL if item == PBItems::IRONPLATE
  return :FIRE if item == PBItems::FLAMEPLATE
  return :WATER if item == PBItems::SPLASHPLATE
  return :GRASS if item == PBItems::MEADOWPLATE
  return :ELECTRIC if item == PBItems::ZAPPLATE
  return :PSYCHIC if item == PBItems::MINDPLATE
  return :ICE if item == PBItems::ICICLEPLATE
  return :DRAGON if item == PBItems::DRACOPLATE
  return :DARK if item == PBItems::DREADPLATE
  return :FAIRY if item == PBItems::PIXIEPLATE
  return -1
end

def Kernel.listPlatesInBag()
  list = []
  list << PBItems::FISTPLATE if $PokemonBag.pbQuantity(:FISTPLATE) >= 1
  list << PBItems::SKYPLATE if $PokemonBag.pbQuantity(:SKYPLATE) >= 1
  list << PBItems::TOXICPLATE if $PokemonBag.pbQuantity(:TOXICPLATE) >= 1
  list << PBItems::EARTHPLATE if $PokemonBag.pbQuantity(:EARTHPLATE) >= 1
  list << PBItems::STONEPLATE if $PokemonBag.pbQuantity(:STONEPLATE) >= 1
  list << PBItems::INSECTPLATE if $PokemonBag.pbQuantity(:INSECTPLATE) >= 1
  list << PBItems::SPOOKYPLATE if $PokemonBag.pbQuantity(:SPOOKYPLATE) >= 1
  list << PBItems::IRONPLATE if $PokemonBag.pbQuantity(:IRONPLATE) >= 1
  list << PBItems::FLAMEPLATE if $PokemonBag.pbQuantity(:FLAMEPLATE) >= 1
  list << PBItems::SPLASHPLATE if $PokemonBag.pbQuantity(:SPLASHPLATE) >= 1
  list << PBItems::MEADOWPLATE if $PokemonBag.pbQuantity(:MEADOWPLATE) >= 1
  list << PBItems::ZAPPLATE if $PokemonBag.pbQuantity(:ZAPPLATE) >= 1
  list << PBItems::MINDPLATE if $PokemonBag.pbQuantity(:MINDPLATE) >= 1
  list << PBItems::ICICLEPLATE if $PokemonBag.pbQuantity(:ICICLEPLATE) >= 1
  list << PBItems::DRACOPLATE if $PokemonBag.pbQuantity(:DRACOPLATE) >= 1
  list << PBItems::DREADPLATE if $PokemonBag.pbQuantity(:DREADPLATE) >= 1
  list << PBItems::PIXIEPLATE if $PokemonBag.pbQuantity(:PIXIEPLATE) >= 1
  return list
end

def getArceusPlateType(heldItem)
  return :NORMAL if heldItem == nil
  case heldItem
  when :FISTPLATE
    return :FIGHTING
  when :SKYPLATE
    return :FLYING
  when :TOXICPLATE
    return :POISON
  when :EARTHPLATE
    return :GROUND
  when :STONEPLATE
    return :ROCK
  when :INSECTPLATE
    return :BUG
  when :SPOOKYPLATE
    return :GHOST
  when :IRONPLATE
    return :STEEL
  when :FLAMEPLATE
    return :FIRE
  when :SPLASHPLATE
    return :WATER
  when :MEADOWPLATE
    return :GRASS
  when :ZAPPLATE
    return :ELECTRIC
  when :MINDPLATE
    return :PSYCHIC
  when :ICICLEPLATE
    return :ICE
  when :DRACOPLATE
    return :DRAGON
  when :DREADPLATE
    return :DARK
  when :PIXIEPLATE
    return :FAIRY
  else
    return :NORMAL
  end
end


def changeOricorioForm(pokemon, form = nil)
  oricorio_forms = [:ORICORIO_1, :ORICORIO_2, :ORICORIO_3, :ORICORIO_4]
  body_id = pokemon.isFusion? ? get_body_species_from_symbol(pokemon.species) : pokemon.species
  head_id = pokemon.isFusion? ? get_head_species_from_symbol(pokemon.species) : pokemon.species

  oricorio_body = oricorio_forms.include?(body_id)
  oricorio_head = oricorio_forms.include?(head_id)

  if form == 1
    body_id = :ORICORIO_1 if oricorio_body
    head_id = :ORICORIO_1 if oricorio_head
  elsif form == 2
    body_id = :ORICORIO_2 if oricorio_body
    head_id = :ORICORIO_2 if oricorio_head
  elsif form == 3
    body_id = :ORICORIO_3 if oricorio_body
    head_id = :ORICORIO_3 if oricorio_head
  elsif form == 4
    body_id = :ORICORIO_4 if oricorio_body
    head_id = :ORICORIO_4 if oricorio_head
  else
    return false
  end

  head_number = getDexNumberForSpecies(head_id)
  body_number = getDexNumberForSpecies(body_id)

  newForm = pokemon.isFusion? ? getSpeciesIdForFusion(head_number, body_number) : head_id
  $player.pokedex.set_seen(newForm)
  $player.pokedex.set_owned(newForm)

  pokemon.species = newForm
  return true
end


def changeOricorioFlower(form = 1)
  if $PokemonGlobal.stepcount % 25 == 0
    if !hatUnlocked?(HAT_FLOWER) && rand(2) == 0
      obtainHat(HAT_FLOWER)
      $PokemonGlobal.stepcount += 1
    else
      pbMessage(_INTL("Woah! A Pokémon jumped out of the flower!"))
      pbWildBattle(:FOMANTIS, 10)
      $PokemonGlobal.stepcount += 1
    end
  end
  return if !($player.has_species_or_fusion?(:ORICORIO_1) || $player.has_species_or_fusion?(:ORICORIO_2) || $player.has_species_or_fusion?(:ORICORIO_3) || $player.has_species_or_fusion?(:ORICORIO_4))
  message = ""
  form_name = ""
  if form == 1
    message = "It's a flower with red nectar. "
    form_name = "Baile"
  elsif form == 2
    message = "It's a flower with yellow nectar. "
    form_name = "Pom-pom"
  elsif form == 3
    message = "It's a flower with pink nectar. "
    form_name = "Pa'u"
  elsif form == 4
    message = "It's a flower with blue nectar. "
    form_name = "Sensu"
  end

  message = message + "Show it to a Pokémon?"
  if pbConfirmMessage(message)
    pbChoosePokemon(1, 2,
                    proc { |poke|
                      !poke.egg? &&
                        (Kernel.isPartPokemon(poke, :ORICORIO_1) ||
                          Kernel.isPartPokemon(poke, :ORICORIO_2) ||
                          Kernel.isPartPokemon(poke, :ORICORIO_3) ||
                          Kernel.isPartPokemon(poke, :ORICORIO_4))
                    })
    if (pbGet(1) != -1)
      poke = $player.party[pbGet(1)]
      if changeOricorioForm(poke, form)
        pbMessage(_INTL("{1} switched to the {2} style", poke.name, form_name))
        pbSet(1, poke.name)
      else
        pbMessage(_INTL("{1} remained the same...", poke.name, form_name))
      end
    end
  end
end

def oricorioEventPickFlower(flower_color)
  quest_progression = pbGet(VAR_ORICORIO_FLOWERS)
  if flower_color == :PINK
    if !$game_switches[SWITCH_ORICORIO_QUEST_PINK]
      pbMessage(_INTL("Woah! A Pokémon jumped out of the flower!"))
      pbWildBattle(:FOMANTIS, 10)
    end
    $game_switches[SWITCH_ORICORIO_QUEST_PINK] = true
    pbMessage(_INTL("It's a flower with pink nectar."))
    pbSEPlay("MiningAllFound")
    pbMessage(_INTL("{1} picked some of the pink flowers.", $player.name))
  elsif flower_color == :RED && quest_progression == 1
    $game_switches[SWITCH_ORICORIO_QUEST_RED] = true
    pbMessage(_INTL("It's a flower with red nectar."))
    pbSEPlay("MiningAllFound")
    pbMessage(_INTL("{1} picked some of the red flowers.", $player.name))
  elsif flower_color == :BLUE && quest_progression == 2
    $game_switches[SWITCH_ORICORIO_QUEST_BLUE] = true
    pbMessage(_INTL("It's a flower with blue nectar."))
    pbSEPlay("MiningAllFound")
    pbMessage(_INTL("{1} picked some of the blue flowers.", $player.name))
  end

end

# frozen_string_literal: true

def isInKantoGeneration(dexNumber)
  return dexNumber <= 151
end

def isKantoPokemon(species)
  dexNum = getDexNumberForSpecies(species)
  poke = getPokemon(species)
  head_dex = getDexNumberForSpecies(poke.get_head_species())
  body_dex = getDexNumberForSpecies(poke.get_body_species())
  return isInKantoGeneration(dexNum) || isInKantoGeneration(head_dex) || isInKantoGeneration(body_dex)
end

def isInJohtoGeneration(dexNumber)
  return dexNumber > 151 && dexNumber <= 251
end

def isJohtoPokemon(species)
  dexNum = getDexNumberForSpecies(species)
  poke = getPokemon(species)
  head_dex = getDexNumberForSpecies(poke.get_head_species())
  body_dex = getDexNumberForSpecies(poke.get_body_species())
  return isInJohtoGeneration(dexNum) || isInJohtoGeneration(head_dex) || isInJohtoGeneration(body_dex)
end

def isAlolaPokemon(species)
  dexNum = getDexNumberForSpecies(species)
  poke = getPokemon(species)
  head_dex = getDexNumberForSpecies(poke.get_head_species())
  body_dex = getDexNumberForSpecies(poke.get_body_species())
  list = [
    370, 373, 430, 431, 432, 433, 450, 451, 452,
    453, 454, 455, 459, 460, 463, 464, 465, 469, 470,
    471, 472, 473, 474, 475, 476, 477, 498, 499,
  ]
  return list.include?(dexNum) || list.include?(head_dex) || list.include?(body_dex)
end

def isKalosPokemon(species)
  dexNum = getDexNumberForSpecies(species)
  poke = getPokemon(species)
  head_dex = getDexNumberForSpecies(poke.get_head_species())
  body_dex = getDexNumberForSpecies(poke.get_body_species())
  list =
    [327, 328, 329, 339, 371, 372, 417, 418,
     425, 426, 438, 439, 440, 441, 444, 445, 446,
     456, 461, 462, 478, 479, 480, 481, 482, 483, 484, 485, 486, 487,
     489, 490, 491, 492, 500,

    ]
  return list.include?(dexNum) || list.include?(head_dex) || list.include?(body_dex)
end

def isUnovaPokemon(species)
  dexNum = getDexNumberForSpecies(species)
  poke = getPokemon(species)
  head_dex = getDexNumberForSpecies(poke.get_head_species())
  body_dex = getDexNumberForSpecies(poke.get_body_species())
  list =
    [
      330, 331, 337, 338, 348, 349, 350, 351, 359, 360, 361,
      362, 363, 364, 365, 366, 367, 368, 369, 374, 375, 376, 377,
      397, 398, 399, 406, 407, 408, 409, 410, 411, 412, 413, 414,
      415, 416, 419, 420,
      422, 423, 424, 434, 345,
      466, 467, 494, 493,
    ]
  return list.include?(dexNum) || list.include?(head_dex) || list.include?(body_dex)
end

def isSinnohPokemon(species)
  dexNum = getDexNumberForSpecies(species)
  poke = getPokemon(species)
  head_dex = getDexNumberForSpecies(poke.get_head_species())
  body_dex = getDexNumberForSpecies(poke.get_body_species())
  list =
    [254, 255, 256, 257, 258, 259, 260, 261, 262, 263, 264, 265,
     266, 267, 268, 269, 270, 271, 272, 273, 274, 275, 288, 294,
     295, 296, 297, 298, 299, 305, 306, 307, 308, 315, 316, 317,
     318, 319, 320, 321, 322, 323, 324, 326, 332, 343, 344, 345,
     346, 347, 352, 353, 354, 358, 383, 384, 388, 389, 400, 402,
     403, 429, 468]

  return list.include?(dexNum) || list.include?(head_dex) || list.include?(body_dex)
end

def isHoennPokemon(species)
  dexNum = getDexNumberForSpecies(species)
  poke = getPokemon(species)
  head_dex = getDexNumberForSpecies(poke.get_head_species())
  body_dex = getDexNumberForSpecies(poke.get_body_species())
  list = [252, 253, 276, 277, 278, 279, 280, 281, 282, 283, 284,
          285, 286, 287, 289, 290, 291, 292, 293, 300, 301, 302, 303,
          304, 309, 310, 311, 312, 313, 314, 333, 334, 335, 336, 340,
          341, 342, 355, 356, 357, 378, 379, 380, 381, 382, 385, 386,
          387, 390, 391, 392, 393, 394, 395, 396, 401, 404, 405, 421,
          427, 428, 436, 437, 442, 443, 447, 448, 449, 457, 458, 488,
          495, 496, 497, 501, 502, 503, 504, 505, 506, 507, 508, 509,
          510, 511, 512, 513, 514, 515, 516, 517, 518, 519, 520, 521,
          522, 523, 524, 525, 526, 527, 528, 529, 530, 531, 532, 533,
          534, 535, 536, 537, 538, 539, 540, 541, 542, 543, 544, 545,
          546, 547, 548, 549, 550, 551, 552, 553, 554, 555, 556, 557,
          558, 559, 560, 561, 562, 563, 564, 565
  ]
  return list.include?(dexNum) || list.include?(head_dex) || list.include?(body_dex)
end

def Kernel.getRoamingMap(roamingArrayPos)
  curmap = $PokemonGlobal.roamPosition[roamingArrayPos]
  mapinfos = $RPGVX ? load_data("Data/MapInfos.rvdata") : load_data("Data/MapInfos.rxdata")
  text = mapinfos[curmap].name #,(curmap==$game_map.map_id) ? _INTL("(this map)") : "")
  return text
end

def get_default_moves_at_level(species, level)
  moveset = GameData::Species.get(species).moves
  knowable_moves = []
  moveset.each { |m| knowable_moves.push(m[1]) if m[0] <= level }
  # Remove duplicates (retaining the latest copy of each move)
  knowable_moves = knowable_moves.reverse
  knowable_moves |= []
  knowable_moves = knowable_moves.reverse
  # Add all moves
  moves = []
  first_move_index = knowable_moves.length - MAX_MOVES
  first_move_index = 0 if first_move_index < 0
  for i in first_move_index...knowable_moves.length
    #moves.push(Pokemon::Move.new(knowable_moves[i]))
    moves << knowable_moves[i]
  end
  return moves
end

def listPokemonIDs()
  for id in 0..Settings::NB_POKEMON
    pokemon = GameData::Species.get(id).species
    echoln id.to_s + ": " + "\"" + pokemon.to_s + "\"" + ", "
  end
end

def getAllNonLegendaryPokemon()
  list = []
  for i in 1..143
    list.push(i)
  end
  for i in 147..149
    list.push(i)
  end
  for i in 152..242
    list.push(i)
  end
  list.push(246)
  list.push(247)
  list.push(248)
  for i in 252..314
    list.push(i)
  end
  for i in 316..339
    list.push(i)
  end
  for i in 352..377
    list.push(i)
  end
  for i in 382..420
    list.push(i)
  end
  return list
end

def getPokemonEggGroups(species)
  return GameData::Species.get(species).egg_groups
end

def getAbilityIndexFromID(abilityID, fusedPokemon)
  abilityList = fusedPokemon.getAbilityList
  for abilityArray in abilityList #ex: [:CHLOROPHYLL, 0]
    ability = abilityArray[0]
    index = abilityArray[1]
    return index if ability == abilityID
  end
  return 0
end

def getSpecies(dexnum)
  return getPokemon(dexnum.species) if dexnum.is_a?(Pokemon)
  return getPokemon(dexnum)
end

def getPokemon(dexNum)
  if dexNum.is_a?(Integer)
    if dexNum > Settings::NB_POKEMON
      body_id = getBodyID(dexNum)
      head_id = getHeadID(dexNum, body_id)
      pokemon_id = getFusedPokemonIdFromDexNum(body_id, head_id)
    else
      pokemon_id = dexNum
    end
  else
    pokemon_id = dexNum
  end

  return GameData::Species.get(pokemon_id)
end

def CanLearnMove(pokemon, move)
  species = getID(PBSpecies, pokemon)
  return false if species <= 0
  data = load_data("Data/tm.dat")
  return false if !data[move]
  return data[move].any? { |item| item == species }
end

def getID(pbspecies_unused, species)
  if species.is_a?(String)
    return nil
  elsif species.is_a?(Symbol)
    return GameData::Species.get(species).id_number
  elsif species.is_a?(Pokemon)
    id = species.dexNum
  end
end

def pbAddPokemonID(pokemon_id, level = 1, see_form = true, skip_randomize = false)
  return false if !pokemon_id
  skip_randomize = true if $game_switches[SWITCH_CHOOSING_STARTER] #when choosing starters
  if pbBoxesFull?
    pbMessage(_INTL("There's no more room for Pokémon!\1"))
    pbMessage(_INTL("The Pokémon Boxes are full and can't accept any more!"))
    return false
  end
  if pokemon_id.is_a?(Integer) && level.is_a?(Integer)
    pokemon = Pokemon.new(pokemon_id, level)
    species_name = pokemon.speciesName
  end

  #random species if randomized gift pokemon &  wild poke
  if $game_switches[SWITCH_RANDOM_GIFT_POKEMON] && $game_switches[SWITCH_RANDOM_WILD] && !skip_randomize
    tryRandomizeGiftPokemon(pokemon, skip_randomize)
  end

  pbMessage(_INTL("{1} obtained {2}!\\me[Pkmn get]\\wtnp[80]\1", $Trainer.name, species_name))
  pbNicknameAndStore(pokemon)
  $Trainer.pokedex.register(pokemon) if see_form
  return true
end

def pbHasSpecies?(species)
  if species.is_a?(String) || species.is_a?(Symbol)
    id = getID(PBSpecies, species)
  elsif species.is_a?(Pokemon)
    id = species.dexNum
  end
  for pokemon in $Trainer.party
    next if pokemon.isEgg?
    return true if pokemon.dexNum == id
  end
  return false
end

def pbPlayCry(pkmn, volume = 90, pitch = nil)
  GameData::Species.play_cry(pkmn, volume, pitch)
end

def pbCryFrameLength(species, form = 0, pitch = 100)
  return GameData::Species.cry_length(species, form, pitch)
end