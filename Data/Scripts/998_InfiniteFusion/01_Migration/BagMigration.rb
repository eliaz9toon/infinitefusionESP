class PokemonBag
  def pbQuantity(item)
    return quantity(item)
  end

  def pbHasItem?(item, qty = 1)
    return has?(item, qty)
  end

  def pbCanStore?(item, qty = 1)
    return can_add?(item, qty = 1)
  end

  def pbStoreItem(item, qty = 1)
    return add(item, qty = 1)
  end

  def pbStoreAllOrNone(item, qty = 1)
    add_all(item, qty = 1)
  end

  def pbChangeItem(old_item, new_item)
    replace_item(old_item, new_item)
  end

  def pbDeleteItem(item, qty = 1)
    remove(item, qty = 1)
  end

  def pbIsRegistered?(item)
    registered?(item)
  end

  def pbRegisterItem(item)
    register(item)
  end

  def pbUnregisterItem(item)
    unregister(item)
  end

end

#Shortcut methods
def pbQuantity(*args)
  return $bag.pbQuantity(*args)
end

def pbHasItem?(*args)
  return $bag.pbHasItem?(*args)
end

def pbCanStore?(*args)
  return $bag.pbCanStore?(*args)
end

def pbStoreItem(*args)
  return $bag.pbStoreItem(*args)
end

def pbStoreAllOrNone(*args)
  return $bag.pbStoreAllOrNone(*args)
end