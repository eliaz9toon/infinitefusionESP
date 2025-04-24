def turnEventTowardsEvent(turning, turnedTowards)
  event_x = turnedTowards.x
  event_y = turnedTowards.y
  if turning.x < event_x
    turning.turn_right # Event is to the right of the player
  elsif turning.x > event_x
    turning.turn_left # Event is to the left of the player
  elsif turning.y < event_y
    turning.turn_down # Event is below the player
  elsif turning.y > event_y
    turning.turn_up # Event is above the player
  end
end


def turnPlayerTowardsEvent(event)
  event_x = event.x
  event_y = event.y
  if $game_player.x < event_x
    $game_player.turn_right # Event is to the right of the player
  elsif $game_player.x > event_x
    $game_player.turn_left # Event is to the left of the player
  elsif $game_player.y < event_y
    $game_player.turn_down # Event is below the player
  elsif $game_player.y > event_y
    $game_player.turn_up # Event is above the player
  end
end

def player_near_event?(map_id, event_id, radius)
  return false if map_id != $game_map.map_id
  event = $game_map.events[event_id]
  return false if event.nil?
  dx = $game_player.x - event.x
  dy = $game_player.y - event.y
  distance = Math.sqrt(dx * dx + dy * dy)
  return distance <= radius
end