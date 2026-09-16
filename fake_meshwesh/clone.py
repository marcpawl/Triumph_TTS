import json
import os
from pathlib import Path
import sys
import subprocess
import time


def retrieve_allyOptions(id) :
    dest_file = "armyLists/" + id + ".allyOptions.json"
    src_url = "https://meshwesh.wgcwar.com/api/v1/armyLists/" + id + "/allyOptions"
    cmd = [ "curl", "-o", dest_file, src_url]
    subprocess.check_call(cmd)

def retrieve_army(id) :
    dest_file = "armyLists/" + id
    src_url = "https://meshwesh.wgcwar.com/api/v1/armyLists/" + id
    cmd = [ "curl", "-o", dest_file, src_url]
    subprocess.check_call(cmd)

#   https://meshwesh.wgcwar.com/api/v1/armyLists/{army-list-id}/thematicCategories
def retrieve_theme(id) :
    dest_file = "armyLists/" + id  + "_thematicCategories"
    src_url = "https://meshwesh.wgcwar.com/api/v1/armyLists/" + id + "/thematicCategories"
    cmd = [ "curl", "-o", dest_file, src_url]
    subprocess.check_call(cmd)

def retrieve_summary() :
    dest_file = "armyLists/summary"
    src_url = "https://meshwesh.wgcwar.com/api/v1/armyLists?summary=true"
    cmd = [ "curl", "-o", dest_file, src_url]
    subprocess.check_call(cmd)

def retrieve_version():
    """ Meshwesh has no version for its data, so we will use the current time
        instead.
    """
    with open("armyLists/version", "w") as version_file:
        version = time.time()
        version_file.write(str(version))
        version_file.write("\n")
        
def format_json_file(path, indent=4, sort_keys=False, ensure_ascii=False):
    """
    Reformat a single JSON file in place.
    """
    with open(path, "r", encoding="utf-8") as f:
        data = json.load(f)

    tmp = str(path) + ".tmp"
    try:
        with open(tmp, "w", encoding="utf-8") as f:
            json.dump(data, f, indent=indent, sort_keys=sort_keys,
                      ensure_ascii=ensure_ascii)
            f.write("\n")  # trailing newline
        os.replace(tmp, path)  # atomic replace
    except OSError as e:
        print(f"  ✗ Write error: {e}")
        if os.path.exists(tmp):
            os.remove(tmp)
        raise e


def format_json_dir(directory, recursive=False, indent=4,
                    sort_keys=False, ensure_ascii=False):
    """
    Reformat all .json files in a directory.

    Args:
        directory (str | Path): The directory to scan.
        indent (int | str): Indentation passed to json.dump.
        sort_keys (bool): Alphabetically sort object keys.
        ensure_ascii (bool): Escape non-ASCII chars if True.
    """
    root = Path(directory)
    assert root.is_dir(), f"{root} is not a directory"

    files = sorted(p for p in root.glob("*") if p.is_file())
    for path in files:
        format_json_file(path, indent=indent, sort_keys=sort_keys,
                            ensure_ascii=ensure_ascii)

def retrieve_all():
    root = Path("armyLists")
    if not root.exists():
        root.mkdir(parents=True)
    retrieve_version()
    retrieve_summary()
    summary_path = root / "summary"
    with open(summary_path, "r") as summary_file:
        summary_text = summary_file.read()
        summary = json.loads(summary_text)
    for army_entry in summary :
        print(army_entry['id'])
        retrieve_army(army_entry['id'])
        retrieve_allyOptions(army_entry['id'])
        retrieve_theme(army_entry['id'])
    format_json_dir(directory=root, ensure_ascii=False)
    
        
if __name__ == "__main__":
    # Clone MeshWesh data to the local file system
    retrieve_all()
