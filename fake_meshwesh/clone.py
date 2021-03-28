import json
import os
import sys
import subprocess

#https://meshwesh.wgcwar.com/api/v1/
def retrieve_army(id) :
    dest_file = "armyLists/" + id
    src_url = "https://meshwesh.wgcwar.com/api/v1/armyLists/" + id
    cmd = [ "curl", "-o", dest_file, src_url]
    subprocess.check_call(cmd)

with open("armyLists/summary", "r") as summary_file:
  summary_text = summary_file.read()
summary = json.loads(summary_text)
for army_entry in summary :
    print(army_entry['id'])
    retrieve_army(army_entry['id'])
