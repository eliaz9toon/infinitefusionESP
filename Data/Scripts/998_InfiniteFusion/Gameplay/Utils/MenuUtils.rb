def optionsMenu(options = [], cmdIfCancel = -1, startingOption = 0)
  cmdIfCancel = -1 if !cmdIfCancel
  result = pbShowCommands(nil, options, cmdIfCancel, startingOption)
  echoln "menuResult :#{result}"
  return result
end

def displaySpriteWindowWithMessage(pif_sprite, message = "", x = 0, y = 0, z = 0)
  spriteLoader = BattleSpriteLoader.new
  sprite_bitmap = spriteLoader.load_pif_sprite_directly(pif_sprite)
  pictureWindow = PictureWindow.new(sprite_bitmap.bitmap)

  pictureWindow.opacity = 0
  pictureWindow.z = z
  pictureWindow.x = x
  pictureWindow.y = y
  pbMessage(message)
  pictureWindow.dispose
end

def select_any_pokemon()
  commands = []
  for dex_num in 1..NB_POKEMON
    species = getPokemon(dex_num)
    commands.push([dex_num - 1, species.real_name, species.id])
  end
  return pbChooseList(commands, 0, nil, 1)
end

def purchaseDyeKitMenu(hats_kit_price=0,clothes_kit_price=0)

  commands = []
  command_hats = "Hats Dye Kit ($#{hats_kit_price})"
  command_clothes = "Clothes Dye Kit ($#{clothes_kit_price})"
  command_cancel = "Cancel"

  commands << command_hats if !$PokemonBag.pbHasItem?(:HATSDYEKIT)
  commands << command_clothes if !$PokemonBag.pbHasItem?(:CLOTHESDYEKIT)
  commands << command_cancel

  if commands.length <= 1
    pbCallBub(2,@event_id)
    pbMessage("\\C[1]Dye Kits\\C[0] can be used to dye clothes all sorts of colours!")

    pbCallBub(2,@event_id)
    pbMessage("You can use them at any time when you change clothes.")
    return
  end
  pbCallBub(2,@event_id)
  pbMessage("\\GWelcome! Are you interested in dyeing your outfits different colours?")

  pbCallBub(2,@event_id)
  pbMessage("I make handy \\C[1]Dye Kits\\C[0] from my Smeargle's paint that can be used to dye your outfits any color you want!")

  pbCallBub(2,@event_id)
  pbMessage("\\GWhat's more is that it's reusable so you can go completely wild with it if you want! Are you interested?")

  choice = optionsMenu(commands,commands.length)
  case commands[choice]
  when command_hats
    if $player.money < hats_kit_price
      pbCallBub(2,@event_id)
      pbMessage("Oh, you don't have enough money...")
      return
    end
    pbMessage("\\G\\PN purchased the dye kit.")
    $player.money -= hats_kit_price
    pbSEPlay("SlotsCoin")
    Kernel.pbReceiveItem(:HATSDYEKIT)
    pbCallBub(2,@event_id)
    pbMessage("\\GHere you go! Have fun dyeing your hats!")
  when command_clothes
    if $player.money < clothes_kit_price
      pbCallBub(2,@event_id)
      pbMessage("Oh, you don't have enough money...")
      return
    end
    pbMessage("\\G\\PN purchased the dye kit.")
    $player.money -= clothes_kit_price
    pbSEPlay("SlotsCoin")
    Kernel.pbReceiveItem(:CLOTHESDYEKIT)
    pbCallBub(2,@event_id)
    pbMessage("\\GHere you go! Have fun dyeing your clothes!")
  end
  pbCallBub(2,@event_id)
  pbMessage("You can use \\C[1]Dye Kits\\C[0] at any time when you change clothes.")
end


def promptCaughtPokemonAction(pokemon)
  pickedOption = false
  return pbStorePokemon(pokemon) if !$player.party_full?
  return promptKeepOrRelease(pokemon) if isOnPinkanIsland() && !$game_switches[SWITCH_PINKAN_FINISHED]
  while !pickedOption
    command = pbMessage(_INTL("\\ts[]Your team is full!"),
                        [_INTL("Add to your party"), _INTL("Store to PC"),], 2)
    echoln ("command " + command.to_s)
    case command
    when 0 # SWAP
      if swapCaughtPokemon(pokemon)
        echoln pickedOption
        pickedOption = true
      end
    else
      # STORE
      pbStorePokemon(pokemon)
      echoln pickedOption
      pickedOption = true
    end
  end

end

def promptKeepOrRelease(pokemon)
  pickedOption = false
  while !pickedOption
    command = pbMessage(_INTL("\\ts[]Your team is full!"),
                        [_INTL("Release a party member"), _INTL("Release this #{pokemon.name}"),], 2)
    echoln ("command " + command.to_s)
    case command
    when 0 # SWAP
      if swapReleaseCaughtPokemon(pokemon)
        pickedOption = true
      end
    else
      pickedOption = true
    end
  end
end

# def pbChoosePokemon(variableNumber, nameVarNumber, ableProc = nil, allowIneligible = false)
def swapCaughtPokemon(caughtPokemon)
  pbChoosePokemon(1, 2,
                  proc { |poke|
                    !poke.egg? &&
                      !(poke.isShadow? rescue false)
                  })
  index = pbGet(1)
  return false if index == -1
  $PokemonStorage.pbStoreCaught($player.party[index])
  pbRemovePokemonAt(index)
  pbStorePokemon(caughtPokemon)

  tmp = $player.party[index]
  $player.party[index] = $player.party[-1]
  $player.party[-1] = tmp
  return true
end

def swapReleaseCaughtPokemon(caughtPokemon)
  pbChoosePokemon(1, 2,
                  proc { |poke|
                    !poke.egg? &&
                      !(poke.isShadow? rescue false)
                  })
  index = pbGet(1)
  return false if index == -1
  releasedPokemon = $player.party[index]
  pbMessage("#{releasedPokemon.name} was released.")
  pbRemovePokemonAt(index)
  pbStorePokemon(caughtPokemon)

  tmp = $player.party[index]
  $player.party[index] = $player.party[-1]
  $player.party[-1] = tmp
  return true
end

def Kernel.getItemNamesAsString(list)
  strList = ""
  for i in 0..list.length - 1
    id = list[i]
    name = PBItems.getName(id)
    strList += name
    if i != list.length - 1 && list.length > 1
      strList += ","
    end
  end
  return strList
end