import json
import pathlib
import sys


ARMYLISTS_DIRECTORY = pathlib.Path("../../fake_meshwesh/armyLists")


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
    elm.write("module Themes exposing (..)\n")
    elm.write("""
type alias Theme =
  { id : String
  , name : String
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
      # TODO armies
      elm.write("  }\n\n")

    elm.write("themes =\n")
    elm.write("  [\n")
    elm.write("    theme_")
    elm.write("\n  , theme_".join(sorted_id))
    elm.write("\n  ]\n")





themes()
