# frozen_string_literal: true

# todo: implement
def getMappedKeyFor(internalKey)

  keybinding_fileName = "keybindings.mkxp1"
  path = System.data_directory + keybinding_fileName

  parse_keybindings(path)

  # echoln Keybindings.new(path).bindings
end



def formatNumberToString(number)
  return number.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
end

def playCry(pokemonSpeciesSymbol)
  species = GameData::Species.get(pokemonSpeciesSymbol).species
  GameData::Species.play_cry_from_species(species)
end

# Get difficulty for displaying in-game
def getDisplayDifficulty
  if $game_switches[SWITCH_GAME_DIFFICULTY_EASY] || $player.lowest_difficulty <= 0
    return getDisplayDifficultyFromIndex(0)
  elsif $player.lowest_difficulty <= 1
    return getDisplayDifficultyFromIndex(1)
  elsif $game_switches[SWITCH_GAME_DIFFICULTY_HARD]
    return getDisplayDifficultyFromIndex(2)
  else
    return getDisplayDifficultyFromIndex(1)
  end
end

def getDisplayDifficultyFromIndex(difficultyIndex)
  return "Easy" if difficultyIndex == 0
  return "Normal" if difficultyIndex == 1
  return "Hard" if difficultyIndex == 2
  return "???"
end

def getGameModeFromIndex(index)
  return "Classic" if index == 0
  return "Random" if index == 1
  return "Remix" if index == 2
  return "Expert" if index == 3
  return "Species" if index == 4
  return "Debug" if index == 5
  return ""
end

def openUrlInBrowser(url = "")
  begin
    # Open the URL in the default web browser
    system("xdg-open", url) || system("open", url) || system("start", url)
  rescue
    Input.clipboard = url
    pbMessage("The game could not open the link in the browser")
    pbMessage("The link has been copied to your clipboard instead")
  end
end

def clearAllSelfSwitches(mapID, switch = "A", newValue = false)
  map = $MapFactory.getMap(mapID, false)
  map.events.each { |event_array|
    event_id = event_array[0]
    pbSetSelfSwitch(event_id, switch, newValue, mapID)
  }
end


def isTuesdayNight()
  day = getDayOfTheWeek()
  hour = pbGetTimeNow().hour
  echoln hour
  return (day == :TUESDAY && hour >= 20) || (day == :WEDNESDAY && hour < 5)
end


def setDifficulty(index)
  $player.selected_difficulty = index
  case index
  when 0 # EASY
    $game_switches[SWITCH_GAME_DIFFICULTY_EASY] = true
    $game_switches[SWITCH_GAME_DIFFICULTY_HARD] = false
  when 1 # NORMAL
    $game_switches[SWITCH_GAME_DIFFICULTY_EASY] = false
    $game_switches[SWITCH_GAME_DIFFICULTY_HARD] = false
  when 2 # HARD
    $game_switches[SWITCH_GAME_DIFFICULTY_EASY] = false
    $game_switches[SWITCH_GAME_DIFFICULTY_HARD] = true
  end
end

# Old menu for changing difficulty - unused
def change_game_difficulty(down_only = false)
  message = "The game is currently on " + get_difficulty_text() + " difficulty."
  pbMessage(message)

  choice_easy = "Easy"
  choice_normal = "Normal"
  choice_hard = "Hard"
  choice_cancel = "Cancel"

  available_difficulties = []
  currentDifficulty = get_current_game_difficulty
  if down_only
    if currentDifficulty == :HARD
      available_difficulties << choice_hard
      available_difficulties << choice_normal
      available_difficulties << choice_easy
    elsif currentDifficulty == :NORMAL
      available_difficulties << choice_normal
      available_difficulties << choice_easy
    elsif currentDifficulty == :EASY
      available_difficulties << choice_easy
    end
  else
    available_difficulties << choice_easy
    available_difficulties << choice_normal
    available_difficulties << choice_hard
  end
  available_difficulties << choice_cancel
  index = pbMessage("Select a new difficulty", available_difficulties, available_difficulties[-1])
  choice = available_difficulties[index]
  case choice
  when choice_easy
    $game_switches[SWITCH_GAME_DIFFICULTY_EASY] = true
    $game_switches[SWITCH_GAME_DIFFICULTY_HARD] = false
  when choice_normal
    $game_switches[SWITCH_GAME_DIFFICULTY_EASY] = false
    $game_switches[SWITCH_GAME_DIFFICULTY_HARD] = false
  when choice_hard
    $game_switches[SWITCH_GAME_DIFFICULTY_EASY] = false
    $game_switches[SWITCH_GAME_DIFFICULTY_HARD] = true
  when choice_cancel
    return
  end

  message = "The game is currently on " + get_difficulty_text() + " difficulty."
  pbMessage(message)
end