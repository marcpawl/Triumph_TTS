#!/usr/bin/env python3
 
import argparse
import clone
import json
from pathlib import Path
import shutil
import subprocess
import sys
import sqlite3

import tts_army


def create_armies_table( conn):
    """
    """
    # Create the armies table with indexed columns
    cursor = conn.cursor()
    cursor.execute('''
        CREATE TABLE armies (
            name TEXT,
            old_army_id TEXT,
            new_army_id TEXT,
            PRIMARY KEY (name)
        )
        ''')
        
    # Create indexes for the columns
    cursor.execute('CREATE INDEX idx_name ON armies (name)')
    cursor.execute('CREATE INDEX idx_old_army_id ON armies (old_army_id)')
    cursor.execute('CREATE INDEX idx_new_army_id ON armies (new_army_id)')
    
    # Create the view for the mapped army id
    cursor.execute(
        """
            CREATE VIEW armies_mapping AS
            SELECT old_army_id, new_army_id
            FROM armies
            WHERE 
                old_army_id IS NOT NULL AND 
                new_army_id IS NOT NULL AND
                old_army_id != new_army_id
        """);
        
    conn.commit()  # Commit the changes to the database
    cursor.close()  # Close the cursor
    
    
def update_old_army(cursor, name, old_army_id):
    """
    Insert a new row into the armies table with the given name and old_army_id.
    new_army_id is left as NULL.
    
    Args:
        cursor: An sqlite3 cursor object.
        name (str): The army name (primary key).
        old_army_id (str): The old army identifier.
    """        
    cursor.execute(
        """
        INSERT INTO armies (name, old_army_id, new_army_id)
        VALUES (?, ?, NULL)
        """,
        (name, old_army_id),
    )
    
    
def update_new_army(cursor, name, new_army_id):
    """
    Upsert a row into the armies table.

    If a row with the given `name` already exists, update its `new_army_id`
    column. Otherwise, insert a new row with `old_army_id` left as NULL.

    Args:
        cursor: An sqlite3 cursor object.
        name (str): The army name (primary key).
        new_army_id (str): The new army identifier.
    """
    cursor.execute(
        """
        SELECT count(old_army_id) 
        FROM armies 
        WHERE name = ?
        """, 
        (name,)
    )
    count = cursor.fetchone()[0]
    if count == 0:
        # Insert a new row with old_army_id as NULL
        cursor.execute(
            """
            INSERT INTO armies (name, new_army_id, old_army_id)
            VALUES (?, ?, NULL)
            """,
            (name, new_army_id),
        )
    else:
        cursor.execute(
            """
            UPDATE armies
            SET new_army_id = ?
            WHERE name = ?
            """,
            (new_army_id, name),
        )
        assert cursor.rowcount == 1, f"Expected to update 1 row for name '{name}', but updated {cursor.rowcount} rows."
    
def load_army_summary(conn, summary_file_path, update_function):
    """
    Load army summary data from a JSON file and update the database using the provided function.

    Args:
        conn: Open connection to the SQLite database.
        summary_file_path (str): Path to the JSON file containing army summary data.
        update_function (function): Function to update the database (either update_old_army or update_new_army).
    """
    cursor = conn.cursor()
    
    with open(summary_file_path, "r") as summary_file:
        summary_text = summary_file.read()
        summary = json.loads(summary_text)
        for army_entry in summary:
            name = army_entry['name']
            army_id = army_entry['id']
            update_function(cursor, name, army_id) 
            
    conn.commit()  # Commit the changes to the database
    cursor.close()  # Close the cursor
            
def load_troops(cursor, army_data_dir: Path, data_version):    
    if data_version == "old":
        army_id_column = "old_army_id"
    else:
        army_id_column = "new_army_id"
    cursor.execute(f"""
        SELECT {army_id_column} 
        FROM armies
        WHERE {army_id_column} IS NOT NULL
        ;
        """)
    army_id_records = cursor.fetchall()
    
    for army_id_record in army_id_records:
        army_id = army_id_record[0]
        file_path = army_data_dir / army_id
        if not file_path.exists():
            raise FileNotFoundError(f"Army data file not found: {file_path}")   
        
        print(f"Loading troops for army_id: {army_id} from {file_path}")
        with open(file_path, "r") as json_file:
            j = json.load(json_file)
            troop_options = j["troopOptions"]
            for troop_option in troop_options:
                troop_option_id = troop_option["_id"]
                troop_option_description = troop_option['description']
                troop_entries = troop_option["troopEntries"]
                for troop_entry in troop_entries:
                    troop_entry_id = troop_entry["_id"]
                    troop_entry_type_code = troop_entry["troopTypeCode"]
                    cursor.execute("INSERT INTO troops (army_id, troop_option_id, troop_option_description, troop_entry_id, troop_entry_type_code, data_version) VALUES (?,?,?,?,?,?)",
                            (army_id, troop_option_id, troop_option_description, troop_entry_id, troop_entry_type_code, data_version))
            

def create_troops_view(cursor, view_name, data_version):
    cursor.execute(
            f"""
            CREATE VIEW {view_name} AS
                SELECT
                    army_id,
                    troop_option_id,
                    troop_option_description,
                    troop_entry_id,
                    troop_entry_type_code
                FROM troops
                WHERE data_version = '{data_version}';
            """)
                
def create_troops_table(cursor):        
    cursor.execute(
        """
        create table troops (
            army_id TEXT,
            troop_option_id TEXT,
            troop_option_description TEXT,
            troop_entry_id TEXT,
            troop_entry_type_code TEXT,
            data_version TEXT
        );
        """)

    create_troops_view(cursor, "old_troops", "old")
    create_troops_view(cursor, "new_troops", "new")

    cursor.execute(
            f"""
            CREATE VIEW old_troops_army_mapped AS
                SELECT
                    armies.new_army_id as new_army_id,
                    troop_option_id,
                    troop_option_description,
                    troop_entry_id,
                    troop_entry_type_code
                FROM troops, armies
                WHERE 
                    data_version = 'old' AND
                    armies.old_army_id = troops.army_id
            ;
            """)
    
    cursor.execute(
        """
        CREATE VIEW troops_mapping AS
            SELECT 
                old_troops.troop_entry_id AS old_troop_entry_id,
                new_troops.troop_entry_id AS new_troop_entry_id
            FROM old_troops_army_mapped AS old_troops, new_troops
            WHERE
                old_troops.new_army_id = new_troops.army_id AND
                old_troops.troop_option_description = new_troops.troop_option_description AND
                old_troops.troop_entry_type_code = new_troops.troop_entry_type_code
        ;
        """)

    
def create_database(db_path: Path):
    """Create a new SQLite database named update_meshwesh.db.
       If it already exists, delete it and create a new one.
       Also, add the database to .gitignore.
    """    
    # Delete the database if it exists
    if db_path.exists():
        db_path.unlink()
    
    
    # Connect to the SQLite database
    conn = sqlite3.connect(db_path)
    
    create_armies_table(conn)
    load_army_summary(conn, "armyLists.old/summary", update_old_army)
    load_army_summary(conn, "armyLists/summary", update_new_army)

    cursor = conn.cursor()
    create_troops_table(cursor)
    load_troops(cursor, Path("armyLists.old"), "old")
    load_troops(cursor, Path("armyLists"), "new")

    # Commit changes and close the connection
    conn.commit()
    cursor.close()
    conn.close()
    

def reclone():
    """Create a new version of armyLists preserving the old content in armyLists.old
    
       Reclone the armyLists directory by resetting git state, backing up, and re-importing.
    """
    # Reset any pending changes in armyLists
    subprocess.run(['git', 'reset', '--hard', 'HEAD'], check=True)
    subprocess.run(['git', 'clean', '-fdx', 'armyLists'], check=True)
    subprocess.run(['git', 'clean', '-fdX', 'armyLists'], check=True)
        
    # Copy armyLists to armyLists.old
    if Path('armyLists.old').exists():
        shutil.rmtree('armyLists.old')
    shutil.copytree('armyLists', 'armyLists.old')
    
    # Delete all files in armyLists from git
    subprocess.run(['git', 'rm', '-r', 'armyLists/*'], check=True)
    
    # Re-import from clone module
    clone.retrieve_all()
    
    # Add all files in armyLists to git
    subprocess.run(['git', 'add', 'armyLists/'], check=True)
    
    
def get_changes(db_path: Path):
    """Output the changes between:
          * old and new troop_entry_id 
          * old and new army_id
        to a sed script.
    """
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
        
    cursor.execute("""
        SELECT old_troop_entry_id, new_troop_entry_id
        FROM troops_mapping
        ;
    """)
    changes= cursor.fetchall()
            
    cursor.execute("""
        SELECT old_army_id, new_army_id
        FROM armies_mapping
        """)
    changes.extend(cursor.fetchall())
        
    cursor.close()
    conn.close()    
    
    return changes


def replace_ids_in_file(path, replacements):
    """
    Replace all occurrences of each old GUID with its new GUID in `path`.

    `replacements` is a list of (old_id, new_id) tuples.
    Returns True if the file was changed, False otherwise.
    """
    try:
        text = path.read_text(encoding="utf-8")
    except (OSError, UnicodeDecodeError) as e:
        raise e

    original = text
    for old_id, new_id in replacements:
        if old_id in text:
            text = text.replace(old_id, new_id)

    if text == original:
        return False

    tmp = path.with_suffix(path.suffix + ".tmp")
    tmp.write_text(text, encoding="utf-8")
    tmp.replace(path)
    return True


def replace_ids_in_dir(root: Path, replacements: list[tuple[str, str]]):
    """
    Apply (old_id, new_id) replacements to every file in `directory`.

    Args:
        root (Path): Directory containing the files.
        replacements (list[tuple[str, str]]): Pairs of (old_id, new_id).
    """
    if not root.is_dir():
        print(f"Error: {root} is not a directory")
        return

    files = sorted(p for p in root.iterdir() if p.is_file())
    if not files:
        print(f"No files found in {root}")
        return

    changed = 0
    for path in files:
        if replace_ids_in_file(path, replacements):
            print(f"  ✓ {path}")
            changed += 1
        else:
            print(f"  = {path} (no change)")

    print(f"\nDone: {changed} of {len(files)} files changed")
    
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Update meshwesh script.")
    parser.add_argument("--clone", action="store_true", dest="clone", default=None, help="Clone meshwesh data.")
    parser.add_argument("--no-clone", action="store_false", dest="clone", help="Do not reclone Meshwesh data.")
    parser.add_argument("--db-create", action="store_true", dest="db_create", default=None, help="Create mapping database.")
    parser.add_argument("--no-db-create", action="store_false", dest="db_create", default=True, help="Use existing mapping database.")
    parser.description = "Generate a sed script to execute against the ttslua scripts to update the mappings for units to models"
    args = parser.parse_args()
    
    if args.clone is None:
        print("ERROR: No clone option specified.")
        sys.exit(1)
    if args.db_create is None:
        print("ERROR: No database option specified.")
        sys.exit(1)


    # Initialize the variable with the default value
    if args.clone:
        reclone()
    
    db_path = Path('update_meshwesh.db')    
    
    if args.db_create:
        create_database(db_path)        
        
    changes = get_changes(db_path)

    ttslua_data = Path("../scripts/data").resolve()
    replace_ids_in_dir(ttslua_data, changes)

    unittests_path = Path("../unittests").resolve()
    replace_ids_in_dir(unittests_path, changes)
    
    tts_army.generate_army_data()
    
sys.exit(0)
