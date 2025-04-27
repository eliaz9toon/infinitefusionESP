# frozen_string_literal: true

class Game_Map

  alias pokemonEssentials_GameMap_setup setup
  def scroll_direction
      return 0 if @scroll_distance_x == 0 && @scroll_distance_y == 0
      if @scroll_distance_x < 0
        return DIRECTION_LEFT
      elsif @scroll_distance_x > 0
        return DIRECTION_RIGHT
      elsif @scroll_distance_y < 0
        return DIRECTION_UP
      elsif @scroll_distance_y > 0
        return DIRECTION_DOWN
      end
      return 0
  end

end
