# frozen_string_literal: true

class Sprite_Character
  attr_accessor :pending_bitmap
  attr_accessor :bitmap_override
  attr_accessor :charbitmap
  alias pokemonEssentials_spriteCharacter_initialize initialize
  def initialize(viewport, character = nil)
    pokemonEssentials_spriteCharacter_initialize(viewport, character)
    checkModifySpriteGraphics(@character) if @character
  end

  def setSpriteToAppearance(trainerAppearance)
    #return if !@charbitmap || !@charbitmap.bitmap
    begin
      new_bitmap = AnimatedBitmap.new(getBaseOverworldSpriteFilename()) #@charbitmap
      new_bitmap.bitmap = generateNPCClothedBitmapStatic(trainerAppearance)
      @bitmap_override = new_bitmap
      updateBitmap
    rescue
    end
  end

  def clearBitmapOverride()
    @bitmap_override = nil
    updateBitmap
  end

  def setSurfingPokemon(pokemonSpecies)
    @surfingPokemon = pokemonSpecies
    @surfbase.setPokemon(pokemonSpecies) if @surfbase
  end

  def updateBitmap
    @manual_refresh = true
  end

  def pbLoadOutfitBitmap(outfitFileName)
    # Construct the file path for the outfit bitmap based on the given value
    #outfitFileName = sprintf("Graphics/Outfits/%s", value)

    # Attempt to load the outfit bitmap
    begin
      outfitBitmap = RPG::Cache.load_bitmap("", outfitFileName)
      return outfitBitmap
    rescue
      return nil
    end
  end

  def generateClothedBitmap()
    return
  end

  def applyDayNightTone()
    if @character.is_a?(Game_Event) && @character.name[/regulartone/i]
      self.tone.set(0, 0, 0, 0)
    else
      pbDayNightTint(self)
    end
  end

  def updateCharacterBitmap
    AnimatedBitmap.new('Graphics/Characters/' + @character_name, @character_hue)
  end

  def should_update?
    return @tile_id != @character.tile_id ||
      @character_name != @character.character_name ||
      @character_hue != @character.character_hue ||
      @oldbushdepth != @character.bush_depth ||
      @manual_refresh
  end

  def refreshOutfit()
    self.pending_bitmap = getClothedPlayerSprite(true)
  end



  def checkModifySpriteGraphics(character)
    return if character == $game_player || !character.name
    if TYPE_EXPERTS_APPEARANCES.keys.include?(character.name.to_sym)
      typeExpert = character.name.to_sym
      setSpriteToAppearance(TYPE_EXPERTS_APPEARANCES[typeExpert])
    end
  end

  def refresh_graphic
    return if !should_update?
    @manual_refresh=false
    @tile_id        = @character.tile_id
    @character_name = @character.character_name
    @character_hue  = @character.character_hue
    @oldbushdepth   = @character.bush_depth
    @charbitmap&.dispose
    @charbitmap = nil
    @bushbitmap&.dispose
    @bushbitmap = nil

    if @tile_id >= 384
      @charbitmap = pbGetTileBitmap(@character.map.tileset_name, @tile_id,
                                    @character_hue, @character.width, @character.height)
      @charbitmapAnimated = false
      @spriteoffset = false
      @cw = Game_Map::TILE_WIDTH * @character.width
      @ch = Game_Map::TILE_HEIGHT * @character.height
      self.src_rect.set(0, 0, @cw, @ch)
      self.ox = @cw / 2
      self.oy = @ch
    elsif @character_name != ""

      @charbitmap = updateCharacterBitmap()

      RPG::Cache.retain("Graphics/Characters/", @character_name, @character_hue) if @character == $game_player
      @charbitmapAnimated = true

      @spriteoffset = @character_name[/fish/i] ||  @character_name[/dive/i] ||  @character_name[/surf/i]

      @cw = @charbitmap.width / 4
      @ch = @charbitmap.height / 4
      self.ox = @cw / 2
    else
      self.bitmap = nil
      @cw = 0
      @ch = 0
      @reflection&.update
    end
    @character.sprite_size = [@cw, @ch]
  end
  def update
    if self.pending_bitmap
      self.bitmap = self.pending_bitmap
      self.pending_bitmap = nil
    end
    return if @character.is_a?(Game_Event) && !@character.should_update?
    super
    refresh_graphic
    #return if !@charbitmap
    @charbitmap.update if @charbitmapAnimated
    bushdepth = @character.bush_depth
    if bushdepth == 0
      if @character == $game_player
        self.bitmap = getClothedPlayerSprite()
      else
        self.bitmap = (@charbitmapAnimated) ? @charbitmap.bitmap : @charbitmap
      end
    else
      @bushbitmap = BushBitmap.new(@charbitmap, (@tile_id >= 384), bushdepth) if !@bushbitmap
      self.bitmap = @bushbitmap.bitmap
    end

    self.visible = !@character.transparent
    if @tile_id == 0
      sx = @character.pattern * @cw
      sy = ((@character.direction - 2) / 2) * @ch
      self.src_rect.set(sx, sy, @cw, @ch)
      self.oy = (@spriteoffset rescue false) ? @ch - 16 : @ch
      self.oy -= @character.bob_height
    end
    if self.visible
      applyDayNightTone()
    end
    this_x = @character.screen_x
    this_x = ((this_x - (Graphics.width / 2)) * TilemapRenderer::ZOOM_X) + (Graphics.width / 2) if TilemapRenderer::ZOOM_X != 1
    self.x = this_x
    this_y = @character.screen_y
    this_y = ((this_y - (Graphics.height / 2)) * TilemapRenderer::ZOOM_Y) + (Graphics.height / 2) if TilemapRenderer::ZOOM_Y != 1
    self.y = this_y
    self.z = @character.screen_z(@ch)
    self.opacity = @character.opacity
    self.blend_type = @character.blend_type
    if @character.animation_id && @character.animation_id != 0
      animation = $data_animations[@character.animation_id]
      animation(animation, true, @character.animation_height || 3, @character.animation_regular_tone || false)
      @character.animation_id = 0
    end
    @reflection&.update
    @surfbase&.update
  end
  # def update
  #   if self.pending_bitmap
  #     self.bitmap = self.pending_bitmap
  #     self.pending_bitmap = nil
  #   end
  #   return if @character.is_a?(Game_Event) && !@character.should_update?
  #   super
  #   if should_update?
  #     @manual_refresh = false
  #     @tile_id = @character.tile_id
  #     @character_name = @character.character_name
  #     @character_hue = @character.character_hue
  #     @oldbushdepth = @character.bush_depth
  #     if @tile_id >= 384
  #       @charbitmap.dispose if @charbitmap
  #       @charbitmap = pbGetTileBitmap(@character.map.tileset_name, @tile_id,
  #                                     @character_hue, @character.width, @character.height)
  #       @charbitmapAnimated = false
  #       @bushbitmap.dispose if @bushbitmap
  #       @bushbitmap = nil
  #       @spriteoffset = false
  #       @cw = Game_Map::TILE_WIDTH * @character.width
  #       @ch = Game_Map::TILE_HEIGHT * @character.height
  #       self.src_rect.set(0, 0, @cw, @ch)
  #       self.ox = @cw / 2
  #       self.oy = @ch
  #       @character.sprite_size = [@cw, @ch]
  #     else
  #       @charbitmap.dispose if @charbitmap
  #
  #       @charbitmap = updateCharacterBitmap()
  #       @charbitmap = @bitmap_override.clone if @bitmap_override
  #
  #       RPG::Cache.retain('Graphics/Characters/', @character_name, @character_hue) if @charbitmapAnimated = true
  #       @bushbitmap.dispose if @bushbitmap
  #       @bushbitmap = nil
  #       #@spriteoffset = @character_name[/offset/i]
  #       @spriteoffset = @character_name[/fish/i] || @character_name[/dive/i] || @character_name[/surf/i]
  #       @cw = @charbitmap.width / 4
  #       @ch = @charbitmap.height / 4
  #       self.ox = @cw / 2
  #       @character.sprite_size = [@cw, @ch]
  #     end
  #   end
  #   @charbitmap.update if @charbitmapAnimated
  #   bushdepth = @character.bush_depth
  #   if bushdepth == 0
  #     if @character == $game_player
  #       self.bitmap = getClothedPlayerSprite() #generateClothedBitmap()
  #     else
  #       self.bitmap = (@charbitmapAnimated) ? @charbitmap.bitmap : @charbitmap
  #     end
  #   else
  #     @bushbitmap = BushBitmap.new(@charbitmap, (@tile_id >= 384), bushdepth) if !@bushbitmap
  #     self.bitmap = @bushbitmap.bitmap
  #   end
  #   self.visible = !@character.transparent
  #   if @tile_id == 0
  #     sx = @character.pattern * @cw
  #     sy = ((@character.direction - 2) / 2) * @ch
  #     self.src_rect.set(sx, sy, @cw, @ch)
  #     self.oy = (@spriteoffset rescue false) ? @ch - 16 : @ch
  #     self.oy -= @character.bob_height
  #   end
  #   if self.visible
  #     applyDayNightTone()
  #   end
  #   self.x = @character.screen_x
  #   self.y = @character.screen_y
  #   self.z = @character.screen_z(@ch)
  #   #    self.zoom_x     = Game_Map::TILE_WIDTH / 32.0
  #   #    self.zoom_y     = Game_Map::TILE_HEIGHT / 32.0
  #   self.opacity = @character.opacity
  #   self.blend_type = @character.blend_type
  #   #    self.bush_depth = @character.bush_depth
  #   if @character.animation_id != 0
  #     animation = $data_animations[@character.animation_id]
  #     animation(animation, true)
  #     @character.animation_id = 0
  #   end
  #   @reflection.update if @reflection
  #   @surfbase.update if @surfbase
  # end


end
