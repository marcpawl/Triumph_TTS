def troop_type_to_name(troop_type) :
  if troop_type == "Prepared Defenses" :
      return troop_type
  if troop_type == "WWG" :
    return "War Wagons"
  if troop_type == "CAT" :
    return "Cataphracts"
  if troop_type == "KNT" :
    return "Knights"
  if troop_type == "PAV" :
    return "Pavisiers"
  if troop_type == "ECV" :
    return "Elite Cavalry"
  if troop_type == "HBW" :
    return "Horse Bow"
  if troop_type == "ART" :
    return "Artillery"
  if troop_type == "JCV" :
    return "Javelin Cavalry"
  if troop_type == "SPR" or troop_type == "Spear" or troop_type == "Spears":
    return "Spears"
  if troop_type == "ELE" :
    return "Elephants"
  if troop_type == "WRR" or troop_type == "Warrior" or troop_type == "Warriors":
    return "Warriors"
  if troop_type == "BTX" :
    return "Battle Taxi"
  if troop_type == "BAD" :
    return "Bad Horse"
  if troop_type == "WBD" or troop_type == "Warband":
    return "Warband"
  if troop_type == "ARC" or troop_type == "Archer" or troop_type == "Archers":
    return "Archers"
  if troop_type == "RDR" or troop_type == "Raider" or troop_type == "Raiders":
    return "Raiders"
  if troop_type == "BLV" :
    return "Bow Levy"
  if troop_type == "RBL" :
    return "Rabble"
  if troop_type == "HRD" :
    return "Horde"
  if troop_type == "SKM" or troop_type == "Skirmisher" or troop_type == "Skirmishers" :
    return "Skirmishers"
  if troop_type == "CHT" :
    return "Chariots"
  if troop_type == "LFT" or troop_type == "Light Foot" :
    return "Light Foot"
  if troop_type == "HFT" or troop_type == "Heavy Foot" :
    return "Heavy Foot"
  if troop_type == "EFT" or troop_type == "Elite Foot" :
    return "Elite Foot"
  if troop_type == "PIK" or troop_type == "Pike" or troop_type == "Pikes":
    return "Pikes"
  if troop_type == "LSP" or troop_type == "Light Spear" or troop_type == "Light Spears" :
    return 'Light Spear'
  if troop_type == "Camp" :
    return 'Camp'
  if troop_type == "Elephant Screen Counter" :
    return  "Elephant Screen Counter"
  raise Exception("troop_type not understood: " + troop_type)
