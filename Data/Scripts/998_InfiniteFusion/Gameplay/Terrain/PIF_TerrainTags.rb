# frozen_string_literal: true

module GameData
  class TerrainTag
    attr_reader :flowerRed
    attr_reader :flowerPink
    attr_reader :flowerYellow
    attr_reader :flowerBlue
    attr_reader :flower
    attr_reader :trashcan
    attr_reader :sharpedoObstacle

    alias original_TerrainTag_init initialize
    def initialize(hash)
      original_TerrainTag_init(hash)
      @waterCurrent = hash[:waterCurrent] || false
      @flowerRed = hash[:flowerRed] || false
      @flowerYellow = hash[:flowerYellow] || false
      @flowerPink = hash[:flowerPink] || false
      @flowerBlue = hash[:flowerBlue] || false
      @flower = hash[:flower] || false
      @trashcan = hash[:trashcan] || false
      @sharpedoObstacle = hash[:sharpedoObstacle] || false
    end

  end
end


GameData::TerrainTag.register({
                                :id => :WaterCurrent,
                                :id_number => 6,
                                :can_surf => true,
                                :can_fish => true,
                                :waterCurrent => true,
                                :battle_environment => :MovingWater
                              })


GameData::TerrainTag.register({
                                :id => :FlowerRed,
                                :id_number => 17,
                                :flowerRed => true,
                                :flower => true
                              })
GameData::TerrainTag.register({
                                :id => :FlowerYellow,
                                :id_number => 18,
                                :flowerYellow => true,
                                :flower => true
                              })
GameData::TerrainTag.register({
                                :id => :FlowerPink,
                                :id_number => 19,
                                :flowerPink => true,
                                :flower => true
                              })
GameData::TerrainTag.register({
                                :id => :FlowerBlue,
                                :id_number => 20,
                                :flowerBlue => true,
                                :flower => true
                              })
GameData::TerrainTag.register({
                                :id => :FlowerOther,
                                :id_number => 21,
                                :flower => true
                              })
GameData::TerrainTag.register({
                                :id => :Trashcan,
                                :id_number => 22,
                                :trashcan => true
                              })

GameData::TerrainTag.register({
                                :id => :SharpedoObstacle,
                                :id_number => 23,
                                :sharpedoObstacle => true
                              })

GameData::TerrainTag.register({
                                :id => :Grass_alt1,
                                :id_number => 24,
                                :shows_grass_rustle => true,
                                :land_wild_encounters => true,
                                :battle_environment => :Grass
                              })

GameData::TerrainTag.register({
                                :id => :Grass_alt2,
                                :id_number => 25,
                                :shows_grass_rustle => true,
                                :land_wild_encounters => true,
                                :battle_environment => :Grass
                              })

GameData::TerrainTag.register({
                                :id => :Grass_alt3,
                                :id_number => 26,
                                :shows_grass_rustle => true,
                                :land_wild_encounters => true,
                                :battle_environment => :Grass
                              })

GameData::TerrainTag.register({
                                :id => :StillWater,
                                :id_number => 27,
                                :can_surf => true,
                                :can_fish => true,
                                :battle_environment => :StillWater,
                                :shows_reflections      => true
                              })





GameData::TerrainTag.register({
                                :id                     => :NoEffect,
                                :id_number              => 99
                              })