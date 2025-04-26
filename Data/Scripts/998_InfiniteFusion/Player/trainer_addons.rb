
class Trainer
  attr_accessor :quests
  attr_accessor :sprite_override
  attr_accessor :custom_appearance
  attr_accessor :lowest_difficulty
  attr_accessor :selected_difficulty
  attr_accessor :game_mode


  alias pokemonEssentials_Trainer_initialize initialize


  def initialize(name, trainer_type, sprite_override=nil, custom_appearance=nil)
    pokemonEssentials_Trainer_initialize(name, trainer_type)
    @sprite_override = sprite_override
    @custom_appearance = custom_appearance
    @lowest_difficulty=2  #On hard by default, lowered whenever the player selects another difficulty
    @selected_difficulty=2  #On hard by default, lowered whenever the player selects another difficulty
    @game_mode =0  #classic
  end

  def trainer_type_name
    return GameData::TrainerType.get(@trainer_type).name;
  end

  def base_money
    return GameData::TrainerType.get(@trainer_type).base_money;
  end

  def gender
    return GameData::TrainerType.get(@trainer_type).gender;
  end

  def male?
    return GameData::TrainerType.get(@trainer_type).male?;
  end

  def female?
    return GameData::TrainerType.get(@trainer_type).female?;
  end

  def skill_level
    if $game_switches[SWITCH_GAME_DIFFICULTY_HARD]
      return 100
    end
    return GameData::TrainerType.get(@trainer_type).skill_level;
  end

  def skill_code
    return GameData::TrainerType.get(@trainer_type).skill_code;
  end

  def highest_level_pokemon_in_party
    max_level = 0
    for pokemon in @party
      if pokemon.level > max_level
        max_level = pokemon.level
      end
    end
    return max_level
  end


  def has_species_or_fusion?(species, form = -1)
    return pokemon_party.any? { |p| p && p.isSpecies?(species) || p.isFusionOf(species) }
  end



end
