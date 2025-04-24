def get_mart_exclusive_items(city)
  items_list = []
  case city
  when :PEWTER;
    items_list = [:ROCKGEM, :NESTBALL]
  when :VIRIDIAN;
    items_list = []
  when :CERULEAN;
    items_list = [:WATERGEM, :NETBALL, :PRETTYWING]
  when :VERMILLION;
    items_list = [:LOVEBALL, :ELECTRICGEM]
  when :LAVENDER;
    items_list = [:GHOSTGEM, :DARKGEM, :DUSKBALL]
  when :CELADON;
    items_list = [:GRASSGEM, :FLYINGGEM, :QUICKBALL, :TIMERBALL,]
  when :FUCHSIA;
    items_list = [:POISONGEM, :REPEATBALL]
  when :SAFFRON;
    items_list = [:PSYCHICGEM, :FIGHTINGGEM, :FRIENDBALL]
  when :CINNABAR;
    items_list = [:FIREGEM, :ICEGEM, :HEAVYBALL]
  when :CRIMSON;
    items_list = [:DRAGONGEM, :LEVELBALL]
  when :GOLDENROD;
    items_list = [:EVERSTONE, :MOONSTONE, :SUNSTONE, :DUSKSTONE, :DAWNSTONE, :SHINYSTONE]
  when :AZALEA;
    items_list = [:BUGGEM]
  when :VIOLET;
    items_list = [:FLYINGGEM, :STATUSBALL]
  when :BLACKTHORN;
    items_list = [:DRAGONGEM, :CANDYBALL]
  when :CHERRYGROVE;
    items_list = [:BUGGEM, :PUREBALL]
  when :MAHOGANY;
    items_list = []
  when :ECRUTEAK;
    items_list = [:GHOSTGEM, :DARKGEM]
  when :OLIVINE;
    items_list = []
  when :CIANWOOD;
    items_list = []
  when :KNOTISLAND;
    items_list = []
  when :BOONISLAND;
    items_list = []
  when :KINISLAND;
    items_list = []
  when :CHRONOISLAND;
    items_list = []
  end
  return items_list
end# frozen_string_literal: true

