# frozen_string_literal: true

def pokemart_clothes_shop(current_city = nil, include_defaults = true)
  current_city = pbGet(VAR_CURRENT_MART) if !current_city
  echoln current_city
  current_city = :PEWTER if !current_city.is_a?(Symbol)
  current_city_tag = current_city.to_s.downcase
  selector = OutfitSelector.new
  list = selector.generate_clothes_choice(
    baseOptions = include_defaults,
    additionalIds = [],
    additionalTags = [current_city_tag],
    filterOutTags = [])
  clothesShop(list)
end

def pokemart_hat_shop(include_defaults = true)
  current_city = pbGet(VAR_CURRENT_MART)
  current_city = :PEWTER if !current_city.is_a?(Symbol)
  current_city_tag = current_city.to_s.downcase
  selector = OutfitSelector.new
  list = selector.generate_hats_choice(
    baseOptions = include_defaults,
    additionalIds = [],
    additionalTags = [current_city_tag],
    filterOutTags = [])

  hatShop(list)
end
