import json
import pathlib
import sys
from typing import List


ARMYLISTS_DIRECTORY = pathlib.Path("../../fake_meshwesh/armyLists")

def make_safe_string(udata) :
    """Remove special characters."""
    if udata is None:
      return None
    asciidata:str = udata.encode("ascii", "ignore").decode("ascii")
    asciidata = asciidata.replace('"', "")
    return asciidata

def quote(x: str) -> str:
    return '"' + x + '"'


def writeStringList(aList: List[str], elm, indent: int):
    safe_strings = map(make_safe_string, aList)
    quoted = list(map(quote, safe_strings))
    writeList(quoted, elm, indent)


def writeList(aList: List, elm, indent: int):
    indent_str = " " * indent 
    elm.write(indent_str + '[\n')
    if len(aList) > 0:
      elm.write(indent_str)
      elm.write("  ")
      elm.write(('\n' + indent_str + ', ').join(aList))
      elm.write('\n')
    elm.write(indent_str + ']')

def toNote(container) -> str:
  return toMaybe(container, 'note')


def toMaybe(container, field) -> str:
  if field not in container:
      return "Nothing"
  value = container[field] 
  if value is None:
      return "Nothing"
  if (type(value) == str):
    if value == "":
      return "Nothing"
    else:
      safe = make_safe_string(value)
      return "(Just " + quote(safe) + ")"
  return "(Just " + str(value) + ")"


def toRating(rating) -> str:
  result =  "InvasionRating " 
  result = result + quote(rating['_id'])
  result = result + ' ' + str(rating['value'])
  result = result + " "+ toNote(rating)
  return result


def writeRatings(elm, type: str, army_id: str, ratings):
  ratings_string: List[str] = list(map(toRating, ratings))
  variable = type[0].lower() + type[1:] + "s" + "_" + army_id
  elm.write(variable)
  elm.write(": List " + type + "\n")
  elm.write(variable)
  elm.write(" =\n")
  writeList(ratings_string, elm, 8)
  elm.write("\n\n")


def writeInvasionRatings(elm, army_id, invasion_ratings):
  writeRatings(elm, "InvasionRating", army_id, invasion_ratings)


def writeManeuverRatings(elm, army_id, ratings):
  writeRatings(elm, "ManeuverRating", army_id, ratings)


def toTopography(homeTopography) -> str:
   result = "HomeTopographies " + quote(homeTopography['_id']) + " ["
   result = result + ", ".join(homeTopography['values'])
   result = result + "] " + toNote(homeTopography)
   return result


def writeHomeTopographies(elm, army_id, homeTopographiesList: List):
  homeTopographies_string: List[str] = list(map(toTopography, homeTopographiesList))
  variable = "homeTopographies_" + army_id
  elm.write(variable)
  elm.write(": List HomeTopographies\n")
  elm.write(variable)
  elm.write(" =\n")
  writeList(homeTopographies_string, elm, 8)
  elm.write("\n\n")
   

def writeTroopEntry(elm, troop_entry) -> str:
   note = toNote(troop_entry)
   id = troop_entry['_id']
   variable = "troopEntry_" + id
   elm.write(f"{variable}: TroopEntry\n")
   elm.write(f"{variable} = TroopEntry {quote(id)} ")
   elm.write(troop_entry['troopTypeCode'])
   elm.write(" ")
   elm.write(toMaybe(troop_entry, "dismountTypeCode"))
   elm.write(" ")
   elm.write(note)
   elm.write("\n\n")
   return variable


def writeTroopEntries(elm, troop_entries: dict):
  def write_entry(troop_entry) -> str:
    return writeTroopEntry(elm, troop_entry)
  
  id = troop_entries['_id']
  variable = "troopEntries_" + id
  entries = troop_entries['troopEntries']
  entries_variables = list(map(write_entry, entries))
  variable = "troopEntries_" + id
  elm.write(f"{variable}: List TroopEntry\n")
  elm.write(f"{variable} =\n")
  writeList(entries_variables, elm, 2)
  elm.write("\n\n")
  return variable


def writeTroopEntriesForGeneral(elm, army_id, general_troop_entries) -> str:
  def write_entries(troop_entries) -> str:
    return writeTroopEntries(elm, troop_entries)
  
  troop_entries = list(map(write_entries, general_troop_entries))
  variable = "troopEntriesForGeneral_" + army_id
  elm.write(f"{variable} =\n")
  writeList(troop_entries, elm, 2)
  elm.write("\n\n")
  return variable

def write_battle_card(elm, entry) -> str:
   note = toNote(entry)
   id = entry['_id']
   min = toMaybe(entry, 'min')
   max = toMaybe(entry, 'max')
   battleCardCode = entry['battleCardCode']
   variable = "battleCard_" + id
   elm.write(f"{variable}: BattleCardEntry\n")
   elm.write(f"{variable} = BattleCardEntry ")
   elm.write(f"{min} {max} {battleCardCode} {note}\n\n")
   return variable

def writeBattleCardEntries(elm, id: str, entries) -> str:
  def write_entry(battleCard) -> str:
    return write_battle_card(elm, battleCard)
  
  battlecard_entries = list(map(write_entry, entries))
  variable = "battleCards_" + id
  elm.write(f"{variable} =\n")
  writeList(battlecard_entries, elm, 2)
  elm.write("\n\n")
  return variable


def writeArmy(elm, army):
      army_id = army['id']
      extendedName = army['derivedData']['extendedName']
      try:
        invasion_ratings = army['invasionRatings']
        writeInvasionRatings(elm, army_id, invasion_ratings)

        maneuver_ratings = army['maneuverRatings']
        writeManeuverRatings(elm, army_id, maneuver_ratings)

        writeHomeTopographies(elm, army_id, army['homeTopographies'])
        troopEntriesForGeneral = \
          writeTroopEntriesForGeneral(elm, army_id, army['troopEntriesForGeneral'])
        battleCardEntries = \
          writeBattleCardEntries(elm, army_id, army['battleCardEntries'])

        elm.write(f"army_{army_id}: Army\n")
        elm.write(f"army_{army_id} =\n")
        elm.write("  {\n")
        elm.write(f"""    id = "{army_id}"\n""")

        elm.write("    , keywords =\n")
        writeStringList(army['keywords'], elm, 8)
        elm.write("\n")

        elm.write(f"    , listStartDate = {army['derivedData']['listStartDate']}\n")
        elm.write(f"    , listEndDate = {army['derivedData']['listEndDate']}\n")
        elm.write(f"""    , extendedName = "{extendedName}"\n""")
        elm.write(f"    , sortId = {army['sortId']}\n")
        elm.write(f"""    , sublistId = "{army['sublistId']}"\n""")
        elm.write(f"""    , name = "{army['name']}"\n""")
        elm.write(f"""    , invasionRatings = invasionRatings_{army_id}\n""")
        elm.write(f"""    , maneuverRatings = maneuverRatings_{army_id}\n""")
        elm.write(f"""    , homeTopographies = homeTopographies_{army_id}\n""")
        elm.write(f"""    , troopEntriesForGeneral = {troopEntriesForGeneral}\n""")
        elm.write(f"""    , battleCardEntries = {battleCardEntries}\n""")
        elm.write("  }\n\n")
      except Exception as exception:
        raise Exception(extendedName, exception)

def armies():
  all_armies = dict()
  for file in ARMYLISTS_DIRECTORY.glob("*.army.json"):
    army_id = pathlib.Path(file.stem).stem
    with file.open() as army:
      army_data = json.load(army)
      all_armies[army_id] = army_data
  with open("src/Armies.elm", "w") as elm:
    elm.write("""module Armies exposing (..)
--import ArmyTypes exposing(InvasionRating, ManeuverRating, Topography, HomeTopographies, Army, )
import MeshWeshTypes exposing (..)
""")
    elm.write("\n")

    def by_name(id1: str) -> str:
      return all_armies[id1]['name']
   
    sorted_id = list(all_armies.keys())
    sorted_id.sort(key=by_name)

    for army_id in sorted_id:
      army = all_armies[army_id]
      writeArmy(elm, army)

    armies_names = list(map(lambda x: "army_" + x, sorted_id))
    elm.write("all_armies = ")
    writeList(armies_names, elm, 2)


def themes():
  all_themes = dict()
  for file in ARMYLISTS_DIRECTORY.glob("*.thematicCategories.json"):
    army_id = pathlib.Path(file.stem).stem
    with file.open() as theme:
      theme_data = json.load(theme)
      for theme_description in theme_data:
        if theme_description['id'] not in all_themes:
          all_themes[theme_description['id']] = { 'name': theme_description['name'], 'armies':[]}
        all_themes[theme_description['id']]['armies'].append(army_id)

  with open("src/Themes.elm", "w") as elm:
    elm.write("""module Themes exposing (..)

import MeshWeshTypes exposing (..)
import Armies exposing (..)
              
              
""")
    elm.write("\n")

    def by_name(id1: str) -> str:
      return all_themes[id1]['name']
   
    sorted_id = list(all_themes.keys())
    sorted_id.sort(key=by_name)

    for theme_id in sorted_id:
      theme_description = all_themes[theme_id]
      elm.write(f"theme_{theme_id}: Theme\n")
      elm.write(f"theme_{theme_id} =\n")
      elm.write("  {\n")
      elm.write(f"""    id = "{theme_id}"\n""")
      elm.write(f"""  , name = "{theme_description['name']}"\n""")

      elm.write("  , armies =\n")
      armies_names = map(lambda x: "Armies.army_" + x, theme_description['armies'])
      writeList(list(armies_names), elm, 8)
      elm.write("  }\n\n")

    elm.write("themes =\n")
    elm.write("  [\n")
    elm.write("    theme_")
    elm.write("\n  , theme_".join(sorted_id))
    elm.write("\n  ]\n")






armies()
themes()
