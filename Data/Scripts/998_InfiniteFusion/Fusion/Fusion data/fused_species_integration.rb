# module GameData
#   module ClassMethods
#     def get(other)
#       validate other => [Symbol, self, String, Integer]
#       return other if other.is_a?(self)
#       other = other.to_sym if other.is_a?(String)
#
#       if other.to_s.match?(/\AB\d+H\d+\z/)
#         species = GameData::FusedSpecies.new(other)
#         return species
#       end
#
#       if other.is_a?(Integer) && self == GameData::Species
#         if other > NB_POKEMON
#           body_id = getBodyID(other)
#           head_id = getHeadID(other, body_id)
#           pokemon_id = getFusedPokemonIdFromDexNum(body_id, head_id)
#           return GameData::FusedSpecies.new(pokemon_id)
#         end
#       end
#
#       if !self::DATA.has_key?(other)
#         # echoln _INTL("Unknown ID {1}.", other)
#         return self::get(:PIKACHU)
#       end
#
#       raise "Unknown ID #{other}." unless self::DATA.has_key?(other)
#       return self::DATA[other]
#     end
#   end
# end
