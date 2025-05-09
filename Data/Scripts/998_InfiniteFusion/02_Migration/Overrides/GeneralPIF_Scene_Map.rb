# frozen_string_literal: true

class Scene_Map
  def cacheNeedsClearing
    return RPG::Cache.size >= 100
  end

  def reset_switches_for_map_transfer
    $game_switches[SWITCH_ILEX_FOREST_SPOOKED_POKEMON] = false
  end

  def clear_quest_icons()
    for sprite in $scene.spriteset.character_sprites
      if sprite.is_a?(Sprite_Character) && sprite.questIcon
        sprite.removeQuestIcon
      end
    end
  end



  alias pokemonEssentials_SceneMap_transfer_player transfer_player
  def transfer_playerr(cancel_swimming = true)
    pokemonEssentials_SceneMap_transfer_player(cancel_swimming)
    reset_switches_for_map_transfer()
    clear_quest_icons()
  end

end
