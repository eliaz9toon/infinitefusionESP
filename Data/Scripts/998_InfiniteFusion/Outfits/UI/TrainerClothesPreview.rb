class TrainerClothesPreview
  attr_writer :pokeball, :clothes, :hat, :hat2, :hair, :skin_tone, :hair_color, :hat_color,:hat2_color, :clothes_color

  def initialize(x = 0, y = 0, windowed = true, pokeball = nil)
    @playerBitmap = nil
    @playerSprite = nil
    @x_pos = x
    @y_pos = y
    @windowed = windowed

    @pokeball = pokeball
    resetOutfits()
  end

  def set_hat(value,is_secondaryHat=false)
    if is_secondaryHat
      @hat2 = value
    else
      @hat = value
    end
  end

  def set_hat_color(value,is_secondaryHat=false)
    if is_secondaryHat
      @hat2_color = value
    else
      @hat_color = value
    end
  end

  def resetOutfits()
    @clothes = $player.clothes
    @hat = $player.hat
    @hat2 = $player.hat2
    @hair = $player.hair
    @skin_tone = $player.skin_tone
    @hair_color = $player.hair_color
    @hat_color = $player.hat_color
    @hat2_color = $player.hat2_color
    @clothes_color = $player.clothes_color
  end

  def show()
    @playerBitmap = generate_front_trainer_sprite_bitmap(false,
                                                         @pokeball,
                                                         @clothes,
                                                         @hat,@hat2, @hair,
                                                         @skin_tone,
                                                         @hair_color, @hat_color, @clothes_color, @hat2_color)
    initialize_preview()
  end

  def updatePreview()
    erase()
    show()
  end

  def initialize_preview()
    @playerSprite = PictureWindow.new(@playerBitmap)
    @playerSprite.opacity = 0 if !@windowed

    @playerSprite.x = @x_pos
    @playerSprite.y = @y_pos
    @playerSprite.z = 9999
    @playerSprite.update
  end

  def erase()
    @playerSprite.dispose if @playerSprite
  end

end