class Pokemon
  attr_accessor :exp_when_fused_head
  attr_accessor :exp_when_fused_body
  attr_accessor :exp_gained_since_fused

  attr_accessor :hat
  attr_accessor :hat_x
  attr_accessor :hat_y

  attr_accessor :glitter
  attr_accessor :head_shiny
  attr_accessor :body_shiny
  attr_accessor :debug_shiny
  attr_accessor :natural_shiny

  attr_writer :ability_index
  attr_accessor :body_original_ability_index
  attr_accessor :head_original_ability_index

  # @return [Array<Symbol>] All the move (ids) ever learned by this Pokémon
  attr_accessor :learned_moves

  attr_accessor :force_disobey


  def print_all_attributes
    instance_variables.each do |var|
      begin
        value = instance_variable_get(var)
        echoln("#{var}: #{value.inspect}")
      rescue => e
        echoln("#{var}: [Error reading value: #{e.message}]")
      end
    end
  end


  def id_number
    return species_data.id_number
  end

  def hiddenPower=(type)
    @hiddenPowerType = type
  end

  def sprite_scale()
    @sprite_scale = 1 if !@sprite_scale
    return @sprite_scale
  end

  def sprite_scale=(scale)
    @sprite_scale = scale
  end


  def size_category()
    @size_category = :AVERAGE if !@size_category
    return @size_category
  end

  def size_category=(category)
    @size_category = category
  end

  def hasBodyOf?(check_species)
    if !self.isFusion?
      return isSpecies?(check_species)
    end
    bodySpecies = getBodyID(species)
    checkSpeciesId = getID(nil, check_species)
    return bodySpecies == checkSpeciesId
  end

  def hasHeadOf?(check_species)
    if !self.isFusion?
      return isSpecies?(check_species)
    end
    headSpecies = getHeadID(species)
    checkSpeciesId = getID(nil, check_species)
    return headSpecies == checkSpeciesId
  end

  def head_id()
    return get_head_id_from_symbol(@species)
  end

  def body_id()
    return get_body_id_from_symbol(@species)
  end

  def shiny=(value)
    @shiny = value
    if value && Settings::SHINY_POKEMON_CHANCE != S_CHANCE_VALIDATOR
      @debug_shiny = true
    end
  end

  def isShiny?()
    return @shiny || @body_shiny || @head_shiny
  end

  def naturalShiny?
    return @natural_shiny
  end

  def debugShiny?
    return !@natural_shiny || @debug_shiny
  end

  def bodyShiny?
    return @body_shiny
  end

  def headShiny?
    return @head_shiny
  end


  def isFusionOf(check_species)
    return hasBodyOf?(check_species) || hasHeadOf?(check_species)
  end


  def dexNum
    return species_data.id_number
  end

  def isSelfFusion?
    return isFusion? && getHeadID(species) == getBodyID(species)
  end

  def isFusion?
    return species_data.id_number > NB_POKEMON && !self.isTripleFusion?
  end

  def isTripleFusion?
    return species_data.id_number >= Settings::ZAPMOLCUNO_NB
  end

  def changeFormSpecies(oldForm, newForm)

    is_already_old_form = self.isFusionOf(oldForm) #A 466
    is_already_new_form = self.isFusionOf(newForm) #P

    #reverse the fusion if it's a meloA and meloP fusion
    # There's probably a smarter way to do this but laziness lol
    if is_already_old_form && is_already_new_form
      body_id = self.species_data.get_body_species()
      body_species = GameData::Species.get(body_id)

      if body_species == oldForm
        changeSpeciesSpecific(self, getFusedPokemonIdFromSymbols(newForm, oldForm))
      else
        changeSpeciesSpecific(self, getFusedPokemonIdFromSymbols(oldForm, newForm))
      end
    else
      echoln "changing species...."
      changeSpecies(self, oldForm, newForm) if is_already_old_form
      changeSpecies(self, newForm, oldForm) if is_already_new_form
    end

    calc_stats
  end

  def changeSpecies(pokemon, speciesToReplace, newSpecies)
    if pokemon.isFusion?()
      replaceFusionSpecies(pokemon, speciesToReplace, newSpecies)
    else
      changeSpeciesSpecific(pokemon, newSpecies)
    end
    $Trainer.pokedex.set_seen(pokemon.species)
    $Trainer.pokedex.set_owned(pokemon.species)
  end

  def type1
    if @ability == :MULTITYPE && species_data.type1 == :NORMAL
      return getHeldPlateType()
    end
    return @type1 if @type1
    return species_data.type1
  end

  # @return [Symbol] this Pokémon's second type, or the first type if none is defined
  def type2
    if @ability == :MULTITYPE && species_data.type2 == :NORMAL
      return getHeldPlateType()
    end
    sp_data = species_data
    return sp_data.type2 || sp_data.type1
  end


  def type1=(value)
    @type1 = value
  end

  def type2=(value)
    @type2 = value
  end

  def getHeldPlateType()
    return getArceusPlateType(@item)
  end

  def makeMale
    @gender = 0
  end

  # Makes this Pokémon female.
  def makeFemale
    @gender = 1
  end

  # @return [Boolean] whether this Pokémon is male
  def male?
    return self.gender == 0;
  end

  # @return [Boolean] whether this Pokémon is female
  def female?
    return self.gender == 1;
  end

  # @return [Boolean] whether this Pokémon is genderless
  def genderless?
    return self.gender == 2;
  end

  def add_learned_move(move)
    @learned_moves = [] if !@learned_moves
    if move.is_a?(Symbol)
      @learned_moves << move unless @learned_moves.include?(move)
    else
      move_id = move.id
      if move_id
        @learned_moves << move_id unless @learned_moves.include?(move_id)
      end
    end
  end


  alias pokemonEssentials_Pokemon_learn_move learn_move
  def learn_move(move)
    pokemonEssentials_Pokemon_learn_move(move)
    add_learned_move(move)
  end

  alias pokemonEssentials_Pokemon_forget_move forget_move
  def forget_move(move_id)
    pokemonEssentials_Pokemon_forget_move(move_id)
    add_learned_move(move_id)
  end

  def forget_move_at_index(index)
    move_id = @moves[index].id
    add_learned_move(move_id)
    @moves.delete_at(index)
  end

  # Deletes all moves from the Pokémon.
  def forget_all_moves
    for move in @moves
      add_learned_move(move)
    end
    @moves.clear
  end

  def compatible_with_move?(move_id)
    move_data = GameData::Move.try_get(move_id)
    if isFusion?()
      head_species_id = getBasePokemonID(species, false)
      body_species_id = getBasePokemonID(species)
      head_species = GameData::Species.get(head_species_id)
      body_species = GameData::Species.get(body_species_id)
      return move_data && (pokemon_can_learn_move(head_species, move_data) || pokemon_can_learn_move(body_species, move_data))
    else
      return move_data && pokemon_can_learn_move(species_data, move_data)
    end
  end

  def pokemon_can_learn_move(species_data, move_data)
    moveset = species_data.moves.map { |pair| pair[1] }
    return species_data.tutor_moves.include?(move_data.id) ||
      species_data.moves.include?(move_data.id) ||  ##this is formatted as such [[1, :PECK],[etc.]] so it never finds anything when move_data is just the symbol. Leaving it there in case something depends on that for some reason.
      moveset.include?(move_data.id) ||
      species_data.egg_moves.include?(move_data.id)
  end

  def has_egg_move?
    return false if egg? || shadowPokemon?
    baby = pbGetBabySpecies(self.species)
    moves = pbGetSpeciesEggMoves(baby)
    return true if moves.size >= 1
  end

  def foreign?(trainer)
    return @owner.id != trainer.id# || @owner.name != trainer.name
  end

  def always_disobey(value)
    @force_disobey = value
  end

  #=============================================================================
  # Evolution checks
  #=============================================================================
  # Checks whether this Pokemon can evolve because of levelling up.
  # @return [Symbol, nil] the ID of the species to evolve into
  def prompt_evolution_choice(body_evolution, head_evolution)
    current_body = @species_data.body_pokemon
    current_head = @species_data.head_pokemon

    choices = [
      #_INTL("Evolve both!"),
      _INTL("Evolve head!"),
      _INTL("Evolve body!"),
      _INTL("Don't evolve")
    ]
    choice = pbMessage(_INTL('Both halves of {1} are ready to evolve!', self.name), choices, 0)
    # if choice == 0  #EVOLVE BOTH
    #   newspecies = getFusionSpecies(body_evolution,head_evolution)
    if choice == 0 #EVOLVE HEAD
      newspecies = getFusionSpecies(current_body, head_evolution)
    elsif choice == 1 #EVOLVE BODY
      newspecies = getFusionSpecies(body_evolution, current_head)
    else
      newspecies = nil
    end
    return newspecies
  end

  def check_evolution_on_level_up(prompt_choice=true)
    if @species_data.is_a?(GameData::FusedSpecies)
      body = self.species_data.body_pokemon
      head = self.species_data.head_pokemon

      body_evolution = check_evolution_internal(@species_data.body_pokemon) { |pkmn, new_species, method, parameter|
        success = GameData::Evolution.get(method).call_level_up(pkmn, parameter)
        next (success) ? new_species : nil
      }
      head_evolution = check_evolution_internal(@species_data.head_pokemon) { |pkmn, new_species, method, parameter|
        success = GameData::Evolution.get(method).call_level_up(pkmn, parameter)
        next (success) ? new_species : nil
      }
      if body_evolution && head_evolution
        return prompt_evolution_choice(body_evolution, head_evolution) if prompt_choice
        return [body_evolution,head_evolution].sample
      end
    end

    return check_evolution_internal { |pkmn, new_species, method, parameter|
      success = GameData::Evolution.get(method).call_level_up(pkmn, parameter)
      next (success) ? new_species : nil
    }
    end
    def getBaseStatsFormException()
      if @species == :PUMPKABOO
        case @size_category
        when :SMALL
          return { :HP => 44, :ATTACK => 66, :DEFENSE => 70, :SPECIAL_ATTACK => 44, :SPECIAL_DEFENSE => 55, :SPEED => 56}
        when :AVERAGE
          return nil
        when :LARGE
          return { :HP => 54, :ATTACK => 66, :DEFENSE => 70, :SPECIAL_ATTACK => 44, :SPECIAL_DEFENSE => 55, :SPEED => 46}
        when :SUPER
          return { :HP => 59, :ATTACK => 66, :DEFENSE => 70, :SPECIAL_ATTACK => 44, :SPECIAL_DEFENSE => 55, :SPEED => 41}
        end
      end
      if @species == :GOURGEIST
        case @size_category
        when :SMALL
          return { :HP => 55, :ATTACK => 85, :DEFENSE => 122, :SPECIAL_ATTACK => 58, :SPECIAL_DEFENSE => 75, :SPEED => 99}
        when :AVERAGE
          return nil
        when :LARGE
          return { :HP => 75, :ATTACK => 95, :DEFENSE => 122, :SPECIAL_ATTACK => 58, :SPECIAL_DEFENSE => 75, :SPEED => 69}
        when :SUPER
          return { :HP => 85, :ATTACK => 100, :DEFENSE => 122, :SPECIAL_ATTACK => 58, :SPECIAL_DEFENSE => 75, :SPEED => 54}
        end
      end
      return nil
    end

    def adjust_level_for_base_stats_mode()
      nb_badges = $Trainer.badge_count
      this_level = ((nb_badges * Settings::NO_LEVEL_MODE_LEVEL_INCR) + Settings::NO_LEVEL_MODE_LEVEL_BASE).ceil
      if this_level > Settings::MAXIMUM_LEVEL
        this_level = Settings::MAXIMUM_LEVEL
      end
      return this_level
    end

    def adjustHPForWonderGuard(stats)
      return self.ability == :WONDERGUARD ? 1 : stats[:HP]
    end

    def checkHPRelatedFormChange()
      if @ability == :SHIELDSDOWN
        return if $game_temp.in_battle  #handled in battlers class in-battle
        if isFusionOf(:MINIOR_M)
          if @hp <= (@totalhp / 2)
            changeFormSpecies(:MINIOR_M, :MINIOR_C)
          end
        end
        if isFusionOf(:MINIOR_C)
          if @hp > (@totalhp / 2)
            changeFormSpecies(:MINIOR_C, :MINIOR_M)
          end
        end
      end
    end

    def determine_scale
      return :AVERAGE if !@size_category
      size_roll = rand(100) # Random number between 0-99
      if @size_category == :SMALL
        return 0.75
      elsif @size_category == :AVERAGE
        return 1
      elsif @size_category == :LARGE
        return 1 + (1.0 /3) #"Large Size"
      elsif @size_category == :SUPER
        return 1 + (2.0 /3)      #"Super Size"
      end
      return 1
    end

    def determine_size_category
      return :AVERAGE if !(Kernel.isPartPokemon(self,:PUMPKABOO) || Kernel.isPartPokemon(self,:GOURGEIST))
      size_roll = rand(100) # Random number between 0-99
      if size_roll < 10
        return :SMALL
      elsif size_roll < 50
        return :AVERAGE
      elsif size_roll < 90
        return :LARGE
      else
        return :SUPER
      end
    end

  def species=(species_id)
    new_species_data = GameData::Species.get(species_id)
    return if @species == new_species_data.species
    @species     = new_species_data.species
    @forced_form = nil
    @gender      = nil if singleGendered?
    @level       = nil   # In case growth rate is different for the new species
    @ability     = nil
    calc_stats
  end

end