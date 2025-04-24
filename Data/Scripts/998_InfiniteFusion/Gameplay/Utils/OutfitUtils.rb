# frozen_string_literal: true

def unlock_easter_egg_hats()
  if $player.name == "Ash"
    $player.hat = HAT_ASH
    $player.unlock_hat(HAT_ASH)
  end
  if $player.name == "Frogman"
    $player.hat = HAT_FROG
    $player.unlock_hat(HAT_FROG)
  end
end

def setupStartingOutfit()
  $player.hat = nil
  $player.clothes = STARTING_OUTFIT
  unlock_easter_egg_hats()
  gender = pbGet(VAR_TRAINER_GENDER)
  if gender == GENDER_FEMALE
    $player.unlock_clothes(DEFAULT_OUTFIT_FEMALE, true)
    $player.unlock_hat(DEFAULT_OUTFIT_FEMALE, true)
    $player.hair = "3_" + DEFAULT_OUTFIT_FEMALE if !$player.hair # when migrating old savefiles

  elsif gender == GENDER_MALE
    $player.unlock_clothes(DEFAULT_OUTFIT_MALE, true)
    $player.unlock_hat(DEFAULT_OUTFIT_MALE, true)

    echoln $player.hair
    $player.hair = ("3_" + DEFAULT_OUTFIT_MALE) if !$player.hair # when migrating old savefiles
    echoln $player.hair
  end
  $player.unlock_hair(DEFAULT_OUTFIT_MALE, true)
  $player.unlock_hair(DEFAULT_OUTFIT_FEMALE, true)
  $player.unlock_clothes(STARTING_OUTFIT, true)
end

def give_date_specific_hats()
  current_date = Time.new
  # Christmas
  if (current_date.day == 24 || current_date.day == 25) && current_date.month == 12
    if !$player.unlocked_hats.include?(HAT_SANTA)
      pbCallBub(2, @event_id, true)
      pbMessage("Hi! We're giving out a special hat today for the holidays season. Enjoy!")
      obtainHat(HAT_SANTA)
    end
  end

  # April's fool
  if (current_date.day == 1 && current_date.month == 4)
    if !$player.unlocked_hats.include?(HAT_CLOWN)
      pbCallBub(2, @event_id, true)
      pbMessage("Hi! We're giving out this fun accessory for this special day. Enjoy!")
      obtainHat(HAT_CLOWN)
    end
  end
end