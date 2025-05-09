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

def find_newer_available_version
  latest_Version = fetch_latest_game_version
  return nil if !latest_Version
  return nil if is_higher_version(Settings::GAME_VERSION_NUMBER, latest_Version)
  return latest_Version
end

def is_higher_version(gameVersion, latestVersion)
  gameVersion_parts = gameVersion.split('.').map(&:to_i)
  latestVersion_parts = latestVersion.split('.').map(&:to_i)

  # Compare each part of the version numbers from left to right
  gameVersion_parts.each_with_index do |part, i|
    return true if (latestVersion_parts[i].nil? || part > latestVersion_parts[i])
    return false if part < latestVersion_parts[i]
  end
  return latestVersion_parts.length <= gameVersion_parts.length
end

def get_current_game_difficulty
  return :EASY if $game_switches[SWITCH_GAME_DIFFICULTY_EASY]
  return :HARD if $game_switches[SWITCH_GAME_DIFFICULTY_HARD]
  return :NORMAL
end

def get_difficulty_text
  if $game_switches[SWITCH_GAME_DIFFICULTY_EASY]
    return "Easy"
  elsif $game_switches[SWITCH_GAME_DIFFICULTY_HARD]
    return "Hard"
  else
    return "Normal"
  end
end

def getCurrentLevelCap()
  current_max_level = Settings::LEVEL_CAPS[$Trainer.badge_count]
  current_max_level *= Settings::HARD_MODE_LEVEL_MODIFIER if $game_switches[SWITCH_GAME_DIFFICULTY_HARD]
  return current_max_level
end

def pokemonExceedsLevelCap(pokemon)
  return false if $Trainer.badge_count >= Settings::NB_BADGES
  current_max_level = getCurrentLevelCap()
  return pokemon.level >= current_max_level
end

def getLatestSpritepackDate()
  return Time.new(Settings::NEWEST_SPRITEPACK_YEAR, Settings::NEWEST_SPRITEPACK_MONTH)
end

def new_spritepack_was_released()
  current_spritepack_date = $PokemonGlobal.current_spritepack_date
  latest_spritepack_date = getLatestSpritepackDate()
  if !current_spritepack_date || (current_spritepack_date < latest_spritepack_date)
    $PokemonGlobal.current_spritepack_date = latest_spritepack_date
    return true
  end
  return false
end

def pbGetSelfSwitch(eventId, switch)
  return $game_self_switches[[@map_id, eventId, switch]]
end