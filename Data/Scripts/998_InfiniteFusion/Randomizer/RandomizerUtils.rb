# frozen_string_literal: true

def setRivalStarter(starterIndex1, starterIndex2)
  starter1 = obtainStarter(starterIndex1)
  starter2 = obtainStarter(starterIndex2)

  ensureRandomHashInitialized()
  if $game_switches[SWITCH_RANDOM_WILD_TO_FUSION] # if fused starters, only take index 1
    starter = obtainStarter(starterIndex1)
  else
    starter_body = starter1.id_number
    starter_head = starter2.id_number
    starter = getFusionSpecies(starter_body, starter_head).id_number
  end
  if $game_switches[SWITCH_RANDOM_STARTER_FIRST_STAGE]
    starterSpecies = GameData::Species.get(starter)
    starter = GameData::Species.get(starterSpecies.get_baby_species(false)).id_number
  end
  pbSet(VAR_RIVAL_STARTER, starter)
  $game_switches[SWITCH_DEFINED_RIVAL_STARTER] = true
  return starter
end

def ensureRandomHashInitialized()
  if $PokemonGlobal.psuedoBSTHash == nil
    psuedoHash = Hash.new
    for i in 0..NB_POKEMON
      psuedoHash[i] = i
    end
    $PokemonGlobal.psuedoBSTHash = psuedoHash
  end
end


def displayRandomizerErrorMessage()
  Kernel.pbMessage(_INTL("The randomizer has encountered an error. You should try to re-randomize your game as soon as possible."))
  Kernel.pbMessage(_INTL("You can do this on the top floor of Pokémon Centers."))
end


def validate_regirock_steel_puzzle()
  expected_pressed_switches = [75, 77, 74, 68, 73, 69]
  expected_unpressed_switches = [76, 67, 72, 70]
  switch_ids = [75, 77, 76, 67,
                74, 68,
                73, 72, 70, 69]

  pressed_switches = []
  unpressed_switches = []
  switch_ids.each do |switch_id|
    is_pressed = pbGetSelfSwitch(switch_id, "A")
    if is_pressed
      pressed_switches << switch_id
    else
      unpressed_switches << switch_id
    end
  end

  for event_id in switch_ids
    is_pressed = pbGetSelfSwitch(event_id, "A")
    return false if !is_pressed && expected_pressed_switches.include?(event_id)
    return false if is_pressed && expected_unpressed_switches.include?(event_id)
  end
  return true
end

def registeel_ice_press_switch(letter)
  order = pbGet(VAR_REGI_PUZZLE_SWITCH_PRESSED)
  solution = "ssBSBGG" # GGSBBss"
  registeel_ice_reset_switches() if !order.is_a?(String)
  order << letter
  pbSet(VAR_REGI_PUZZLE_SWITCH_PRESSED, order)
  if order == solution
    echoln "OK"
    pbSEPlay("Evolution start", nil, 130)
  elsif order.length >= solution.length
    registeel_ice_reset_switches()
  end
  echoln order
end

def registeel_ice_reset_switches()
  switches_events = [66, 78, 84, 85, 86, 87, 88]
  switches_events.each do |switch_id|
    pbSetSelfSwitch(switch_id, "A", false)
    echoln "reset" + switch_id.to_s
  end
  pbSet(VAR_REGI_PUZZLE_SWITCH_PRESSED, "")
end

def unpress_all_regirock_steel_switches()
  switch_ids = [75, 77, 76, 67, 74, 68, 73, 72, 70, 69]
  regi_map = 813
  switch_ids.each do |event_id|
    pbSetSelfSwitch(event_id, "A", false, regi_map)
  end
end

# Solution: position of boulders [[x,y],[x,y],etc.]
def validate_regirock_ice_puzzle(solution)
  for boulder_position in solution
    x = boulder_position[0]
    y = boulder_position[1]
    # echoln ""
    # echoln x.to_s + ", " + y.to_s
    # echoln $game_map.event_at_position(x,y)
    return false if !$game_map.event_at_position(x, y)
  end
  echoln "all boulders in place"
  return true
end