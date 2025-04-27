MenuHandlers.add(:pause_menu, :outfit, {
  "name"      => _INTL("Outfit"),
  "order"     => 51,
  "condition" => proc { $player.can_change_outfit },
  "effect"    => proc { |menu|

    changeOutfit()
    # pbFadeOutIn do
    #   #pbCommonEvent(COMMON_EVENT_OUTFIT)
    #   #todo give Favorite outfit (used to be done through common event)
    #   changeOutfit()
    #   menu.silent_end_screen
    # end
    next false


  }
})# frozen_string_literal: true

