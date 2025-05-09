# frozen_string_literal: true

class Game_Temp
  attr_accessor :unimportedSprites
  attr_accessor :nb_imported_sprites
  attr_accessor :loading_screen
  attr_accessor :custom_sprites_list
  attr_accessor :base_sprites_list
  attr_accessor :forced_alt_sprites

  alias pokemonEssentials_GameTemp_original_initialize initialize
  def initialize
    pokemonEssentials_GameTemp_original_initialize
    @custom_sprites_list    ={}
    @base_sprites_list    ={}
  end
end
