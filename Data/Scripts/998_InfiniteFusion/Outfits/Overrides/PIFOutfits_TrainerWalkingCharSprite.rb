
class TrainerWalkingCharSprite

  alias pokemonEssentials_TrainerWalkingCharSprite_initialize initialize
  def initialize(charset,viewport=nil,trainer=nil)
    @trainer=trainer
    pokemonEssentials_TrainerWalkingCharSprite_initialize(charset,viewport)

  end
  def charset=(value)
    isPlayerCharacter = value == "walk" #todo: passe de l'ours à corriger
    echoln value
    @animbitmap&.dispose
    @animbitmap = nil
    bitmapFileName = sprintf("Graphics/Characters/%s", value)
    @charset = pbResolveBitmap(bitmapFileName)
    if @charset
      if isPlayerCharacter
        outfit_bitmap = _INTL("Graphics/Characters/players/outfits/{1}_{2}",value,$Trainer.outfit) if $Trainer && $Trainer.outfit
        @trainer = $Trainer if !@trainer
        @animbitmap = AnimatedBitmap.new(@charset)
        @animbitmap.bitmap = generateClothedBitmapStatic(@trainer)
        @animbitmap.bitmap.blt(0, 0, outfit_bitmap, outfit_bitmap.rect) if pbResolveBitmap(outfit_bitmap)
      else
        @animbitmap = AnimatedBitmap.new(@charset)
      end
      self.bitmap = @animbitmap.bitmap
      self.src_rect.set(0, 0, self.bitmap.width / 4, self.bitmap.height / 4)
    else
      self.bitmap = nil
    end
  end
end



class UI::LoadContinuePanel
  def initialize_player_sprite
    meta = GameData::PlayerMetadata.get(@save_data[:player].character_ID)
    filename = pbGetPlayerCharset(meta.walk_charset, @save_data[:player], true)
    @sprites[:player] = TrainerWalkingCharSprite.new(filename, @viewport,@save_data[:player])
    if !@sprites[:player].bitmap
      raise _INTL("Overrides character {1}'s walking charset was not found (filename: \"{2}\").",
                  @save_data[:player].character_ID, filename)
    end
    @sprites[:player].x = 48 - (@sprites[:player].bitmap.width / 8)
    @sprites[:player].y = 72 - (@sprites[:player].bitmap.height / 8)
    @sprites[:player].z = 1
    record_values(:player)
  end

end