module Game
  class << self
    alias_method :original_start_new, :start_new
    def start_new
      original_start_new
      onLoadSaveFile
    end

    alias_method :original_load, :load
    def load(save_data)
      original_load(save_data)
      onLoadSaveFile
    end

    def onLoadSaveFile
      # Essentials 21 renamed the global variable $Trainer
      # It's still used everywhere in events, global events so this makes things simpler
      $Trainer = $player
      $PokemonBag = $bag

      migrateOldSavesToCharacterCustomization()
      clear_all_images()
      loadDateSpecificChanges()
    end
  end
end



def loadDateSpecificChanges()
  current_date = Time.new
  if (current_date.day == 1 && current_date.month == 4)
    $Trainer.hat2=HAT_CLOWN if $Trainer.unlocked_hats.include?(HAT_CLOWN)
  end
end

def migrateOldSavesToCharacterCustomization()
  if !$Trainer.unlocked_clothes
    $Trainer.unlocked_clothes = [DEFAULT_OUTFIT_MALE,
                                 DEFAULT_OUTFIT_FEMALE,
                                 STARTING_OUTFIT]
  end
  if !$Trainer.unlocked_hats
    $Trainer.unlocked_hats = [DEFAULT_OUTFIT_MALE, DEFAULT_OUTFIT_FEMALE]
  end
  if !$Trainer.unlocked_hairstyles
    $Trainer.unlocked_hairstyles = [DEFAULT_OUTFIT_MALE, DEFAULT_OUTFIT_FEMALE]
  end

  if !$Trainer.clothes || !$Trainer.hair #|| !$Trainer.hat
    setupStartingOutfit()
  end
end

def clear_all_images()
  for i in 1..99
    # echoln i.to_s + " : " + $game_screen.pictures[i].name
    $game_screen.pictures[i].erase
  end
end