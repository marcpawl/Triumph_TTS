#!/usr/bin/python3
# Create the TTS army definitions.

import json
import os
import sys
import subprocess
import re
from troop_type import troop_type_to_name


# set of the identifiers of the base definitions that have already
# been written
base_definitions_written=set()

re_safe_string = "[^-:/a-zA-Z0-9 (),]"

def make_safe_string(udata) :
    """Remove special characters."""
    asciidata=udata.encode("ascii", "ignore").decode("ascii")
    if udata != asciidata :
        print(udata, " is not ascii.")
        m=max( len(udata), len(asciidata))
        for i in range(0,m-1) :
            print(i, ' ', udata[i], ' ', asciidata[i])
    return asciidata

def read_json(file_name) :
  with open(file_name, "r") as file:
    text = file.read()
    data = json.loads(text)
    return data

def read_army_json(army_id) :
  file_name = os.path.join("armyLists", army_id + ".army.json")
  army_json = read_json(file_name)
  # Push down date ranges to make it easier to see if the troop entries are in an army for date range.
  army_json['dateRange'] = {}
  army_json['dateRange']['startDate'] = army_json['derivedData']['listStartDate']
  army_json['dateRange']['endDate'] = army_json['derivedData']['listEndDate']
  troop_options = army_json['troopOptions']
  for troop_option in  troop_options :
    if 'dateRange' not in troop_option or troop_option['dateRange']  is None:
      troop_option['dateRange'] = army_json['dateRange']
  return army_json

def read_army_theme_json(army_id) :
  file_name = os.path.join("armyLists", army_id + ".thematicCategories.json")
  return read_json(file_name)

def read_army_ally_options(army_id) :
  file_name = os.path.join("armyLists", army_id + ".allyOptions.json")
  allies = read_json(file_name)
  # Push down date ranges to make it easier to see if the troop entries are in an army for date range.
  for ally in allies :
    for allyEntry in ally['allyEntries'] :
      set_date_range(allyEntry, ally['dateRange'])
      allyArmyList=allyEntry['allyArmyList']
      set_date_range(allyArmyList, allyEntry['dateRange'])
      for troop_option in allyArmyList['troopOptions'] :
          set_date_range(troop_option, allyArmyList['dateRange'])
          for troop_entry in troop_option['troopEntries'] :
            set_date_range(troop_entry, troop_option['dateRange'])
  return allies

def set_date_range(destination, dates) :
  if 'dateRange' not in destination  or (destination['dateRange'] is None):
    destination['dateRange'] = dates
  else:
    if dates is None:
      return
    dest = destination['dateRange']
    if not between(dates['startDate'], dest['startDate'], dates['endDate']) :
      #print("ERROR start date is out of range. ", dates['startDate'], dest['startDate'], dates['endDate'])
      pass
    if not between(dates['startDate'], dest['endDate'], dates['endDate']) :
      #print("ERROR end date is out of range.", dates['startDate'], dest['endDate'], dates['endDate'])
      pass

    dest['startDate'] = max( dates['startDate'], dest['startDate'] )
    dest['endDate'] = min( dates['endDate'], dest['endDate'] )


def get_points_for_troop_type(troop_type) :
  if troop_type == "WWG" or troop_type == "War Wagons":
    return 3
  if troop_type == "CAT" or troop_type ==  "Cataphracts":
    return 4
  if troop_type == "KNT" or troop_type == "Knights":
    return 4
  if troop_type == "PAV" or troop_type == "Pavisiers" :
    return 4
  if troop_type == "ECV" or troop_type ==  "Elite Cavalry":
    return 4
  if troop_type == "HBW" or troop_type ==  "Horse Bow":
    return 4
  if troop_type == "ART" or troop_type ==  "Artillery":
    return 3
  if troop_type == "JCV" or troop_type ==  "Javelin Cavalry":
    return 4
  if troop_type == "SPR" or troop_type ==  "Spears" or troop_type == "Spear":
    return 4
  if troop_type == "ELE" or troop_type ==  "Elephants":
    return 4
  if troop_type == "WRR" or troop_type ==  "Warriors" or  troop_type ==  "Warrior":
    return 3
  if troop_type == "BTX" or troop_type ==  "Battle Taxi":
    return 3
  if troop_type == "BAD" or troop_type ==  "Bad Horse":
    return 3
  if troop_type == "WBD" or troop_type ==  "Warband":
    return 3
  if troop_type == "ARC" or troop_type ==  "Archers" or troop_type ==  "Archer":
    return 4
  if troop_type == "RDR" or troop_type == "Raiders" or troop_type == "Raider":
    return 4
  if troop_type == "BLV" or troop_type ==  "Bow Levy":
    return 2
  if troop_type == "RBL" or troop_type ==  "Rabble":
    return 2
  if troop_type == "HRD" or troop_type ==  "Horde":
    return 2
  if troop_type == "SKM" or troop_type ==  "Skirmisher" or troop_type ==  "Skirmishers":
    return 3
  if troop_type == "CHT" or troop_type ==  "Chariots":
    return 4
  if troop_type == "LFT" or troop_type ==  "Light Foot":
    return 3
  if troop_type == "HFT" or troop_type ==  "Heavy Foot":
    return 3
  if troop_type == "EFT" or troop_type ==  "Elite Foot":
    return 4
  if troop_type == "PIK" or troop_type ==  "Pikes" or troop_type == "Pike":
    return 3
  if troop_type == "LSP" or troop_type ==  'Light Spear':
    return 3
  raise Exception("troop_type not understood: " + str(troop_type))

def is_general(base_definition):
  return ('general' in base_definition) and (base_definition['general'] == True)

def get_dismounting_type(base_definition, battle_card_note) :
  # DD  only 1477 AD: as Elite Foot
  # DD  1328-1515 AD: as Elite Foot
  # DD  1335-1399 AD: as Archer
  # DD  1362-1419 AD: as Elite Foot
  # DD  639-843 AD, as Heavy Foot
  # DD  as Archer
  # DD  as Elite Foot
  # DD  as Heavy Foot
  # DD  as Light Foot
  # DD  as Pike
  # DD  as Raider
  # DD  as Spear
  # DD  as Warrior
  r=re.compile("^(((only )|(\\d*-))\\d* AD[:,] *)?as *(?P<troop_type>.*)")
  m = r.match(battle_card_note)
  if m is not None :
    dismount =  m.group('troop_type')
    if dismount == "Pike" :
      return "Pikes"
    elif dismount == "Spear" :
      return "Spears"
    return dismount
  elif (battle_card_note == "General only; as Pike") :
    if is_general(base_definition) :
      return "Pikes"
    else:
      return None
  elif battle_card_note == "German Knights as Elite Foot; Lithuanian Javelin Cavalry as Archers" :
      print("base_definition=", base_definition)
      if base_definition['troop_type'] == "KNT" :
        return "Elite Foot"
      if base_definition['troop_type'] == "JCV" :
        return "Archers"
      return None
  else:
    print("Unable to decode battle card note ", battle_card_note)
    print("base_definition=", base_definition)
    assert False


def write_deployment_dismounting_as(file, base_definition, dismount_type, battle_card) :
  """
  @return list of base defintions for mounted and dismounted.
  """
  assert dismount_type is not None
  mounted = base_definition.copy()
  dismounted = base_definition.copy()

  if ("min" in battle_card)  and (battle_card["min"] is not None):
    mounted["min"] = battle_card["min"]
    dismounted["min"] = battle_card["min"]
  if ("max" in battle_card)  and (battle_card["max"] is not None):
    mounted["max"] = battle_card["max"]
    dismounted["max"] = battle_card["max"]
  if ('general' in base_definition) and (base_definition['general'] == True) :
    mounted["max"] = 1
    dismounted["max"] = 1

  mounted['id'] += "_mounted"
  dismounted['id'] += "_dismounted"

  dismounted['troop_type'] = troop_type_to_name(dismount_type)
  dismounted['name'] = troop_type_to_name(dismount_type)
  if 'general' in dismounted:
    dismounted['name'] = troop_type_to_name(dismounted['name']) + " General"


  # Calculate the points for being able to dismount
  mounted_points = get_points_for_troop_type(base_definition['troop_type'])
  dismounted_points = get_points_for_troop_type(dismount_type)
  points = max(mounted_points, dismounted_points) + 0.5
  mounted['points'] = points
  dismounted['points'] = points

  if 'description' not in mounted :
    mounted['description'] = ""
  else:
    mounted['description'] += "\\n"

  if 'description' not in dismounted :
    dismounted['description'] = ""
  else:
    dismounted['description'] += "\\n"

  mounted['description'] += "Deployment dismounting as " + dismount_type
  dismounted['description'] += "Deployment dismounted from " + mounted['name']

  mounted['dismount_as'] = "g_str_" + dismounted['id']
  dismounted['dismounted_from'] = "g_str_" + mounted['id']

  mounted['deployment_dismounting']=True

  write_base_definition_id(file, dismounted)
  write_base_definition_id(file, mounted)
  write_base_definition_details(file, dismounted)
  write_base_definition_details(file, mounted)

  return (mounted, dismounted)

def write_deployment_dismounting(file, base_definition, battle_card) :
  note = battle_card['note']
  dismount_type = get_dismounting_type(base_definition, note)
  if dismount_type is not None:
    return write_deployment_dismounting_as(file, base_definition, dismount_type, battle_card)

def write_mid_battle_dismounting_as(file, base_definition, dismount_type, battle_card) :
  """
  @return list of base defintions for mounted and dismounted.
  """
  assert dismount_type is not None
  mounted = base_definition.copy()
  dismounted = base_definition.copy()

  if ("min" in battle_card)  and (battle_card["min"] is not None):
    mounted["min"] = battle_card["min"]
    dismounted["min"] = battle_card["min"]
  if ("max" in battle_card)  and (battle_card["max"] is not None):
    mounted["max"] = battle_card["max"]
    dismounted["max"] = battle_card["max"]
  if ('general' in base_definition) and (base_definition['general'] == True) :
    mounted["max"] = 1
    dismounted["max"] = 1

  mounted['id'] += "_mounted"
  dismounted['id'] += "_dismounted"

  dismounted['troop_type'] = troop_type_to_name(dismount_type)
  dismounted['name'] = troop_type_to_name(dismount_type)
  if 'general' in dismounted:
    dismounted['name'] = troop_type_to_name(dismounted['name']) + " General"

  if 'description' not in mounted :
    mounted['description'] = ""
  else:
    mounted['description'] += "\\n"

  if 'description' not in dismounted :
    dismounted['description'] = ""
  else:
    dismounted['description'] += "\\n"

  mounted['description'] += "Mid-battle dismounting as " + dismount_type
  dismounted['description'] += "Mid-battle dismounted from " + mounted['name']

  mounted['dismount_as'] = "g_str_" + dismounted['id']
  dismounted['dismounted_from'] = "g_str_" + mounted['id']

  mounted['mid_battle_dismounting']=True

  write_base_definition_id(file, dismounted)
  write_base_definition_id(file, mounted)
  write_base_definition_details(file, dismounted)
  write_base_definition_details(file, mounted)

  return (mounted, dismounted)


def write_mid_battle_dismounting(file, base_definition, battle_card) :
  note = battle_card['note']
  if note is None:
    # Feudal German Kings or Emperors is missing dismount type
    return []
  else:
    dismount_type = get_dismounting_type(base_definition, note)
    return write_mid_battle_dismounting_as(file, base_definition, dismount_type, battle_card)

def write_mobile_infantry(file, base_definition, battle_card):
  """
     @param file Open file to write the definitions to.
     @param base_definition Defintinition of the base the battle card is being applied to.
     @param battle_card Battle card being applied.
     @return the extra base definitions for the mounted and dismounted infantry.
  """
  troop_type_name = troop_type_to_name( base_definition['troop_type'])
  if troop_type_name == "Bad Horse":
      # Kievan Rus have Elite Foot or Bad Horse with Mobile Infantry
      # battle card.  We are not going to place the horses in
      # trailers.
      return []

  mounted = base_definition.copy()
  dismounted = base_definition.copy()

  if ("min" in battle_card)  and (battle_card["min"] is not None):
    mounted["min"] = battle_card["min"]
    dismounted["min"] = battle_card["min"]
  if ("max" in battle_card)  and (battle_card["max"] is not None):
    mounted["max"] = battle_card["max"]
    dismounted["max"] = battle_card["max"]
  if ('general' in base_definition) and (base_definition['general'] == True) :
    mounted["max"] = 1
    dismounted["max"] = 1

  mounted['id'] = mounted['id'] + "_mounted_mobile_infantry"
  dismounted['id'] = dismounted['id'] + "_dismounted_mobile_infantry"

  if 'description' not in mounted :
    mounted['description'] = ""
  else:
    mounted['description'] += "\\n"
  if 'description' not in dismounted :
    dismounted['description'] = ""
  else:
    dismounted['description'] += "\\n"
  dismounted['description'] += "Dismounted mobile infantry"
  mounted['description'] += "mounted mobile infantry"

  mounted['dismount_as'] = "g_str_" + dismounted['id']
  dismounted['dismounted_from'] = "g_str_" + mounted['id']

  mounted['mobile_infantry'] = True

  write_base_definition_id(file, dismounted)
  write_base_definition_id(file, mounted)
  write_base_definition_details(file, dismounted)
  write_base_definition_details(file, mounted)

  return [ mounted, dismounted]

def write_separated_valets(file, base_definition, battle_card) :
    print("TODO write_separated_valets")
    return []


def write_armored_camelry(file, base_definition, battle_card) :
  camels = base_definition.copy()

  if ("min" in battle_card)  and (battle_card["min"] is not None):
    camels["min"] = battle_card["min"]
  if ("max" in battle_card)  and (battle_card["max"] is not None):
    camels["max"] = battle_card["max"]
  if ('general' in base_definition) and (base_definition['general'] == True) :
    camels["max"] = 1

  camels['id'] = camels['id'] + "_armored_camelry"

  if 'description' not in camels :
    camels['description'] = ""
  else:
    camels['description'] += "\\n"
  camels['description'] += "Armored Camelry"

  camels['armored_camelry'] = True
  write_base_definition(file, camels)
  return [ camels ]


def write_light_camelry(file, base_definition, battle_card) :
  camels = base_definition.copy()

  if ("min" in battle_card)  and (battle_card["min"] is not None):
    camels["min"] = battle_card["min"]
  if ("max" in battle_card)  and (battle_card["max"] is not None):
    camels["max"] = battle_card["max"]
  if ('general' in base_definition) and (base_definition['general'] == True) :
    camels["max"] = 1

  camels['id'] = camels['id'] + "_light_camelry"

  if 'description' not in camels :
    camels['description'] = ""
  else:
    camels['description'] += "\\n"
  camels['description'] += "Light Camelry"

  camels['light_camelry'] = True
  write_base_definition(file, camels)
  return [ camels ]


def write_charging_camelry(file, base_definition, battle_card) :
  camels = base_definition.copy()

  if ("min" in battle_card)  and (battle_card["min"] is not None):
    camels["min"] = battle_card["min"]
  if ("max" in battle_card)  and (battle_card["max"] is not None):
    camels["max"] = battle_card["max"]
  if ('general' in base_definition) and (base_definition['general'] == True) :
    camels["max"] = 1

  camels['id'] = camels['id'] + "_charging_camelry"

  if 'description' not in camels :
    camels['description'] = ""
  else:
    camels['description'] += "\\n"
  camels['description'] += "Charging Camelry"

  camels['charging_camelry'] = True
  write_base_definition(file, camels)
  return [ camels ]

def write_elephant_screen(file, base_definition, battle_card) :
  with_elephants = base_definition.copy()

  if ("min" in battle_card)  and (battle_card["min"] is not None):
    with_elephants["min"] = battle_card["min"]
  if ("max" in battle_card)  and (battle_card["max"] is not None):
    with_elephants["max"] = battle_card["max"]
  if ('general' in base_definition) and (base_definition['general'] == True) :
    with_elephants["max"] = 1

  with_elephants['id'] = with_elephants['id'] + "_elephant_screen"

  if 'description' not in with_elephants :
    with_elephants['description'] = ""
  else:
    with_elephants['description'] += "\\n"
  with_elephants['description'] += "Elephant Screen"

  with_elephants['elephant_screen'] = True
  write_base_definition(file, with_elephants)

  elephant_screen_counter = {
    'name' : 'Elephant Screen',
    'troop_type' : 'Elephant Screen Counter',
    'base_definition':'tile_plain_El_Screen',
   }
  elephant_screen_counter['id'] = with_elephants['id'] + "_elephant_screen_counter"
  if ("min" in battle_card)  and (battle_card["min"] is not None):
    elephant_screen_counter["min"] = battle_card["min"]
  else:
    elephant_screen_counter["min"] = base_definition['min']
  if ("max" in battle_card)  and (battle_card["max"] is not None):
    elephant_screen_counter["max"] = battle_card["max"]
  else:
    elephant_screen_counter["max"] = base_definition['max']
  write_base_definition(file, elephant_screen_counter)

  return [ with_elephants ]

def write_plaustrella(file, base_definition, battle_card) :
  plaustrella = base_definition.copy()

  if ("min" in battle_card)  and (battle_card["min"] is not None):
    plaustrella["min"] = battle_card["min"]
  if ("max" in battle_card)  and (battle_card["max"] is not None):
    plaustrella["max"] = battle_card["max"]
  if ('general' in base_definition) and (base_definition['general'] == True) :
    plaustrella["max"] = 1

  plaustrella['id'] = plaustrella['id'] + "_plaustrella"

  if 'description' not in plaustrella :
    plaustrella['description'] = ""
  else:
    plaustrella['description'] += "\\n"
  plaustrella['description'] += "Plaustrella"

  plaustrella['plaustrella'] = True
  write_base_definition(file, plaustrella)
  return [ plaustrella ]

def write_shower_shooting(file, base_definition, battle_card) :
  shower_shooting = base_definition.copy()

  if ("min" in battle_card)  and (battle_card["min"] is not None):
    shower_shooting["min"] = battle_card["min"]
  if ("max" in battle_card)  and (battle_card["max"] is not None):
    shower_shooting["max"] = battle_card["max"]
  if ('general' in base_definition) and (base_definition['general'] == True) :
    shower_shooting["max"] = 1

  shower_shooting['id'] = shower_shooting['id'] + "_shower_shooting"

  if 'description' not in shower_shooting :
    shower_shooting['description'] = ""
  else:
    shower_shooting['description'] += "\\n"
  shower_shooting['description'] += "Shower Shooting"

  shower_shooting['shower_shooting'] = True
  write_base_definition(file, shower_shooting)
  return [ shower_shooting ]


def write_fortified_camp(file, camp_definition, battle_card) :
  fort = camp_definition.copy()

  fort['id'] = fort['id'] + "_fortified"

  fort['fortified_camp'] = True
  fort['description'] = "Fortified camp"
  write_base_definition(file, fort)
  return [ fort ]

def write_pack_train_and_herds(file, camp_definition, battle_card) :
  pack_train = camp_definition.copy()

  pack_train['id'] = pack_train['id'] + "_pack_train"

  pack_train['pack_train'] = True
  pack_train['description'] = "Pack Train"
  write_base_definition(file, pack_train)
  return [ pack_train ]

def write_standard_wagon(file, camp_definition, battle_card) :
  wagon = camp_definition.copy()

  wagon['id'] = wagon['id'] + "_standard_wagon"

  wagon['standard_wagon'] = True
  wagon['description'] = "Standard Wagon"
  write_base_definition(file, wagon)
  return [ wagon ]


def write_pack_train_and_herds(file, camp_definition, battle_card) :
  pack_train = camp_definition.copy()

  pack_train['id'] = pack_train['id'] + "_pack_train"

  pack_train['pack_train'] = True
  pack_train['description'] = "Pack Train"
  write_base_definition(file, pack_train)
  return [ pack_train ]


def write_prepared_defenses(file, army_id, battle_card) :
  if "min" in battle_card :
    min = battle_card['min']
  else:
    min = 0
  if "max" in battle_card:
    max = battle_card['max']
  else:
    max = 16 # No specific mention in the battle card rules

  id = army_id + "_prepared_defenses"
  description = "Prepared Defenses"
  troop_type = "Prepared Defenses"
  name = "Prepared Defenses"

  #troop_option_id = troop_option['_id']

  base_definition = {
    'id': id, 'name':name,
    'troop_type':troop_type,
    'min':min, 'max':max,
    'description': battle_card['note'],
    #'troop_option_id': troop_option_id
    'prepared_defenses':True
    }
  write_base_definition(file, base_definition)
  return [ base_definition ]

def create_base_definition(troop_option, troop_entry) :
  min = troop_option['min']
  max = troop_option['max']

  id = troop_entry['_id']
  if id == '5fb1ba37e1af06001770e72d' :
    description = "German or Polish men-at-arms"
  elif id ==  "5fb1ba37e1af06001770e72e" :
    description = "Lithuanian horsemen"
  else :
    description = troop_option['description']


  troop_type = troop_entry['troopTypeCode']
  name = troop_type_to_name(troop_type)

  troop_option_id = troop_option['_id']

  base_definition = {
    'id': id, 'name':name, 'troop_type':troop_type,
    'min':min, 'max':max,
    'description':description,
    'troop_option_id': troop_option_id }

  if 'battleCardEntries' in troop_entry:
    for battle_card in troop_entry['battleCardEntries'] :
      code = battle_card['battleCardCode']
      if code == "CT" :
          base_definition['charge_through'] = True
      elif code == "HD" :
          base_definition['hoplite_deep_formation'] = True
      elif code == "HL" :
          base_definition['hold_the_line'] = True

  return base_definition

def write_base_definition_id(file, base_definition) :
  id = base_definition['id']
  file.write("g_str_%s='%s'\n" % (id,id))

def write_base_definition_details(file, base_definition) :
  if 'description' not in base_definition:
    description = ""
  else:
    #escape quotes
    description = base_definition['description']
    description = description.replace("'", "\\'")

  id = base_definition['id']

  file.write("g_base_definitions[g_str_%s]={\n" % (id))
  file.write("  id=g_str_%s,\n" % (id))
  file.write("  name='%s',\n" % (base_definition['name']))
  file.write("  min=%d,\n" % (base_definition['min']))
  file.write("  max=%d,\n" % (base_definition['max']))
  file.write("  description='%s',\n" % (description))
  if 'points' in base_definition :
    file.write("  points=%d,\n" % (base_definition['points']))
  if 'dismount_as' in base_definition :
    file.write("  dismount_as=%s,\n" % (base_definition['dismount_as']))
  if 'dismounted_from' in base_definition :
    file.write("  dismounted_from=%s,\n" % (base_definition['dismounted_from']))
  for k in [
    'general',
    'charge_through', 'hold_the_line', 'hoplite_deep_formation',
    'deployment_dismounting',
    'mid_battle_dismounting',
    'mobile_infantry', 'armored_camelry', 'charging_camelry', 'light_camelry', 'elephant_screen',
    'plaustrella', 'shower_shooting',
    'fortified_camp', 'pack_train', 'standard_wagon', 'prepared_defenses'] :
    if k in base_definition  and base_definition[k] == True :
      file.write("  %s=true,\n" % (k))
  troop_type_name = troop_type_to_name( base_definition['troop_type'])
  file.write("  troop_type=\"%s\",\n" %(troop_type_name))
  if 'troop_option_id' in base_definition :
    troop_option_id = base_definition['troop_option_id']
    file.write("  troop_option_id=\"%s\",\n" %(troop_option_id))
  file.write("}\n")

def write_base_definition(file, base_definition) :
  if base_definition['id'] not in base_definitions_written:
    write_base_definition_id(file, base_definition)
    write_base_definition_details(file, base_definition)
    base_definitions_written.add( base_definition['id'])

def get_general_troop_type_codes(army) :
  codes = {}
  if 'troopEntriesForGeneral' not in army :
    return codes

  for troop_entry_for_general in army['troopEntriesForGeneral'] :
    for troop_entry in troop_entry_for_general['troopEntries'] :
      troop_type = troop_entry['troopTypeCode']
      codes[troop_type] = 1
  return codes


def write_battle_cards(file, army, troop_option, troop_entry, base_definition)  :
  """Return the base definitions of the bases created due to battle cards."""
  result = []
  write_base_definition(file, base_definition)
  for battle_card in troop_entry['battleCardEntries'] :
    code = battle_card['battleCardCode']
    note = battle_card['note']
    if code == "DD" :
      id = troop_entry['_id']
      if id == '5fb1ba37e1af06001770e72d' :
        # "German or Polish men-at-arms"
        extra = write_deployment_dismounting_as(file, base_definition, "Elite Foot", battle_card)
        result.extend(extra)
      elif id ==  "5fb1ba37e1af06001770e72e" :
        #"Lithuanian horsemen"
        extra = write_deployment_dismounting_as(file, base_definition, "Archers", battle_card)
        result.extend(extra)
      elif battle_card['_id'] == "5fb1ba34e1af06001770e1a0" :
        extra = write_deployment_dismounting_as(file, base_definition, "Pikes", battle_card)
        result.extend(extra)
      else:
        extra = write_deployment_dismounting(file, base_definition, battle_card)
        if extra is not None:
          result.extend(extra)
    elif code == "SV" :
        extra = write_separated_valets(file, base_definition, battle_card)
        result.extend(extra)
    elif code == "MD" :
        extra = write_mid_battle_dismounting(file, base_definition, battle_card)
        result.extend(extra)
    elif code == "MI" :
        extra = write_mobile_infantry(file, base_definition, battle_card)
        result.extend(extra)
    elif code == "AC" :
        extra = write_armored_camelry(file, base_definition, battle_card)
        result.extend(extra)
    elif code == "LC" :
        extra = write_light_camelry(file, base_definition, battle_card)
        result.extend(extra)
    elif code == "CC" :
        extra = write_charging_camelry(file, base_definition, battle_card)
        result.extend(extra)
    elif code == "ET" :
        extra = write_elephant_screen(file, base_definition, battle_card)
        result.extend(extra)
    elif code == "PL" :
        extra = write_plaustrella(file, base_definition, battle_card)
        result.extend(extra)
    elif code == "SS" :
        extra = write_shower_shooting(file, base_definition, battle_card)
        result.extend(extra)
    else:
      pass
#      print("Unknown battle card ", code)

  return result


def base_definitions(file, army, troop_option) :
  """
    @return List of base definitions
  """
  result = []
  generals = get_general_troop_type_codes(army)

  for troop_entry in troop_option['troopEntries'] :
    # Push down the battle cards
    troop_entry['battleCardEntries'] = troop_option['battleCardEntries']

    if troop_entry['troopTypeCode'] in generals :
      base_definition = create_base_definition(troop_option, troop_entry)
      base_definition['max'] = 1
      base_definition['general'] = True
      base_definition['name'] = base_definition['name'] + " General"
      base_definition['id'] = base_definition['id'] + "_general"
      result.append(base_definition)
      extra = write_battle_cards(file, army, troop_option, troop_entry, base_definition)
      result.extend(extra)

    base_definition = create_base_definition(troop_option, troop_entry)
    result.append(base_definition)
    extra = write_battle_cards(file, army, troop_option, troop_entry, base_definition)
    if extra is not None :
      result.extend(extra)


  return result

# Return the ID for the troop entry that matches the troop
# type.  None is returned if there is no existing unit
# that the general can be part of.
def find_troop_entry_for_troop_type(army_json, troop_type) :
  troop_options = army_json['troopOptions']
  for troop_option in  troop_options :
    for troop_entry in troop_option['troopEntries'] :
      if troop_entry['troopTypeCode'] == troop_type :
        return troop_entry['_id']
  return None


# Write out the base definition for a camp
def write_camp(file, army_id) :
  camp_def = {
    'id' : army_id + "_camp",
    'name' : 'Camp',
    'troop_type' : 'Camp',
    'min': 0,
    'max': 1,
    'description': 'Camp'
  }
  write_base_definition(file, camp_def)
  return [camp_def]


def generate_base_definitions(file, army_json) :
  """Write out the base definitions for the army.
     @param file File to write to
     @param army_json Defintion of the army.
     @return The base definitions for the army.
  """
  definitions = []

  troop_options = army_json['troopOptions']
  for troop_option in  troop_options :
    defs = base_definitions(file, army_json, troop_option)
    definitions.extend(defs)

  camp_definitions = write_camp(file, army_id)
  definitions.extend(camp_definitions)
  if 'battleCardEntries' in army_json :
    for camp_definition in camp_definitions :
      for battle_card in army_json['battleCardEntries'] :
        if battle_card['battleCardCode'] == "FC" :
          extra = write_fortified_camp(file, camp_definition, battle_card)
          definitions.extend(extra)
        elif battle_card['battleCardCode'] == "PT" :
          extra = write_pack_train_and_herds(file, camp_definition, battle_card)
          definitions.extend(extra)
        elif battle_card['battleCardCode'] == "SW" :
          extra = write_standard_wagon(file, camp_definition, battle_card)
          definitions.extend(extra)
        elif battle_card['battleCardCode'] == "PD" :
          extra = write_prepared_defenses(file, army_id, battle_card)
          definitions.extend(extra)
  return definitions

def get_troop_option(army_json, base_definition)  :
  if 'troop_option_id' not in base_definition :
    return None
  id = base_definition['troop_option_id']
  troop_options = army_json['troopOptions']
  for troop_option in  troop_options :
    if troop_option['_id'] == id :
      return troop_option
  return None

def between(low, mid, high) :
  if low > mid :
    return False
  if mid > high :
    return False
  return True

def is_option_in_date_range(troop_option, startDate, endDate)  :
  if troop_option is None :
    return True
  dateRange = troop_option['dateRange']
  assert(dateRange is not None)
  option_start = dateRange['startDate']
  option_end = int(dateRange['endDate'])
  if  between(startDate, option_start, endDate) :
    return True
  if  between(startDate, option_end, endDate) :
    return True
  if between(option_start, startDate, option_end) :
    return True
  if between(option_start, endDate, option_end) :
    return True
  return False

def year_string(year) :
  if year < 0 :
    return str(-year) + " BC"
  else:
    return str(year) + " AD"

def date_string(startDate, endDate) :
  if startDate == endDate :
    return year_string(startDate)
  else:
    return "%s to %s" % (year_string(startDate), year_string(endDate))


def get_optional_contingents(army_ally_options_json):
  """Extract the ally_army options for the ally's that are internal. """
  result = []
  for ally in army_ally_options_json :
    for allyEntry in ally['allyEntries'] :
      allyArmyList=allyEntry['allyArmyList']
      if "internalContingent" in allyArmyList and allyArmyList["internalContingent"]:
        result.append(allyArmyList)
  return result

def get_dates_for_troop_options(troop_options) :
    """ Return the dates that are mentioned in the troop options
        date ranges.
        @param troop_options Troops to scan.
        @return list of dates, unsorted, and possibly duplicated.
    """
    dates=[]
    for troop_option in  troop_options :
      if "dateRange" in troop_option :
        date_range = troop_option['dateRange']
        if date_range is not None:
          startDate = int(date_range['startDate'])
          endDate = int(date_range['endDate'])
          dates.append(startDate)
          dates.append(endDate+1)
    return dates

def get_dates_for_optional_contingents(army_ally_options_json) :
  """Even though the optional contingents are stored in the
     allies file they are really part of the army.
     @param army_ally_options_json Armies alies.
     @return list of dates, unsorted, and possibly duplicated.
  """
  dates=[]
  for ally in army_ally_options_json :
    for allyEntry in ally['allyEntries'] :
      allyArmyList=allyEntry['allyArmyList']
      if "internalContingent" in allyArmyList and allyArmyList["internalContingent"]:
          troopOptions =allyArmyList['troopOptions']
          option_dates = get_dates_for_troop_options(troopOptions)
          dates.extend(option_dates)
  return dates

def get_dates_for_triumph_allies(army_ally_options_json) :
  """Get the dates that the troop options have for the allies of
     an army.  Used for Triumph!.  Grand Triumph! uses the
     allies entire army, whose date are not include in this result.
     @param army_ally_options_json Armies alies.
     @return list of dates, unsorted, and possibly duplicated.
  """
  dates=[]
  for ally in army_ally_options_json :
    for allyEntry in ally['allyEntries'] :
      allyArmyList=allyEntry['allyArmyList']
      troopOptions =allyArmyList['troopOptions']
      option_dates = get_dates_for_troop_options(troopOptions)
      dates.extend(option_dates)
  return dates

def get_dates_for_grand_triumph_allies(army_ally_options_json) :
  """Get the dates that the troop options have for the allies of
     an army.  Used for Triumph!.  Grand Triumph! uses the
     allies entire army, whose date are not include in this result.
     @param army_ally_options_json Armies alies.
     @return list of dates, unsorted, and possibly duplicated.
  """
  dates=[]
  for ally in army_ally_options_json :
    for allyEntry in ally['allyEntries'] :
      allyArmyList=allyEntry['allyArmyList']
      if 'armyListId' in allyArmyList :
        ally_armyListId = allyArmyList['armyListId']
        ally_army_json = read_army_json(ally_armyListId)
        ally_dates = get_dates_for_army_no_allies(ally_army_json)
        dates.extend(ally_dates)
  return dates


def get_dates_for_army_no_allies(army_json) :
  """Get the dates that make up the army.  Includes the army date range,
     and the date ranges of any troops.  But not the date ranges of
     the allies.
     @param army_json Army to query.
     @return list of dates, unsorted, and possibly duplicated.
  """
  if "dateRange" not in army_json :
    raise Exception("No army date range in " + army_id)
  army_date_range = army_json['dateRange']
  army_date_range = army_date_range
  army_startDate = int(army_date_range['startDate'])
  army_endDate = int(army_date_range['endDate'])

  dates = [army_startDate, army_endDate+1]
  troop_options = army_json['troopOptions']
  troop_option_dates = get_dates_for_troop_options(troop_options)
  dates.extend(troop_option_dates)

  army_ally_options_json  = read_army_ally_options(army_id)
  optioanl_dates = get_dates_for_optional_contingents(army_ally_options_json)
  dates.extend(optioanl_dates)
  return dates


# Generate the LUA for an army
# @param army_id Identifier for the army in Meshwesh
def generate_army(army_id) :
  army_json = read_army_json(army_id)
  army_theme_json = read_army_theme_json(army_id)
  army_ally_options_json  = read_army_ally_options(army_id)

  optional_contingents = get_optional_contingents(army_ally_options_json)

  base_definition_file_name = os.path.join(
    "army_data",
    army_id + "_base_definitions.ttslua")
  file_name = os.path.join("army_data", army_id + ".ttslua")
  with open(base_definition_file_name, "a") as base_definitions_file :
    with open(file_name, "a") as file :

      army_name =  army_json['derivedData']['extendedName']
      army_name = make_safe_string(army_name)
      file.write("-- %s %s\n\n" % (army_id, army_name))
      definitions = generate_base_definitions(
        base_definitions_file, army_json)
      for ally_army in  optional_contingents :
        troop_options = ally_army['troopOptions']
        for troop_option in  troop_options :
          defs = base_definitions(
            base_definitions_file, army_json, troop_option)
          definitions.extend(defs)

      file.write("army['%s']={\n" % (army_id))
      file.write("  data={\n")

      file.write("    invasionRatings={\n")
      invasionRatings = army_json['invasionRatings']
      for invasionRating in invasionRatings :
          value = invasionRating['value']
          file.write("      %d,\n" % (value))
      file.write("    },\n")

      file.write("    maneuverRatings={\n")
      maneuverRatings = army_json['maneuverRatings']
      for maneuverRating in maneuverRatings :
          value = maneuverRating['value']
          file.write("      %d,\n" % (value))
      file.write("    },\n")

      file.write("    homeTopographies={\n")
      homeTopographies = army_json['homeTopographies']
      for topography in homeTopographies :
        values = topography['values']
        for value in values :
          value = make_safe_string(value.strip())
          file.write("      '%s',\n" % (value))
      file.write("    },\n")


      #escape quotes
      army_name = make_safe_string(army_name)
      name = army_name.replace("'", "\\'").strip()

      file.write("    name='%s',\n" %(name))
      file.write("    id='%s',\n" %(army_id))
      file.write("    dateRange={\n")
      file.write("      startDate=%d,\n" %
        (army_json['dateRange']['startDate']))
      file.write("      endDate=%d,\n"  % (army_json['dateRange']['endDate']))
      file.write("    },\n")

      if 'battleCardEntries' in army_json :
          for battle_card in army_json['battleCardEntries'] :
              if battle_card['battleCardCode'] == "AM" :
                  file.write("    ambush=true,")
              elif battle_card['battleCardCode'] == "NC" :
                  file.write("    no_camp=true,")
      file.write("  },\n")

      # Bases that make up the army
      for definition in definitions  :
        id = definition['id']
        file.write("  g_base_definitions[g_str_%s],\n" %(id))
      file.write("}\n")

      # Meshwesh is in front so it will be the first entry in the
      # dialog otherwise it will be the second which just looks weird.
      file.write('if nil == armies[\"Meshwesh id\"] then\n')
      file.write('  armies[\"Meshwesh id\"] ={}\n')
      file.write('end\n')
      file.write('armies[\"Meshwesh id\"][\"%s\"] = army[\"%s\"]\n' %
        (army_id, army_id))


      # Look for date ranges
      dates = get_dates_for_army_no_allies(army_json)
      army_date_ranges = army_json['dateRanges']
      army_date_range = army_date_ranges[0]
      army_startDate = int(army_date_range['startDate'])
      army_endDate = int(army_date_range['endDate'])

      # Add the dates for the Triumph! allies
      ally_dates = get_dates_for_triumph_allies(army_ally_options_json)
      for d in ally_dates :
        if between(army_startDate, d, army_endDate) :
            dates.append(d)

      # Add the dates for the Grand Triumph! allies.
      ally_dates = get_dates_for_grand_triumph_allies(army_ally_options_json)
      for d in ally_dates :
        if between(army_startDate, d, army_endDate) :
            dates.append(d)

      dates = sorted(set(dates))

      # dates are kept in order, but there is one extra entry
      # at the beginning that keeps the entire range.
      date_map = []
      date_map.append( (
        date_string(army_startDate, army_endDate),
        [army_startDate, army_endDate]) )

      start = dates[0]
      for end in dates[1:] :
        if start != army_startDate or end != (army_endDate+1) :
          date_map.append( (
            date_string(start, end-1),
            [start, end-1] ))
          start = end

      for army_theme in army_theme_json :
        theme_name = make_safe_string(army_theme["name"])

        file.write('if nil == armies[\"%s\"] then\n' %
          (theme_name))
        file.write('  armies[\"%s\"] ={}\n' %
          (theme_name))
        file.write('end\n')
        file.write('armies[\"%s\"][\"%s\"] = army[\"%s\"]\n' %
          (theme_name, name, army_id))

      file.write('if nil == armies[\"All\"] then\n')
      file.write('  armies[\"All\"] ={}\n')
      file.write('end\n')
      file.write('armies[\"All\"][\"%s\"] = army[\"%s\"]\n' %
          (name, army_id))

      file.write("if nil == army_dates then\n  army_dates={}\nend\n")
      file.write("army_dates[\"%s\"] = {}\n" % (army_id))
      for date_entry in date_map:
        (years, dateRange) = date_entry
        (startDate, endDate) = dateRange
        file.write("army_dates[\"%s\"][\"%s\"] = {\n" %  (army_id, years))
        file.write("  startDate=%d,\n" %  (startDate))
        file.write("  endDate=%d\n" %  (endDate))
        file.write("}\n")


def generate_ally_base_definitions(army_id) :
  """Generate any base definitions for an armies allies that have
     not yet been generated.
  """
  file_name = os.path.join("army_data", army_id + "_base_definitions.ttslua")
  with open(file_name, "a") as file :
    army_ally_options_json  = read_army_ally_options(army_id)
    for ally in army_ally_options_json :
      if 'allyEntries' not in ally :
        return
      for ally_entry in ally['allyEntries'] :
        allyArmyList = ally_entry['allyArmyList']
        troopOptions =allyArmyList['troopOptions']
        for troop_option in troopOptions :
          for troop_entry in troop_option['troopEntries'] :
            base_definition = create_base_definition(troop_option, troop_entry)
            write_base_definition(file, base_definition)

def get_date_range(obj) :
  """Always return a date range."""
  if "dateRange" not in obj :
    return { 'startDate':-50000, 'endDate':50000 }
  if obj['dateRange']  is None :
    return { 'startDate':-50000, 'endDate':50000 }
  return obj['dateRange']

def generate_allies(army_id) :
  """Generaate the list of allies for an army.
     @param army_id: Identifier of the army to examine.
  """
  allies_file_name = os.path.join("army_data", army_id + "_allies.ttslua")
  with open(allies_file_name, "w") as file :
    file.write("""
-- GENERATED FILE DO NOT EDIT
-- See tts_army.py

require("Triumph_TTS/scripts/static_maps")

""")
    army_ally_options_json  = read_army_ally_options(army_id)
    file.write("allies['%s'] = {\n" % (army_id))
    for allies_for_date in army_ally_options_json :
      dateRange = get_date_range(allies_for_date)
      allyEntries = allies_for_date['allyEntries']
      for ally_entry in allyEntries:
        allyArmyList = ally_entry['allyArmyList']
        if 'armyListId' in allyArmyList :
          ally_armyListId = allyArmyList['armyListId']
          file.write("  {\n    id='%s',\n    dateRange={startDate=%d, endDate=%d}\n  },\n" %
            (ally_armyListId, dateRange['startDate'], dateRange['endDate']))
    file.write("}\n")

    # Write out a fake army for use in Triumph!
    for allies_for_date in army_ally_options_json :
      dateRange = get_date_range(allies_for_date)
      allyEntries = allies_for_date['allyEntries']
      for ally_entry in allyEntries:
        allyArmyList = ally_entry['allyArmyList']
        if 'armyListId' in allyArmyList :
          ally_armyListId = allyArmyList['armyListId']
          id = army_id + "_ally_" + ally_armyListId
          ally_name =  ally_entry['name']
          name = ally_name.replace("'", "\\'")
          file.write("army['%s'] = {\n" % (id))
          file.write("  data={\n")
          file.write("    name='%s',\n" %(name))
          file.write("    id='%s',\n" % (id))
          file.write("  },\n")
          troopOptions =allyArmyList['troopOptions']
          for troop_option in troopOptions :
            for troop_entry in troop_option['troopEntries'] :
              base_definition = create_base_definition(troop_option, troop_entry)
              file.write("  g_base_definitions['%s'],\n" % (base_definition['id']) )
          file.write("}\n")


def write_troop_option(file, troop_option) :
  file.write("troop_options['%s'] = {\n" % (troop_option['_id']))
  file.write("  min=%d,\n" % (troop_option['min']))
  file.write("  max=%d,\n" % (troop_option['max']))
  dateRange = troop_option['dateRange']
  if (dateRange is  None) :
    print(troop_option)
  assert(dateRange is not None)
  file.write("  dateRange={\n")
  file.write("    startDate=%d,\n" % (troop_option['dateRange']['startDate']))
  file.write("    endDate=%d,\n"  % (troop_option['dateRange']['endDate']))
  file.write("  }\n")
  file.write("}\n")

def write_troop_options(army_id) :
  """Write the troop options data so they can be accessed in LUA."""
  file_name = os.path.join("army_data", army_id + "_troop_options.ttslua")
  with open(file_name, "w") as file :
    file.write("""
-- GENERATED FILE DO NOT EDIT
-- See tts_army.py

require("Triumph_TTS/scripts/static_maps")

""")
    army_json = read_army_json(army_id)
    troop_options = army_json['troopOptions']
    for troop_option in  troop_options :
      write_troop_option(file, troop_option)
    file.write("-- allies\n")
    army_ally_options_json  = read_army_ally_options(army_id)
    if 'allyEntries' in army_ally_options_json :
      for ally_entry in army_ally_options_json['allyEntries'] :
        allyArmyList = ally_entry['allyArmyList']
        troopOptions =allyArmyList['troopOptions']
        for troop_option in troopOptions :
          write_troop_option(file, troop_option)


summary = read_json("armyLists/summary.json")

with open("army_data/all_armies.ttslua", "w") as all_armies:
    all_armies.write("""
-- GENERATED FILE DO NOT EDIT
-- See tts_army.py

require("Triumph_TTS/scripts/static_maps")

""")

    for army_entry in summary :
        army_id = army_entry['id']
        write_troop_options(army_id)

    for army_entry in summary :
        army_id = army_entry['id']
        print(army_id)
        try :
            generate_army(army_id)
        except:
            print(army_entry['name'])
            raise

    for army_entry in summary :
        army_id = army_entry['id']
        generate_ally_base_definitions(army_id)

    for army_entry in summary :
        army_id = army_entry['id']

    for army_entry in summary :
        army_id = army_entry['id']
        generate_allies(army_id)

    for army_entry in summary :
        army_id = army_entry['id']
        all_armies.write('require("Triumph_TTS/fake_meshwesh/army_data/%s_troop_options")\n' % (army_id))
    for army_entry in summary :
        army_id = army_entry['id']
        all_armies.write( 'require("Triumph_TTS/fake_meshwesh/army_data/%s_base_definitions")\n' % (army_id))
    for army_entry in summary :
        army_id = army_entry['id']
        all_armies.write( 'require("Triumph_TTS/fake_meshwesh/army_data/%s")\n' % (army_id))
    for army_entry in summary :
        army_id = army_entry['id']
        all_armies.write( 'require("Triumph_TTS/fake_meshwesh/army_data/%s_allies")\n' % (army_id))
