class ClothesMartAdapter < OutfitsMartAdapter

  DEFAULT_NAME = "[unknown]"
  DEFAULT_DESCRIPTION = "A piece of clothing that trainers can wear."
  def toggleEvent(item)
    if !isShop? && $player.clothes_color != 0
      if pbConfirmMessage(_INTL("Would you like to remove the dye?"))
        $player.clothes_color = 0
      end
    end
  end

  def list_regional_set_items()
    return list_regional_clothes
  end

  def list_city_exclusive_items
    return list_city_exclusive_clothes
  end

  def initialize(stock = nil, isShop = nil)
    super
  end

  def getName(item)
    name= item.id
    name = "* #{name}" if is_wearing_clothes(item.id)
    return name
  end

  def getDescription(item)
    return DEFAULT_DESCRIPTION if !item.description
    return item.description
  end

  def getItemIcon(item)
    return Settings::BACK_ITEM_ICON_PATH if !item
    return getOverworldOutfitFilename(item.id)
  end

  def updateTrainerPreview(item, previewWindow)
    return if !item
    previewWindow.clothes = item.id
    $player.clothes = item.id
    set_dye_color(item,previewWindow)

    pbRefreshSceneMap
    previewWindow.updatePreview()
  end

  def get_dye_color(item_id)
    return 0 if isShop?
    $player.dyed_clothes= {} if ! $player.dyed_clothes
    if $player.dyed_clothes.include?(item_id)
      return $player.dyed_clothes[item_id]
    end
    return 0
  end

  def set_dye_color(item,previewWindow)
    if !isShop?
      $player.dyed_clothes= {} if ! $player.dyed_clothes
      if $player.dyed_clothes.include?(item.id)
        dye_color = $player.dyed_clothes[item.id]
        $player.clothes_color = dye_color
        previewWindow.clothes_color = dye_color
      else
        $player.clothes_color=0
        previewWindow.clothes_color=0
      end
    else
      $player.clothes_color=0
      previewWindow.clothes_color=0
    end
  end

  def addItem(item)
    changed_clothes = obtainClothes(item.id)
    if changed_clothes
      @worn_clothes = item.id
    end
  end

  def get_current_clothes()
    return $player.clothes
  end

  def player_changed_clothes?()
    $player.clothes != @worn_clothes
  end

  def putOnSelectedOutfit()
    putOnClothes($player.clothes)
    @worn_clothes = $player.clothes
  end

  def putOnOutfit(item)
    putOnClothes(item.id) if item
    @worn_clothes = item.id if item
  end

  def reset_player_clothes()
    $player.clothes = @worn_clothes
    $player.clothes_color = $player.dyed_clothes[@worn_clothes] if  $player.dyed_clothes && $player.dyed_clothes[@worn_clothes]
  end

  def get_unlocked_items_list()
    return $player.unlocked_clothes
  end

  def isWornItem?(item)
    super
  end


end
