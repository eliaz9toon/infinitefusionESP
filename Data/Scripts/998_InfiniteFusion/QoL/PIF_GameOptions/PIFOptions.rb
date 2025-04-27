
#TODO

# attr_accessor :quicksurf
# attr_accessor :level_caps
# attr_accessor :battle_type
# attr_accessor :download_sprites
# attr_accessor :speedup
# attr_accessor :speedup_speed
# attr_accessor :max_nb_sprites_download
# attr_accessor :on_mobile
# attr_accessor :type_icons
# attr_accessor :use_generated_dex_entries
# attr_accessor :use_custom_eggs
#
#
#
# #===============================================================================#
# # Options menu handlers
# #===============================================================================#
# MenuHandlers.add(:options_menu, :only_speedup_battles, {
#   "name" => _INTL("Speed Up Settings"),
#   "order" => 25,
#   "type" => EnumOption,
#   "parameters" => [_INTL("Always"), _INTL("Only Battles")],
#   "description" => _INTL("Choose which aspect is sped up."),
#   "get_proc" => proc { next $PokemonSystem.only_speedup_battles },
#   "set_proc" => proc { |value, scene|
#     $GameSpeed = 0 if value != $PokemonSystem.only_speedup_battles
#     $PokemonSystem.only_speedup_battles = value
#     $CanToggle = value == 0
#   }
# })
#
# MenuHandlers.add(:options_menu, :speedup_type, {
#   "name" => _INTL("Speed-up type"),
#   "order" => 25,
#   "type" => EnumOption,
#   "parameters" => [_INTL("Hold"), _INTL("Toggle")],
#   "description" => _INTL("Pick how you want speed-up to be enabled."),
#   "get_proc" => proc { next $PokemonSystem.speedup_type },
#   "set_proc" => proc { |value, scene|
#     $PokemonSystem.speedup_type = value
#   }
# })
#
# MenuHandlers.add(:options_menu, :speedup_speed, {
#   "name" => _INTL("Speed-up speed"),
#   "order" => 27,
#   "type" => SliderOption,
#   "parameters" => [0, 10, 0.5], # [minimum_value, maximum_value, interval]
#   "description" => _INTL("Sets by how much to speed up the game."),
#   "get_proc" => proc { next $PokemonSystem.speedup_speed },
#   "set_proc" => proc { |value, scene|
#     next if $PokemonSystem.speedup_speed == value
#     $PokemonSystem.speedup_speed = value
#   }
# })# frozen_string_literal: true
#
