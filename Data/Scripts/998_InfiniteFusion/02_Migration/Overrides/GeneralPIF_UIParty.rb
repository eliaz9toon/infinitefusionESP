  def pbChoosePokemon(helptext,index_game_var=1, name_game_var=2, able_proc = nil, _allow_ineligible = false)
    set_help_text(_INTL(helptext))
    chosen = -1
    pbFadeOutIn do
      screen = UI::Party.new($player.party, mode: :choose_pokemon)
      screen.set_able_annotation_proc(able_proc) if able_proc
      chosen = screen.choose_pokemon
    end
    pbSet(index_game_var, chosen)
    pbSet(name_game_var, (chosen >= 0) ? $player.party[chosen].name : "")
    return chosen
  end
