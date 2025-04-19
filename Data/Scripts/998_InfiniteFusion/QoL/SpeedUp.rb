# Name         = Delta Speed Up
# Version      = 1.2
# Essentials   = 21.1
# Requires     = v21.1 Hotfixes
# Website      = https://reliccastle.com/threads/7145
# Credits      = Marin (og speed up script), Phantombass (19.1 version), Mashirosakura, Golisopod User, D0vid (v21.1 version), Manurocker95(bug fixes)

SPEED_UP_TYPE_HOLD = 0
SPEED_UP_TYPE_TOGGLE = 1

#===============================================================================#
# Whether the options menu shows the speed up settings (true by default)
#===============================================================================#
module Settings
  SPEED_OPTIONS = true
end
#===============================================================================#
# Speed-up config
#===============================================================================#
$GameSpeed = 0
$CanToggle = true
$RefreshEventsForTurbo = false
#===============================================================================#
# Set $CanToggle depending on the saved setting
#===============================================================================#
module Game
  class << self
    alias_method :original_load, :load unless method_defined?(:original_load)
  end

  def self.load(save_data)
    original_load(save_data)
    # echoln "UNSCALED #{System.unscaled_uptime} * #{SPEEDUP_STAGES[$GameSpeed]} - #{$GameSpeed}"
    $CanToggle = true #$PokemonSystem.only_speedup_battles == 0
  end
end
#===============================================================================#
# Handle incrementing speed stages if $CanToggle allows it
#===============================================================================#
module Input
  def self.update
    update_KGC_ScreenCapture
    pbScreenCapture if trigger?(Input::F8)

    if $PokemonSystem && $PokemonSystem.speedup_type == SPEED_UP_TYPE_HOLD
      speed_up_hold()
    else
      if $CanToggle && trigger?(Input::AUX1)
        speed_up_toggle()
      end
    end
  end

  def self.speed_up_hold
    if Input.press?(Input::AUX1) && $CanToggle
      $PokemonSystem.speedup_speed = 0 if !$PokemonSystem.speedup_speed || $PokemonSystem.speedup_speed == 0
      $GameSpeed = $PokemonSystem.speedup_speed
      $PokemonSystem.battle_speed = $GameSpeed
    else
      $GameSpeed = 0
    end
  end

  def self.speed_up_toggle
    $PokemonSystem.speedup_enabled = !$PokemonSystem.speedup_enabled
    pbPlayDecisionSE
    if $PokemonSystem.speedup_enabled
      $GameSpeed = $PokemonSystem.speedup_speed
      $PokemonSystem.battle_speed = $GameSpeed if $PokemonSystem && $PokemonSystem.only_speedup_battles == 1
      $RefreshEventsForTurbo = true
    else
      $GameSpeed = 0
    end
  end

end
#===============================================================================#
# Return System.Uptime with a multiplier to create an alternative timeline
#===============================================================================#
module System
  class << self
    alias_method :unscaled_uptime, :uptime unless method_defined?(:unscaled_uptime)
  end

  def self.uptime
    $GameSpeed = 1 if !$GameSpeed || $GameSpeed < 1
    return $GameSpeed * unscaled_uptime
  end
end
#===============================================================================#
# Event handlers for in-battle speed-up restrictions
#===============================================================================#
EventHandlers.add(:on_start_battle, :start_speedup, proc {
  $CanToggle = false
  $GameSpeed = $PokemonSystem.battle_speed if $PokemonSystem.only_speedup_battles == 1
})
EventHandlers.add(:on_end_battle, :stop_speedup, proc {
  $GameSpeed = 0 if $PokemonSystem.only_speedup_battles == 1
  $CanToggle = true if $PokemonSystem.only_speedup_battles == 0
})

#===============================================================================#
# Can only change speed in battle during command phase (prevents weird animation glitches)
#===============================================================================#
class Battle
  alias_method :original_pbCommandPhase, :pbCommandPhase unless method_defined?(:original_pbCommandPhase)

  def pbCommandPhase
    $CanToggle = true
    original_pbCommandPhase
    $CanToggle = false
  end
end

#===============================================================================#
# Fix for consecutive battle soft-lock glitch
#===============================================================================#
alias :original_pbBattleOnStepTaken :pbBattleOnStepTaken

def pbBattleOnStepTaken(repel_active)
  return if $game_temp.in_battle
  original_pbBattleOnStepTaken(repel_active)
end

class Game_Event < Game_Character
  def pbGetInterpreter
    return @interpreter
  end

  def pbResetInterpreterWaitCount
    @interpreter.pbRefreshWaitCount if @interpreter && @trigger == 4
  end
end

class Interpreter
  def pbRefreshWaitCount
    @wait_count = 0
    @wait_start = System.uptime
  end
end

class Window_AdvancedTextPokemon < SpriteWindow_Base
  def pbResetWaitCounter
    @wait_timer_start = nil
    @waitcount = 0
    @display_last_updated = nil
  end
end

$CurrentMsgWindow = nil;

def pbMessage(message, commands = nil, cmdIfCancel = 0, skin = nil, defaultCmd = 0, &block)
  ret = 0
  msgwindow = pbCreateMessageWindow(nil, skin)
  $CurrentMsgWindow = msgwindow

  if commands
    ret = pbMessageDisplay(msgwindow, message, true,
                           proc { |msgwndw|
                             next Kernel.pbShowCommands(msgwndw, commands, cmdIfCancel, defaultCmd, &block)
                           }, &block)
  else
    pbMessageDisplay(msgwindow, message, &block)
  end
  pbDisposeMessageWindow(msgwindow)
  $CurrentMsgWindow = nil
  Input.update
  return ret
end

#===============================================================================#
# Fix for scrolling fog speed
#===============================================================================#
class Game_Map
  alias_method :original_update, :update unless method_defined?(:original_update)

  def update
    if $RefreshEventsForTurbo
      if $game_map&.events
        $game_map.events.each_value { |event| event.pbResetInterpreterWaitCount }
      end

      @scroll_timer_start = System.uptime / $GameSpeed if (@scroll_distance_x || 0) != 0 || (@scroll_distance_y || 0) != 0

      $CurrentMsgWindow.pbResetWaitCounter if $game_temp.message_window_showing && $CurrentMsgWindow

      $RefreshEventsForTurbo = false
    end

    temp_timer = @fog_scroll_last_update_timer
    @fog_scroll_last_update_timer = System.uptime # Don't scroll in the original update method
    original_update
    @fog_scroll_last_update_timer = temp_timer
    update_fog
  end

  def update_fog
    uptime_now = System.unscaled_uptime
    @fog_scroll_last_update_timer = uptime_now unless @fog_scroll_last_update_timer
    speedup_mult = $PokemonSystem.only_speedup_battles == 1 ? 1 : $GameSpeed
    scroll_mult = (uptime_now - @fog_scroll_last_update_timer) * 5 * speedup_mult
    @fog_ox -= @fog_sx * scroll_mult
    @fog_oy -= @fog_sy * scroll_mult
    @fog_scroll_last_update_timer = uptime_now
  end
end

#===============================================================================#
# Fix for animation index crash
#===============================================================================#
class SpriteAnimation
  def update_animation
    new_index = ((System.uptime - @_animation_timer_start) / @_animation_time_per_frame).to_i
    if new_index >= @_animation_duration
      dispose_animation
      return
    end
    quick_update = (@_animation_index == new_index)
    @_animation_index = new_index
    frame_index = @_animation_index
    current_frame = @_animation.frames[frame_index]
    unless current_frame
      dispose_animation
      return
    end
    cell_data = current_frame.cell_data
    position = @_animation.position
    animation_set_sprites(@_animation_sprites, cell_data, position, quick_update)
    return if quick_update
    @_animation.timings.each do |timing|
      next if timing.frame != frame_index
      animation_process_timing(timing, @_animation_hit)
    end
  end
end

#===============================================================================#
# PokemonSystem Accessors
#===============================================================================#
class PokemonSystem
  alias_method :original_initialize, :initialize unless method_defined?(:original_initialize)
  attr_accessor :only_speedup_battles
  attr_accessor :battle_speed

  attr_accessor :speedup_type
  attr_accessor :speedup_speed
  attr_accessor :speedup_enabled

  def initialize
    original_initialize
    @only_speedup_battles = 0 # Speed up setting (0=always, 1=battle_only)
    @battle_speed = 0 # Depends on the SPEEDUP_STAGES array size
    @speedup_type = SPEED_UP_TYPE_HOLD
    @speedup_enabled = false
  end
end

#===============================================================================#
# Options menu handlers
#===============================================================================#
MenuHandlers.add(:options_menu, :only_speedup_battles, {
  "name" => _INTL("Speed Up Settings"),
  "order" => 25,
  "type" => EnumOption,
  "parameters" => [_INTL("Always"), _INTL("Only Battles")],
  "description" => _INTL("Choose which aspect is sped up."),
  "get_proc" => proc { next $PokemonSystem.only_speedup_battles },
  "set_proc" => proc { |value, scene|
    $GameSpeed = 0 if value != $PokemonSystem.only_speedup_battles
    $PokemonSystem.only_speedup_battles = value
    $CanToggle = value == 0
  }
})

MenuHandlers.add(:options_menu, :speedup_type, {
  "name" => _INTL("Speed-up type"),
  "order" => 25,
  "type" => EnumOption,
  "parameters" => [_INTL("Hold"), _INTL("Toggle")],
  "description" => _INTL("Pick how you want speed-up to be enabled."),
  "get_proc" => proc { next $PokemonSystem.speedup_type },
  "set_proc" => proc { |value, scene|
    $PokemonSystem.speedup_type = value
  }
})

MenuHandlers.add(:options_menu, :speedup_speed, {
  "name" => _INTL("Speed-up speed"),
  "order" => 27,
  "type" => SliderOption,
  "parameters" => [0, 10, 0.5], # [minimum_value, maximum_value, interval]
  "description" => _INTL("Sets by how much to speed up the game."),
  "get_proc" => proc { next $PokemonSystem.speedup_speed },
  "set_proc" => proc { |value, scene|
    next if $PokemonSystem.speedup_speed == value
    $PokemonSystem.speedup_speed = value
  }
})

# MenuHandlers.add(:options_menu, :battle_speed, {
#   "name" => _INTL("Battle Speed"),
#   "order" => 26,
#   "type" => EnumOption,
#   "parameters" => [_INTL("x#{SPEEDUP_STAGES[0]}"), _INTL("x#{SPEEDUP_STAGES[1]}"), _INTL("x#{SPEEDUP_STAGES[2]}")],
#   "description" => _INTL("Choose the battle speed when the battle speed-up is set to 'Battles Only'."),
#   "get_proc" => proc { next $PokemonSystem.battle_speed },
#   "set_proc" => proc { |value, scene|
#     $PokemonSystem.battle_speed = value
#   }
# })