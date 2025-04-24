class Player < Trainer
  attr_accessor :skin_tone
  attr_accessor :clothes
  attr_accessor :hat
  attr_accessor :hat2

  attr_accessor :hair
  attr_accessor :hair_color
  attr_accessor :hat_color
  attr_accessor :hat2_color

  attr_accessor :clothes_color
  attr_accessor :unlocked_clothes
  attr_accessor :unlocked_hats
  attr_accessor :unlocked_hairstyles
  attr_accessor :unlocked_card_backgrounds

  attr_accessor :dyed_hats
  attr_accessor :dyed_clothes

  attr_accessor :favorite_hat
  attr_accessor :favorite_hat2

  attr_accessor :favorite_clothes

  attr_accessor :last_worn_outfit
  attr_accessor :last_worn_hat
  attr_accessor :last_worn_hat2

  attr_accessor :surfing_pokemon

  attr_accessor :card_background
  attr_accessor :unlocked_card_backgrounds

  attr_accessor :seen_qmarks_sprite

  attr_accessor :beat_league
  attr_accessor :new_game_plus_unlocked

  def last_worn_outfit
    if !@last_worn_outfit
      if pbGet(VAR_TRAINER_GENDER) == GENDER_MALE
        @last_worn_outfit = DEFAULT_OUTFIT_MALE
      else
        @last_worn_outfit = DEFAULT_OUTFIT_FEMALE
      end
    end
    return @last_worn_outfit
  end

  def last_worn_hat(is_secondary = false)
    return is_secondary ? @last_worn_hat2 : @last_worn_hat
  end

  def set_last_worn_hat(value, is_secondary = false)
    if is_secondary
      @last_worn_hat = value
    else
      @last_worn_hat = value
    end
  end

  def last_worn_hat2
    return @last_worn_hat2
  end

  def outfit=(value)
    @outfit = value
  end

  def favorite_hat(is_secondary = false)
    return is_secondary ? @favorite_hat2 : @favorite_hat
  end

  # todo change to set_favorite_hat(value,is_secondary=false)
  def set_favorite_hat(value, is_secondary = false)
    if is_secondary
      @favorite_hat = value
    else
      @favorite_hat2 = value
    end
  end

  def hat_color(is_secondary = false)
    return is_secondary ? @hat2_color : @hat_color
  end

  def hat(is_secondary = false)
    return is_secondary ? @hat2 : @hat
  end

  def set_hat(value, is_secondary = false)
    if value.is_a?(Symbol)
      value = HATS[value].id
    end
    if is_secondary
      @hat2 = value
    else
      @hat = value
    end
    refreshPlayerOutfit()
  end

  # todo : refactor to always use set_hat instead
  def hat=(value)
    if value.is_a?(Symbol)
      value = HATS[value].id
    end
    @hat = value
    refreshPlayerOutfit()
  end

  # todo : refactor to always use set_hat instead
  def hat2=(value)
    if value.is_a?(Symbol)
      value = HATS[value].id
    end
    @hat2 = value
    refreshPlayerOutfit()
  end

  def hair=(value)
    if value.is_a?(Symbol)
      value = HAIRSTYLES[value].id
    end
    @hair = value
    refreshPlayerOutfit()
  end

  def clothes=(value)
    if value.is_a?(Symbol)
      value = OUTFITS[value].id
    end
    @clothes = value
    refreshPlayerOutfit()
  end

  def clothes_color=(value)
    @clothes_color = value
    $Trainer.dyed_clothes = {} if !$Trainer.dyed_clothes
    $Trainer.dyed_clothes[@clothes] = value if value
    refreshPlayerOutfit()
  end

  def set_hat_color(value, is_secondary = false)
    if is_secondary
      @hat2_color = value
    else
      @hat_color = value
    end
    $Trainer.dyed_hats = {} if !$Trainer.dyed_hats
    worn_hat = is_secondary ? @hat2 : @hat
    $Trainer.dyed_hats[worn_hat] = value if value
    refreshPlayerOutfit()
  end

  def hat_color=(value)
    @hat_color = value
    $Trainer.dyed_hats = {} if !$Trainer.dyed_hats
    worn_hat = @hat
    $Trainer.dyed_hats[worn_hat] = value if value
    refreshPlayerOutfit()
  end

  def hat2_color=(value)
    @hat2_color = value
    $Trainer.dyed_hats = {} if !$Trainer.dyed_hats
    worn_hat = @hat2
    $Trainer.dyed_hats[worn_hat] = value if value
    refreshPlayerOutfit()
  end

  def unlock_clothes(outfitID, silent = false)
    update_global_clothes_list()
    outfit = $PokemonGlobal.clothes_data[outfitID]
    @unlocked_clothes = [] if !@unlocked_clothes
    @unlocked_clothes << outfitID if !@unlocked_clothes.include?(outfitID)

    if !silent
      filename = getTrainerSpriteOutfitFilename(outfitID)
      name = outfit ? outfit.name : outfitID
      unlock_outfit_animation(filename, name)
    end
  end

  def unlock_hat(hatID, silent = false)
    update_global_hats_list()

    hat = $PokemonGlobal.hats_data[hatID]
    @unlocked_hats = [] if !@unlocked_hats
    @unlocked_hats << hatID if !@unlocked_hats.include?(hatID)

    if !silent
      filename = getTrainerSpriteHatFilename(hatID)
      name = hat ? hat.name : hatID
      unlock_outfit_animation(filename, name)
    end
  end

  def unlock_hair(hairID, silent = false)
    update_global_hairstyles_list()

    hairstyle = $PokemonGlobal.hairstyles_data[hairID]
    if hairID.is_a?(Symbol)
      hairID = HAIRSTYLES[hairID].id
    end
    @unlocked_hairstyles = [] if !@unlocked_hairstyles
    @unlocked_hairstyles << hairID if !@unlocked_hairstyles.include?(hairID)

    if !silent
      filename = getTrainerSpriteHairFilename("2_" + hairID)
      name = hairstyle ? hairstyle.name : hairID
      unlock_outfit_animation(filename, name)
    end
  end

  def unlock_outfit_animation(filepath, name, color = 2)
    outfit_preview = PictureWindow.new(filepath)
    outfit_preview.x = Graphics.width / 4
    musicEffect = "Key item get"
    pbMessage(_INTL("{1} obtained \\C[{2}]{3}\\C[0]!\\me[{4}]", $Trainer.name, color, name, musicEffect))
    outfit_preview.dispose
  end

  def surfing_pokemon=(species)
    @surfing_pokemon = species
  end

  def skin_tone=(value)
    @skin_tone = value
    $scene.reset_player_sprite
    #$scene.spritesetGlobal.playersprite.updateCharacterBitmap
  end

  def beat_league=(value)
    @beat_league = value
  end

  def new_game_plus_unlocked=(value)
    @new_game_plus_unlocked = value
  end

  def seen?(species)
    return @pokedex.seen?(species)
  end

  # (see Pokedex#owned?)
  # Shorthand for +self.pokedex.owned?+.
  def owned?(species)
    return @pokedex.owned?(species)
  end

  def can_change_outfit()
    return false if isOnPinkanIsland()
    return true
  end


  alias playerAddOns_initialize initialize
  def initialize(name, trainer_type)
    playerAddOns_initialize(name,trainer_type)
    @outfit                = 0
    @hat                   = 0
    @hat2                  = 0

    @hair                  = 0
    @clothes               = 0
    @hair_color            = 0
    @skin_tone             = 0
    @beat_league             =  false
    @new_game_plus_unlocked  =  false
    @new_game_plus         = false
    @surfing_pokemon = nil
    @last_worn_outfit = nil
    @last_worn_hat = nil
    @last_worn_hat2 = nil

    @dyed_hats = {}
    @dyed_clothes = {}

    @favorite_hat = nil
    @favorite_hat2 =nil
    @favorite_clothes = nil

    @card_background = Settings::DEFAULT_TRAINER_CARD_BG
    @unlocked_card_backgrounds = [@card_background]
    @seen_qmarks_sprite = false

  end
end

