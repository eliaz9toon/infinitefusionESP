
SWITCH_GYM_RANDOM_EACH_BATTLE=668
SWITCH_NO_BUMP_SOUND=108
SWITCH_HAS_PREVIOUS_SAVEFILE = 972
VARIABLE_BATTLE_STYLE = 199

def setup_new_game()
  set_new_game_switches
  set_new_game_variables
  setup_player
  setup_randomizer
end

def set_new_game_switches
  $game_switches[SWITCH_GYM_RANDOM_EACH_BATTLE] = true
  $game_switches[SWITCH_NO_BUMP_SOUND] = true
  $game_switches[SWITCH_HAS_PREVIOUS_SAVEFILE]= SaveData.exists?
end

def set_new_game_variables
  pbSet(VARIABLE_BATTLE_STYLE,0)
end

def setup_player
  $player.has_running_shoes=true
  #pbChangePlayer(0)
end

def setup_randomizer
  #init the random items hash even if  it's not used

  #pbShuffleItems
  #pbShuffleTMs
end