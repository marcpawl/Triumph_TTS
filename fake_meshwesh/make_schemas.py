
import json
import os
from pathlib import Path
import re
import subprocess
from typing import List

import genson.cli


def _get_json_strings(self, raw_text, delimiter=None):
    if delimiter is None or self.args.delimiter == '':
        json_strings = self._detect_json_strings(raw_text)
    else:
        json_strings = raw_text.split(self.args.delimiter)

    # sanitize data before returning
    return [string.strip() for string in json_strings if string.strip()]

def _call_with_json_from_fp(method, fp):
    for json_string in _get_json_strings(fp.read().strip()):
        method(json.loads(json_string))

def extractSchema(type: str):
    builder = genson.SchemaBuilder(schema_uri="http://json-schema.org/draft-07/schema#")
    builder.add_schema(
        {
            "title": type,
            "description": f"Meshwesh {type}"
        })
    p = Path("armyLists")
    files = p.glob(f"*{type}.json")
    for file in files:
        source = file.absolute()
        with open(os.fspath(source), "r") as input:
            json_obj = json.load(input)
            builder.add_object(json_obj)
    destination = Path("json_schemas").absolute() / f"{type}.schema.json"
    with open(os.fspath(destination), "w") as output:
        output.write( builder.to_json(indent=2))


extractSchema("summary")
extractSchema("army")
extractSchema("thematicCategories")
extractSchema("allyOptions")
