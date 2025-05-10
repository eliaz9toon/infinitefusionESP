module GameData
  class Species
    def id_number
      return (GameData::Species.keys.index(@id) || 0) + 1
    end


    def type1
      return @types[0]
    end

    def type2
      return @types[-1]
    end

    def is_fusion
      return id_number > Settings::NB_POKEMON
    end

    def is_triple_fusion
      return id_number >= Settings::ZAPMOLCUNO_NB
    end
    def get_body_species
      return @species
    end

    def get_head_species
      return @species
    end
    def hasType?(type)
      type = GameData::Type.get(type).id
      return self.types.include?(type)
    end

    def self.get_species_form(species, form)
      return nil if !species || !form
      return GameData::Species.get(species)

      validate species => [Symbol, self, String]
      validate form => Integer
      species = species.species if species.is_a?(self)
      species = species.to_sym if species.is_a?(String)
      trial = sprintf("%s_%d", species, form).to_sym
      species_form = (DATA[trial].nil?) ? species : trial
      return (DATA.has_key?(species_form)) ? DATA[species_form] : nil
    end

  end
end

