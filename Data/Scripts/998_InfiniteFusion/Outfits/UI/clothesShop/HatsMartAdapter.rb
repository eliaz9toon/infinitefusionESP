class HatsMartAdapter < OutfitsMartAdapter
  attr_accessor :worn_clothes
  attr_accessor :worn_clothes2

  DEFAULT_NAME = "[unknown]"
  DEFAULT_DESCRIPTION = "A headgear that trainers can wear."

  def initialize(stock = nil, isShop = nil, isSecondaryHat = false)
    super(stock,isShop,isSecondaryHat)
    @worn_clothes =  $player.hat
    @worn_clothes2 =  $player.hat2
    @second_hat_visible = true
  end

  #Used in shops only
  def toggleSecondHat()
    @second_hat_visible = !@second_hat_visible
    $player.hat2 = @second_hat_visible ? @worn_clothes2 : nil
  end

  def toggleEvent(item)
    if isShop?
      toggleSecondHat
    else
      $player.set_hat(nil,@is_secondary_hat)
      @worn_clothes = nil
    end
  end

  def list_regional_set_items()
    return list_regional_hats
  end

  def list_city_exclusive_items
    return list_city_exclusive_hats
  end

  def set_secondary_hat(value)
    @is_secondary_hat = value
  end

  def is_wearing_clothes(outfit_id)
    return outfit_id == @worn_clothes || outfit_id == @worn_clothes2
  end

  def toggleText()
    return
    # return if @isShop
    # toggleKey = "D"#getMappedKeyFor(Input::SPECIAL)
    # return "Remove hat: #{toggleKey}"
  end

  def switchVersion(item,delta=1)
    pbSEPlay("GUI storage put down", 80, 100)
    return toggleSecondHat if isShop?
    @is_secondary_hat = !@is_secondary_hat
  end

  def getName(item)
    return item.id
  end

  def getDescription(item)
    return DEFAULT_DESCRIPTION if !item.description
    return item.description
  end

  def getItemIcon(item)
    return Settings::BACK_ITEM_ICON_PATH if !item
    return getOverworldHatFilename(item.id)
  end

  def updateTrainerPreview(item, previewWindow)
    if item.is_a?(Outfit)
      hat1 = @is_secondary_hat ? get_hat_by_id($player.hat) : item
      hat2 = @is_secondary_hat ? item : get_hat_by_id($player.hat2)

      previewWindow.set_hat(hat1.id,false) if hat1
      previewWindow.set_hat(hat2.id,true) if hat2
      previewWindow.set_hat(nil,true) if !@second_hat_visible #for toggling in shops

      hat1_color=0
      hat2_color=0
      hat1_color = $player.dyed_hats[hat1.id] if hat1 && $player.dyed_hats.include?(hat1.id)
      hat2_color = $player.dyed_hats[hat2.id] if hat2 && $player.dyed_hats.include?(hat2.id)
      previewWindow.hat_color = hat1_color
      previewWindow.hat2_color = hat2_color

      $player.hat = hat1&.id
      $player.hat2 = hat2&.id
      $player.hat_color = hat1_color
      $player.hat2_color = hat2_color

    else
      $player.set_hat(nil,@is_secondary_hat)
      previewWindow.set_hat(nil,@is_secondary_hat)
    end


    pbRefreshSceneMap
    previewWindow.updatePreview()
  end
  
  def get_dye_color(item_id)
    return if !item_id
    return 0 if isShop?
    $player.dyed_hats= {} if ! $player.dyed_hats
    if $player.dyed_hats.include?(item_id)
      return $player.dyed_hats[item_id]
    end
    return 0
  end


  def set_dye_color(item,previewWindow,is_secondary_hat=false)
    return if !item
    if !isShop?

    else
      $player.set_hat_color(0,is_secondary_hat)
      previewWindow.hat_color=0
    end
  end
  
  # def set_dye_color(item,previewWindow,is_secondary_hat=false)
  #   return if !item
  #   if !isShop?
  #     $player.dyed_hats= {} if !$player.dyed_hats
  #
  #     echoln item.id
  #     echoln $player.dyed_hats.include?(item.id)
  #     echoln $player.dyed_hats[item.id]
  #
  #     if $player.dyed_hats.include?(item.id)
  #       dye_color = $player.dyed_hats[item.id]
  #       $player.set_hat_color(dye_color,is_secondary_hat)
  #       previewWindow.hat_color = dye_color
  #     else
  #       $player.set_hat_color(0,is_secondary_hat)
  #       previewWindow.hat_color=0
  #     end
  #     #echoln $player.dyed_hats
  #   else
  #     $player.set_hat_color(0,is_secondary_hat)
  #     previewWindow.hat_color=0
  #   end
  # end


  def addItem(item)
    return unless item.is_a?(Outfit)
    changed_clothes = obtainHat(item.id,@is_secondary_hat)
    if changed_clothes
      @worn_clothes = item.id
    end
  end

  def get_current_clothes()
    return $player.hat(@is_secondary_hat)
  end

  def player_changed_clothes?()
    echoln("Trainer hat: #{$player.hat}, Worn hat: #{@worn_clothes}")
    echoln("Trainer hat2: #{$player.hat2}, Worn hat2: #{@worn_clothes2}")
    $player.hat != @worn_clothes || $player.hat2 != @worn_clothes2
  end

  def putOnSelectedOutfit()

    putOnHat($player.hat,true,false) if $player.hat
    putOnHat($player.hat2,true,true) if $player.hat2

    @worn_clothes = $player.hat
    @worn_clothes2 = $player.hat2

    playOutfitChangeAnimation()
    pbMessage(_INTL("You put on the hat(s)!\\wtnp[30]"))
  end

  def putOnOutfit(item)
    return unless item.is_a?(Outfit)
    putOnHat(item.id,false,@is_secondary_hat)
    @worn_clothes = item.id
  end

  def reset_player_clothes()
    $player.set_hat(@worn_clothes,false)
    $player.set_hat(@worn_clothes2,true)

    $player.set_hat_color($player.dyed_hats[@worn_clothes],false) if  $player.dyed_hats && $player.dyed_hats[@worn_clothes]
    $player.set_hat_color($player.dyed_hats[@worn_clothes2],true) if  $player.dyed_hats && $player.dyed_hats[@worn_clothes2]
  end

  def get_unlocked_items_list()
    return $player.unlocked_hats
  end

  def getSpecialItemCaption(specialType)
    case specialType
    when :REMOVE_HAT
      return "Remove hat"
    end
    return nil
  end

  def getSpecialItemBaseColor(specialType)
    case specialType
    when :REMOVE_HAT
      return MessageConfig::BLUE_TEXT_MAIN_COLOR
    end
    return nil
  end

  def getSpecialItemShadowColor(specialType)
    case specialType
    when :REMOVE_HAT
      return MessageConfig::BLUE_TEXT_SHADOW_COLOR
    end
    return nil
  end

  def getSpecialItemDescription(specialType)
    hair_situation = !$player.hair || getSimplifiedHairIdFromFullID($player.hair) == HAIR_BALD ? "bald head" : "fabulous hair"
    return "Go without a hat and show off your #{hair_situation}!"
  end

  def doSpecialItemAction(specialType,item=nil)
    toggleEvent(item)
  end
end
