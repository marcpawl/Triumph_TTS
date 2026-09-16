#!/usr/bin/env python3
 
import shutil
import subprocess
from pathlib import Path

import clone
import sqlite3
import argparse

def create_armies_table( cursor):
    """
    """
    # Create the armies table with indexed columns
    cursor.execute('''
        CREATE TABLE armies (
            name TEXT,
            old_army_id TEXT,
            new_army_id TEXT,
            PRIMARY KEY (old_army_id)
        )
    ''')
    
    # Create indexes for the columns
    cursor.execute('CREATE INDEX idx_name ON armies (name)')
    cursor.execute('CREATE INDEX idx_old_army_id ON armies (old_army_id)')
    cursor.execute('CREATE INDEX idx_new_army_id ON armies (new_army_id)')
    
def create_database():
    """Create a new SQLite database named update_meshwesh.db.
       If it already exists, delete it and create a new one.
       Also, add the database to .gitignore.
    """
    db_path = Path('update_meshwesh.db')
    
    # Delete the database if it exists
    if db_path.exists():
        db_path.unlink()
    
    
    # Connect to the SQLite database
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    create_armies_table(cursor)

    # Commit changes and close the connection
    conn.commit()
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
    

    
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Update meshwesh script.")
    parser.add_argument("--clone", action="store_true", dest="clone", default=True, help="Clone meshwesh data.")
    parser.add_argument("--no-clone", action="store_false", dest="clone", help="Do not reclone Meshwesh data.")
    parser.add_argument("--db-create", action="store_true", dest="db_create", default=True, help="Create mapping database.")
    parser.add_argument("--no-db-create", action="store_false", dest="db_create", default=True, help="Use existing mapping database.")
    
    args = parser.parse_args()

    # Initialize the variable with the default value
    if args.clone:
        reclone()
    
    if args.db_create:
        create_database()
