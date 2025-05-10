def getPokemonPositionInParty(pokemon)
  for i in 0..$player.party.length
    if $player.party[i] == pokemon
      return i
    end
  end
  return -1
end

# don't remember why there's two Supersplicers arguments.... probably a mistake
def pbDNASplicing(pokemon, scene, item = :DNASPLICERS)
  echoln pokemon
  echoln scene
  echoln item


  is_supersplicer = isSuperSplicersMechanics(item)

  playingBGM = $game_system.getPlayingBGM
  if (pokemon.species_data.id_number <= Settings::NB_POKEMON)
      chosen = scene.pbChoosePokemon(_INTL("Fuse with which Pokémon?"))
      if chosen >= 0
        poke2 = $player.party[chosen]
        if (poke2.species_data.id_number <= Settings::NB_POKEMON) && poke2 != pokemon
          # check if fainted

          if pokemon.egg? || poke2.egg?
            scene.pbDisplay(_INTL("It's impossible to fuse an egg!"))
            return false
          end
          if pokemon.hp == 0 || poke2.hp == 0
            scene.pbDisplay(_INTL("A fainted Pokémon cannot be fused!"))
            return false
          end

          selectedHead = selectFusion(pokemon, poke2, is_supersplicer)
          if selectedHead == -1 # cancelled
            return false
          end
          if selectedHead == nil # can't fuse (egg, etc.)
            scene.pbDisplay(_INTL("It won't have any effect."))
            return false
          end
          selectedBase = selectedHead == pokemon ? poke2 : pokemon

          firstOptionSelected = selectedHead == pokemon
          if !firstOptionSelected
            chosen = getPokemonPositionInParty(pokemon)
            if chosen == -1
              scene.pbDisplay(_INTL("There was an error..."))
              return false
            end
          end

          if (Kernel.pbConfirmMessage(_INTL("Fuse {1} and {2}?", selectedHead.name, selectedBase.name)))
            pbFuse(selectedHead, selectedBase, item)
            $Trainer.remove_pokemon_at_index(chosen)
            scene.pbHardRefresh
            pbBGMPlay(playingBGM)
            return true
          end

        elsif pokemon == poke2
          scene.pbDisplay(_INTL("{1} can't be fused with itself!", pokemon.name))
          return false
        else
          scene.pbDisplay(_INTL("{1} can't be fused with {2}.", poke2.name, pokemon.name))
          return false
        end
      else
        return false
      end

  else
    # UNFUSE
    return true if pbUnfuse(pokemon, scene, is_supersplicer)
  end
end

def selectFusion(pokemon, poke2, supersplicers = false)
  return nil if !pokemon.is_a?(Pokemon) || !poke2.is_a?(Pokemon)
  return nil if pokemon.egg? || poke2.egg?

  selectorWindow = FusionPreviewScreen.new(poke2, pokemon, supersplicers) # PictureWindow.new(picturePath)
  selectedHead = selectorWindow.getSelection
  selectorWindow.dispose
  return selectedHead
end

def pbFuse(pokemon_body, pokemon_head, splicer_item)
  use_supersplicers_mechanics = isSuperSplicersMechanics(splicer_item)

  newid = (pokemon_body.species_data.id_number) * Settings::NB_POKEMON + pokemon_head.species_data.id_number
  fus = PokemonFusionScene.new

  if (fus.pbStartScreen(pokemon_body, pokemon_head, newid, splicer_item))
    returnItemsToBag(pokemon_body, pokemon_head)
    fus.pbFusionScreen(false, use_supersplicers_mechanics)
    $game_variables[VAR_FUSE_COUNTER] += 1 # fuse counter
    fus.pbEndScreen
    return true
  end
end

# Todo: refactor this, holy shit this is a mess
def pbUnfuse(pokemon, scene, supersplicers, pcPosition = nil)
  if pokemon.species_data.id_number > (Settings::NB_POKEMON * Settings::NB_POKEMON) + Settings::NB_POKEMON # triple fusion
    scene.pbDisplay(_INTL("{1} cannot be unfused.", pokemon.name))
    return false
  end
  if pokemon.owner.name  == "RENTAL"
    scene.pbDisplay(_INTL("You cannot unfuse a rental pokémon!"))
    return
  end

  pokemon.spriteform_body = nil
  pokemon.spriteform_head = nil

  bodyPoke = getBasePokemonID(pokemon.species_data.id_number, true)
  headPoke = getBasePokemonID(pokemon.species_data.id_number, false)

  if (pokemon.foreign?($player)) # && !canunfuse
    scene.pbDisplay(_INTL("You can't unfuse a Pokémon obtained in a trade!"))
    return false
  else
    if Kernel.pbConfirmMessageSerious(_INTL("Should {1} be unfused?", pokemon.name))
      keepInParty = 0
      if $player.party.length >= 6 && !pcPosition

        message = "Your party is full! Keep which Pokémon in party?"
        message = "Your party is full! Keep which Pokémon in party? The other will be released." if isOnPinkanIsland()
        scene.pbDisplay(_INTL(message))
        selectPokemonMessage = "Select a Pokémon to keep in your party."
        selectPokemonMessage = "Select a Pokémon to keep in your party. The other will be released" if isOnPinkanIsland()
        choice = Kernel.pbMessage(selectPokemonMessage, [_INTL("{1}", PBSpecies.getName(bodyPoke)), _INTL("{1}", PBSpecies.getName(headPoke)), "Cancel"], 2)
        if choice == 2
          return false
        else
          keepInParty = choice
        end
      end

      scene.pbDisplay(_INTL("Unfusing ... "))
      scene.pbDisplay(_INTL(" ... "))
      scene.pbDisplay(_INTL(" ... "))

      if pokemon.exp_when_fused_head == nil || pokemon.exp_when_fused_body == nil
        new_level = calculateUnfuseLevelOldMethod(pokemon, supersplicers)
        body_level = new_level
        head_level = new_level
        poke1 = Pokemon.new(bodyPoke, body_level)
        poke2 = Pokemon.new(headPoke, head_level)
      else
        exp_body = pokemon.exp_when_fused_body + pokemon.exp_gained_since_fused
        exp_head = pokemon.exp_when_fused_head + pokemon.exp_gained_since_fused

        poke1 = Pokemon.new(bodyPoke, pokemon.level)
        poke2 = Pokemon.new(headPoke, pokemon.level)
        poke1.exp = exp_body
        poke2.exp = exp_head
      end
      body_level = poke1.level
      head_level = poke2.level

      pokemon.exp_gained_since_fused = 0
      pokemon.exp_when_fused_head = nil
      pokemon.exp_when_fused_body = nil

      if pokemon.shiny?
        pokemon.shiny = false
        if pokemon.bodyShiny? && pokemon.headShiny?
          pokemon.shiny = true
          poke2.shiny = true
          pokemon.natural_shiny = true if pokemon.natural_shiny && !pokemon.debug_shiny
          poke2.natural_shiny = true if pokemon.natural_shiny && !pokemon.debug_shiny
        elsif pokemon.bodyShiny?
          pokemon.shiny = true
          poke2.shiny = false
          pokemon.natural_shiny = true if pokemon.natural_shiny && !pokemon.debug_shiny
        elsif pokemon.headShiny?
          poke2.shiny = true
          pokemon.shiny = false
          poke2.natural_shiny = true if pokemon.natural_shiny && !pokemon.debug_shiny
        else
          # shiny was obtained already fused
          if rand(2) == 0
            pokemon.shiny = true
          else
            poke2.shiny = true
          end
        end
      end

      fused_pokemon_learned_moved = pokemon.learned_moves
      pokemon.learned_moves = fused_pokemon_learned_moved
      poke2.learned_moves = fused_pokemon_learned_moved

      pokemon.ability_index = pokemon.body_original_ability_index if pokemon.body_original_ability_index
      poke2.ability_index = pokemon.head_original_ability_index if pokemon.head_original_ability_index

      pokemon.ability2_index = nil
      pokemon.ability2 = nil
      poke2.ability2_index = nil
      poke2.ability2 = nil

      pokemon.debug_shiny = true if pokemon.debug_shiny && pokemon.body_shiny
      poke2.debug_shiny = true if pokemon.debug_shiny && poke2.head_shiny

      pokemon.body_shiny = false
      pokemon.head_shiny = false

      if !pokemon.shiny?
        pokemon.debug_shiny = false
      end
      if !poke2.shiny?
        poke2.debug_shiny = false
      end

      if $player.party.length >= 6
        if (keepInParty == 0)
          if isOnPinkanIsland()
            scene.pbDisplay(_INTL("{1} was released.", poke2.name))
          else
            $PokemonStorage.pbStoreCaught(poke2)
            scene.pbDisplay(_INTL("{1} was sent to the PC.", poke2.name))
          end
        else
          poke2 = Pokemon.new(bodyPoke, body_level)
          poke1 = Pokemon.new(headPoke, head_level)

          # Fusing from PC
          if pcPosition != nil
            box = pcPosition[0]
            index = pcPosition[1]
            # todo: store at next available position from current position
            $PokemonStorage.pbStoreCaught(poke2)
          else
            # Fusing from party
            if isOnPinkanIsland()
              scene.pbDisplay(_INTL("{1} was released.", poke2.name))
            else
              $PokemonStorage.pbStoreCaught(poke2)
              scene.pbDisplay(_INTL("{1} was sent to the PC.", poke2.name))
            end
          end
        end
      else
        if pcPosition != nil
          box = pcPosition[0]
          index = pcPosition[1]
          # todo: store at next available position from current position
          $PokemonStorage.pbStoreCaught(poke2)
        else
          Kernel.pbAddPokemonSilent(poke2, poke2.level)
        end
      end

      # On ajoute les poke au pokedex
      $player.pokedex.set_seen(poke1.species)
      $player.pokedex.set_owned(poke1.species)
      $player.pokedex.set_seen(poke2.species)
      $player.pokedex.set_owned(poke2.species)

      pokemon.species = poke1.species
      pokemon.level = poke1.level
      pokemon.name = poke1.name
      pokemon.moves = poke1.moves
      pokemon.obtain_method = 0
      poke1.obtain_method = 0

      # scene.pbDisplay(_INTL(p1.to_s + " " + p2.to_s))
      scene.pbHardRefresh
      scene.pbDisplay(_INTL("Your Pokémon were successfully unfused! "))
      return true
    end
  end
end# frozen_string_literal: true


def returnItemsToBag(pokemon, poke2)

  it1 = pokemon.item
  it2 = poke2.item

  $PokemonBag.pbStoreItem(it1, 1) if it1 != nil
  $PokemonBag.pbStoreItem(it2, 1) if it2 != nil

  pokemon.item = nil
  poke2.item = nil
end
