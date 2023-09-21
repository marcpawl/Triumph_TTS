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


def toRating(rating) -> str:
  result =  "InvasionRating " 
  result = result + quote(rating['_id'])
  result = result + ' ' + str(rating['value'])
  result = result + " "
  if 'note' in rating and rating['note'] is not None:
    result = result + "(Just " + quote(rating['note']) + ")"
  else:
      result = result + 'Nothing' 
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


def writeArmy(elm, army):
      army_id = army['id']

      invasion_ratings = army['invasionRatings']
      writeInvasionRatings(elm, army_id, invasion_ratings)

      maneuver_ratings = army['maneuverRatings']
      writeManeuverRatings(elm, army_id, maneuver_ratings)

      elm.write(f"army_{army_id}: Army\n")
      elm.write(f"army_{army_id} =\n")
      elm.write("  {\n")
      elm.write(f"""    id = "{army_id}"\n""")

      elm.write("    , keywords =\n")
      writeStringList(army['keywords'], elm, 8)
      elm.write("\n")

      elm.write(f"    , listStartDate = {army['derivedData']['listStartDate']}\n")
      elm.write(f"    , listEndDate = {army['derivedData']['listEndDate']}\n")
      elm.write(f"""    , extendedName = "{army['derivedData']['extendedName']}"\n""")
      elm.write(f"    , sortId = {army['sortId']}\n")
      elm.write(f"""    , sublistId = "{army['sublistId']}"\n""")
      elm.write(f"""    , name = "{army['name']}"\n""")
      elm.write(f"""    , invasionRatings = invasionRatings_{army_id}\n""")
      elm.write(f"""    , maneuverRatings = maneuverRatings_{army_id}\n""")
      elm.write("  }\n\n")


def armies():
  all_armies = dict()
  for file in ARMYLISTS_DIRECTORY.glob("*.army.json"):
    army_id = pathlib.Path(file.stem).stem
    with file.open() as army:
      army_data = json.load(army)
      all_armies[army_id] = army_data
  with open("src/Armies.elm", "w") as elm:
    elm.write("module Armies exposing (..)\n")
    elm.write("""
              
type alias InvasionRating =
  {
    id: String
  , value: Int
  , note: Maybe String
  }
              
type alias ManeuverRating =
  {
    id: String
  , value: Int
  , note: Maybe String
  }
              
type alias Army =
  { 
    id : String
  , keywords: List String
  , listStartDate: Int
  , listEndDate: Int
  , extendedName: String
  , sortId: Float
  , sublistId: String
  , name: String   
  , invasionRatings: List InvasionRating
  , maneuverRatings: List ManeuverRating       
  }
              
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

import Armies exposing (..)
              
type alias Theme =
  { id : String
  , name : String
  , armies: List Armies.Army
  }
              
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
      armies_names = map(lambda x: "army_" + x, theme_description['armies'])
      writeList(list(armies_names), elm, 8)
      elm.write("  }\n\n")

    elm.write("themes =\n")
    elm.write("  [\n")
    elm.write("    theme_")
    elm.write("\n  , theme_".join(sorted_id))
    elm.write("\n  ]\n")






armies()
themes()
