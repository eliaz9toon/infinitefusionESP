# frozen_string_literal: true

class Sprite_SurfBase

  def initialize(parent_sprite, viewport = nil)
    @parent_sprite = parent_sprite
    @sprite = nil
    @viewport = viewport
    @disposed = false

    @surfbitmap = update_surf_bitmap(:SURF)
    @divebitmap = update_surf_bitmap(:DIVE)

    @cws = @surfbitmap.width / 4
    @chs = @surfbitmap.height / 4
    @cwd = @divebitmap.width / 4
    @chd = @divebitmap.height / 4
    update
  end

  def update_surf_bitmap(type)
    species = $Trainer.surfing_pokemon
    path = Settings::PLAYER_GRAPHICS_FOLDER + Settings::PLAYER_SURFBASE_FOLDER + "surfmon_board" if type == :SURF
    path = Settings::PLAYER_GRAPHICS_FOLDER + Settings::PLAYER_SURFBASE_FOLDER + "divemon_Head" if type == :DIVE
    if species
      shape = species.shape
      basePath = Settings::PLAYER_GRAPHICS_FOLDER + Settings::PLAYER_SURFBASE_FOLDER
      action = "divemon" if type == :DIVE
      action = "surfmon" if type == :SURF
      path = "#{basePath}#{action}_#{shape.to_s}"
    end
    return AnimatedBitmap.new(path)
  end

end
