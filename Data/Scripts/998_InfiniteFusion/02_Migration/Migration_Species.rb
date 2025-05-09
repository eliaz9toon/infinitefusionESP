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

  end
end

