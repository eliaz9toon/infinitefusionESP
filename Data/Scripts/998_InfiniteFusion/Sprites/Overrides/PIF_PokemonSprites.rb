# frozen_string_literal: true

class PokemonSprite

  def setPokemonBitmapFromId(id, back = false, shiny = false, bodyShiny = false, headShiny = false,spriteform_body=nil,spriteform_head=nil)
    @_iconbitmap.dispose if @_iconbitmap
    @_iconbitmap = GameData::Species.sprite_bitmap_from_pokemon_id(id, back, shiny, bodyShiny, headShiny)
    self.bitmap = (@_iconbitmap) ? @_iconbitmap.bitmap : nil
    self.color = Color.new(0, 0, 0, 0)
    changeOrigin
  end

end