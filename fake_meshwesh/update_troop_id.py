#!/usr/bin/env python3

"""
Update the mapping for models to base id's when meshwesh has changed.

BEWARE: git operations called that will remove all uncommitted changes.
"""
import json
import os
import shutil
import sqlite3
import subprocess


def is_army(file_name):
    if file_name.endswith(".json") :
        return False
    if file_name.endswith("_thematicCategories") :
        return False
    if file_name.endswith("summary") :
        return False
    return True

def import_files(army_data_dir, data_version):    
    files = os.listdir(army_data_dir)
    for file in files:
        if is_army(file) :
            file_path = os.path.join(army_data_dir, file)
            with open(file_path, "r") as json_file:
                s = json_file.readline()
                j = json.loads(s)
                army_id = file
                troop_options = j["troopOptions"]
                for troop_option in troop_options:
                    troop_option_id = troop_option["_id"]
                    troop_option_description = troop_option['description']
                    troop_entries = troop_option["troopEntries"]
                    for troop_entry in troop_entries:
                        troop_entry_id = troop_entry["_id"]
                        troop_entry_type_code = troop_entry["troopTypeCode"]
                        con.execute("INSERT INTO troops (army_id, troop_option_id, troop_option_description, troop_entry_id, troop_entry_type_code, data_version) VALUES (?,?,?,?,?,?)",
                            (army_id, troop_option_id, troop_option_description, troop_entry_id, troop_entry_type_code, data_version))



subprocess.run(['git', 'reset', '--hard'], check=True)
subprocess.run(['git', 'clean', '-fdx'], check=True)
subprocess.run(['git', 'clean', '-fdX'], check=True)
shutil.move("armyLists", "armyLists.old")
subprocess.run(["make", "clone"], check=True)
subprocess.run(["make", "army_data"], check=True)

if os.path.exists("troops.db"):
    os.unlink("troops.db")
con = sqlite3.connect("troops.db")
con.execute("""create table troops (
    army_id TEXT,
    troop_option_id TEXT,
    troop_option_description TEXT,
    troop_entry_id TEXT,
    troop_entry_type_code TEXT,
    data_version TEXT
    );""")

import_files(os.path.realpath("armyLists.old"), "old")
import_files(os.path.realpath("armyLists"), "new")
sed = os.path.realpath("changes.sed")
changes = open(sed, "w")

cur = con.cursor()
cur.execute("""
    SELECT A.troop_entry_id, B.troop_entry_id 
    FROM troops A, troops B 
    WHERE 
        A.data_version == 'old' AND 
        B.data_version == 'new' AND 
        A.army_id == B.army_id AND 
        A.troop_option_description == B.troop_option_description AND 
        A.troop_entry_type_code == B.troop_entry_type_code""")
while (rec := cur.fetchone()) :
    (old,new) = rec
    line = f"s/{old}/{new}/g\n"
    changes.write(line)
changes.close()

os.chdir("../scripts/data")
files = os.listdir(".")
for file in files:
    subprocess.run([ 'sed', '-i', '-f', sed, file ], check=True)
