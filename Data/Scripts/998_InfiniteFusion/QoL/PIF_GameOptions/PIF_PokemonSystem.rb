# frozen_string_literal: true

class PokemonSystem
  attr_accessor :quicksurf
  attr_accessor :level_caps
  attr_accessor :battle_type
  attr_accessor :download_sprites
  attr_accessor :speedup
  attr_accessor :speedup_speed
  attr_accessor :max_nb_sprites_download
  attr_accessor :on_mobile
  attr_accessor :type_icons
  attr_accessor :use_generated_dex_entries
  attr_accessor :use_custom_eggs

  unless method_defined?(:initialize_with_new_options)
    alias_method :initialize_with_new_options, :initialize

    def initialize
      initialize_with_new_options
      @quicksurf = 0
      @battle_type = 0
      @download_sprites = 0
      @max_nb_sprites_download = 5
      @on_mobile = false
      @type_icons = true
      @use_generated_dex_entries = true
      @use_custom_eggs = true
    end
  end
end
