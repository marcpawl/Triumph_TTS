import json
import os
import pathlib
import re
import sys

re_safe_string = "[^-:/a-zA-Z0-9 (),]"

def make_safe_string(udata) :
    """Remove special characters."""
    asciiData=udata.encode("ascii", "ignore").decode("ascii")
    # Remove escaped quotes from strings
    quoteFree = asciiData.replace('\\"', '')
    return quoteFree


variableName = sys.argv[1] 
moduleName = (variableName[0].upper()) + variableName[1:]
fileName = "src/" + moduleName + ".elm"
with open(fileName, "w") as output:
    directory = pathlib.Path("../../fake_meshwesh/armyLists")
    output.write(f"module {moduleName} exposing(..)\n\n")

    output.write(variableName)
    output.write(' = """')
    # output.write("[\n")
    files = list(directory.glob(f"*{sys.argv[1]}.json"))
    for file in files:
        with open(os.fspath(file), "r") as input:
          contents = input.read()
          safe = make_safe_string(contents)
          jsonContents = json.loads(safe)
          json.dump(jsonContents, output, indent=2)
        if file == files[-1]:
          output.write("\n")
        else:
          output.write(",\n")
    # output.write("]\n")
    output.write('"""')
