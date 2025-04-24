# frozen_string_literal: true

def unlock_easter_egg_hats()
  if $Trainer.name == "Ash"
    $Trainer.hat = HAT_ASH
    $Trainer.unlock_hat(HAT_ASH)
  end
  if $Trainer.name == "Frogman"
    $Trainer.hat = HAT_FROG
    $Trainer.unlock_hat(HAT_FROG)
  end
end

def setupStartingOutfit()
  $Trainer.hat = nil
  $Trainer.clothes = STARTING_OUTFIT
  unlock_easter_egg_hats()
  gender = pbGet(VAR_TRAINER_GENDER)
  if gender == GENDER_FEMALE
    $Trainer.unlock_clothes(DEFAULT_OUTFIT_FEMALE, true)
    $Trainer.unlock_hat(DEFAULT_OUTFIT_FEMALE, true)
    $Trainer.hair = "3_" + DEFAULT_OUTFIT_FEMALE if !$Trainer.hair # when migrating old savefiles

  elsif gender == GENDER_MALE
    $Trainer.unlock_clothes(DEFAULT_OUTFIT_MALE, true)
    $Trainer.unlock_hat(DEFAULT_OUTFIT_MALE, true)

    echoln $Trainer.hair
    $Trainer.hair = ("3_" + DEFAULT_OUTFIT_MALE) if !$Trainer.hair # when migrating old savefiles
    echoln $Trainer.hair
  end
  $Trainer.unlock_hair(DEFAULT_OUTFIT_MALE, true)
  $Trainer.unlock_hair(DEFAULT_OUTFIT_FEMALE, true)
  $Trainer.unlock_clothes(STARTING_OUTFIT, true)
end

def give_date_specific_hats()
  current_date = Time.new
  # Christmas
  if (current_date.day == 24 || current_date.day == 25) && current_date.month == 12
    if !$Trainer.unlocked_hats.include?(HAT_SANTA)
      pbCallBub(2, @event_id, true)
      pbMessage("Hi! We're giving out a special hat today for the holidays season. Enjoy!")
      obtainHat(HAT_SANTA)
    end
  end

  # April's fool
  if (current_date.day == 1 && current_date.month == 4)
    if !$Trainer.unlocked_hats.include?(HAT_CLOWN)
      pbCallBub(2, @event_id, true)
      pbMessage("Hi! We're giving out this fun accessory for this special day. Enjoy!")
      obtainHat(HAT_CLOWN)
    end
  end
end