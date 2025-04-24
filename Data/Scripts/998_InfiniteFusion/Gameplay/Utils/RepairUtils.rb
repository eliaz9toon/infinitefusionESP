def fixMissedHMs()
  # Flash
  if $PokemonBag.pbQuantity(:HM08) < 1 && $PokemonGlobal.questRewardsObtained.include?(:HM08)
    pbReceiveItem(:HM08)
  end

  # Cut
  if $PokemonBag.pbQuantity(:HM01) < 1 && $game_switches[SWITCH_SS_ANNE_DEPARTED]
    pbReceiveItem(:HM01)
  end

  # Strength
  if $PokemonBag.pbQuantity(:HM04) < 1 && $game_switches[SWITCH_SNORLAX_GONE_ROUTE_12]
    pbReceiveItem(:HM04)
  end

  # Surf
  if $PokemonBag.pbQuantity(:HM03) < 1 && $game_self_switches[[107, 1, "A"]]
    pbReceiveItem(:HM03)
  end

  # Teleport
  if $PokemonBag.pbQuantity(:HM07) < 1 && $game_switches[SWITCH_TELEPORT_NPC]
    pbReceiveItem(:HM07)
  end

  # Fly
  if $PokemonBag.pbQuantity(:HM02) < 1 && $game_self_switches[[439, 1, "B"]]
    pbReceiveItem(:HM02)
  end

  # Waterfall
  if $PokemonBag.pbQuantity(:HM05) < 1 && $game_switches[SWITCH_GOT_WATERFALL]
    pbReceiveItem(:HM05)
  end

  # Dive
  if $PokemonBag.pbQuantity(:HM06) < 1 && $game_switches[SWITCH_GOT_DIVE]
    pbReceiveItem(:HM06)
  end

  # Rock Climb
  if $PokemonBag.pbQuantity(:HM10) < 1 && $game_switches[SWITCH_GOT_ROCK_CLIMB]
    pbReceiveItem(:HM10)
  end
end

def fixFinishedRocketQuests()
  fix_broken_TR_quests()

  var_tr_missions_cerulean = 288

  switch_tr_mission_cerulean_4 = 1116
  switch_tr_mission_celadon_1 = 1084
  switch_tr_mission_celadon_2 = 1086
  switch_tr_mission_celadon_3 = 1088
  switch_tr_mission_celadon_4 = 1110
  switch_pinkan_done = 1119

  nb_cerulean_missions = pbGet(var_tr_missions_cerulean)

  finishTRQuest("tr_cerulean_1", :SUCCESS, true) if nb_cerulean_missions >= 1 && !pbCompletedQuest?("tr_cerulean_1")
  echoln pbCompletedQuest?("tr_cerulean_1")
  finishTRQuest("tr_cerulean_2", :SUCCESS, true) if nb_cerulean_missions >= 2 && !pbCompletedQuest?("tr_cerulean_2")
  finishTRQuest("tr_cerulean_3", :SUCCESS, true) if nb_cerulean_missions >= 3 && !pbCompletedQuest?("tr_cerulean_3")
  finishTRQuest("tr_cerulean_4", :SUCCESS, true) if $game_switches[switch_tr_mission_cerulean_4] && !pbCompletedQuest?("tr_cerulean_4")

  finishTRQuest("tr_celadon_1", :SUCCESS, true) if $game_switches[switch_tr_mission_celadon_1] && !pbCompletedQuest?("tr_celadon_1")
  finishTRQuest("tr_celadon_2", :SUCCESS, true) if $game_switches[switch_tr_mission_celadon_2] && !pbCompletedQuest?("tr_celadon_2")
  finishTRQuest("tr_celadon_3", :SUCCESS, true) if $game_switches[switch_tr_mission_celadon_3] && !pbCompletedQuest?("tr_celadon_3")
  finishTRQuest("tr_celadon_4", :SUCCESS, true) if $game_switches[switch_tr_mission_celadon_4] && !pbCompletedQuest?("tr_celadon_4")

  finishTRQuest("tr_pinkan", :SUCCESS, true) if $game_switches[switch_pinkan_done] && !pbCompletedQuest?("tr_pinkan")
end

def fix_broken_TR_quests()
  for trainer_quest in $player.quests
    if trainer_quest.id == 0 # tr quests were all set to ID 0 instead of their real ID in v 6.4.0
      for rocket_quest_id in TR_QUESTS.keys
        rocket_quest = TR_QUESTS[rocket_quest_id]
        next if !rocket_quest
        if trainer_quest.name == rocket_quest.name
          trainer_quest.id = rocket_quest_id
        end
      end
    end
  end
end

def failAllIncompleteRocketQuests()
  for trainer_quest in $player.quests
    finishTRQuest("tr_cerulean_1", :FAILURE) if trainer_quest.id == "tr_cerulean_1" && !pbCompletedQuest?("tr_cerulean_1")
    finishTRQuest("tr_cerulean_2", :FAILURE) if trainer_quest.id == "tr_cerulean_2" && !pbCompletedQuest?("tr_cerulean_2")
    finishTRQuest("tr_cerulean_3", :FAILURE) if trainer_quest.id == "tr_cerulean_3" && !pbCompletedQuest?("tr_cerulean_3")
    finishTRQuest("tr_cerulean_4", :FAILURE) if trainer_quest.id == "tr_cerulean_4" && !pbCompletedQuest?("tr_cerulean_4")

    finishTRQuest("tr_celadon_1", :FAILURE) if trainer_quest.id == "tr_celadon_1" && !pbCompletedQuest?("tr_celadon_1")
    finishTRQuest("tr_celadon_2", :FAILURE) if trainer_quest.id == "tr_celadon_2" && !pbCompletedQuest?("tr_celadon_2")
    finishTRQuest("tr_celadon_3", :FAILURE) if trainer_quest.id == "tr_celadon_3" && !pbCompletedQuest?("tr_celadon_3")
    finishTRQuest("tr_celadon_4", :FAILURE) if trainer_quest.id == "tr_celadon_4" && !pbCompletedQuest?("tr_celadon_4")
  end
end