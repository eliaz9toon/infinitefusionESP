class TilemapRenderer
  alias original_tilemapRenderer_initialize initialize
  def initialize(viewport)
    original_tilemapRenderer_initialize(viewport)
    @custom_autotile_ids = {} # key: tile_id, value: filename
  end


  #   Examples:
  #    1 => [["Sand shore"], ["Flowers2"]],
  #    2 => [[], ["Flowers2", "Waterfall", "Waterfall crest", "Waterfall bottom"]],
  #    6 => [["Water rock", "Sea deep"], []]
  EXTRA_AUTOTILES = {
    1 => {  #route-field
            996 => "flowers_orange[10]",
            991 => "flowers_pink[10]",
            999 => "flowers_yellow[10]",
            1007 => "flowers_blue[10]",
            1015 => "flowers_purple[10]",
            1023 => "flowers_red[10]",
            1031 => "flowers_grey[10]",
            1039 => "flowers_white[10]",
    },
    2 => {  #small-town
            996 => "flowers_orange[10]",
            991 => "flowers_pink[10]",
            999 => "flowers_yellow[10]",
            1007 => "flowers_blue[10]",
            1015 => "flowers_purple[10]",
            1023 => "flowers_red[10]",
            1031 => "flowers_grey[10]",
            1039 => "flowers_white[10]",
    }
  }

  def add_extra_autotiles(tileset_id)
    overrides = EXTRA_AUTOTILES[tileset_id]
    return unless overrides
    overrides.each do |tile_id, filename|
      @autotiles.add(filename)
      @custom_autotile_ids[tile_id] = filename
    end
  end

  def remove_extra_autotiles(tileset_id)
    return if !EXTRA_AUTOTILES[tileset_id]
    EXTRA_AUTOTILES[tileset_id].each do |arr|
      arr.each { |filename| remove_autotile(filename) }
    end
  end


  def refresh_tile_bitmap(tile, map, tile_id)
    tile.tile_id = tile_id
    if tile_id < TILES_PER_AUTOTILE
      tile.set_bitmap("", tile_id, false, false, 0, nil)
      tile.shows_reflection = false
      tile.bridge = false
    else
      terrain_tag = map.terrain_tags[tile_id] || 0
      terrain_tag_data = GameData::TerrainTag.try_get(terrain_tag)
      priority = map.priorities[tile_id] || 0
      single_autotile_start_id = TILESET_START_ID
      true_tileset_start_id = TILESET_START_ID

      filename = nil
      extra_autotile_hash = EXTRA_AUTOTILES[map.tileset_id]

      if extra_autotile_hash && extra_autotile_hash[tile_id]
        # Custom tile_id override
        filename = extra_autotile_hash[tile_id]
        tile.set_bitmap(filename, tile_id, true, @autotiles.animated?(filename),
                        priority, @autotiles[filename])
      elsif tile_id < true_tileset_start_id
        # Default behavior
        if tile_id < TILESET_START_ID # Real autotiles
          filename = map.autotile_names[(tile_id / TILES_PER_AUTOTILE) - 1]
        elsif tile_id < single_autotile_start_id # Large extra autotiles
          filename = extra_autotile_arrays[0][(tile_id - TILESET_START_ID) / TILES_PER_AUTOTILE]
        else
          # Single extra autotiles
          filename = extra_autotile_arrays[1][tile_id - single_autotile_start_id]
        end
        tile.set_bitmap(filename, tile_id, true, @autotiles.animated?(filename),
                        priority, @autotiles[filename])
      else
        filename = map.tileset_name
        tile.set_bitmap(filename, tile_id, false, false, priority, @tilesets[filename])
      end

      tile.shows_reflection = terrain_tag_data&.shows_reflections
      tile.bridge = terrain_tag_data&.bridge
    end
    refresh_tile_src_rect(tile, tile_id)
  end

end

