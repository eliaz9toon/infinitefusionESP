def has_species_or_fusion?(species, form = -1)
  return $player.pokemon_party.any? { |p| p && p.isSpecies?(species) || p.isFusionOf(species) }
end

# frozen_string_literal: true

