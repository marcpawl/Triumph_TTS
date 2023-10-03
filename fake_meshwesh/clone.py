import json
import os
import sys
import subprocess
import time

#https://meshwesh.wgcwar.com/api/v1/


def retrieve_allyOptions(id) :
    dest_file = "armyLists/" + id + ".allyOptions.json"
    src_url = "https://meshwesh.wgcwar.com/api/v1/armyLists/" + id + "/allyOptions"
    cmd = [ "curl", "-o", dest_file, src_url]
    subprocess.check_call(cmd)

def retrieve_army(id) :
    dest_file = "armyLists/" + id + ".army.json"
    src_url = "https://meshwesh.wgcwar.com/api/v1/armyLists/" + id
    cmd = [ "curl", "-o", dest_file, src_url]
    subprocess.check_call(cmd)

#   https://meshwesh.wgcwar.com/api/v1/armyLists/{army-list-id}/thematicCategories
def retrieve_theme(id) :
    dest_file = "armyLists/" + id  + ".thematicCategories.json"
    src_url = "https://meshwesh.wgcwar.com/api/v1/armyLists/" + id + "/thematicCategories"
    cmd = [ "curl", "-o", dest_file, src_url]
    subprocess.check_call(cmd)

#   https://meshwesh.wgcwar.com/api/v1/armyLists/{army-list-id}/enemyArmy
def retrieve_enemies(id) :
    dest_file = "armyLists/" + id  + ".enemyArmy.json"
    src_url = "https://meshwesh.wgcwar.com/api/v1/armyLists/" + id + "/enemyArmyLists"
    cmd = [ "curl", "-o", dest_file, src_url]
    subprocess.check_call(cmd)


def create_timestamp():
    """Write the time the data was retrieved."""
    with open("armyLists/timestamp.json", "w") as timestamp_file:
        timestamp_file.write("%d\n" % (int(time.time())))


if __name__ == "__main__":
    create_timestamp()
    with open("armyLists/summary.json", "r") as summary_file:
      summary_text = summary_file.read()
    summary = json.loads(summary_text)
    for army_entry in summary :
        print(army_entry['id'])
        retrieve_army(army_entry['id'])
        retrieve_allyOptions(army_entry['id'])
        retrieve_theme(army_entry['id'])
        retrieve_enemies(army_entry['id'])
