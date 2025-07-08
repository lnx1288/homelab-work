#!/usr/bin/env python3

import sqlite3
import sys

def main(db_path, query):
    try:
        sqliteConnection = sqlite3.connect(db_path)
        cursor = sqliteConnection.cursor()
        print("Database created and Successfully Connected to SQLite")

        cursor.execute(query)

        if 'select ' in query:
            for record in cursor.fetchall():
                print(record)
        else:
            sqliteConnection.commit()
        cursor.close()

    except sqlite3.Error as error:
        print("Error while connecting to sqlite", error)
    finally:
        if sqliteConnection:
            sqliteConnection.close()
            print("The SQLite connection is closed")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("ERROR: please pass the DB path and the query you want to execute.")
        print("\nExamples:\n")
        print("   python3 this_script.py /tmp/some_db_file  \'select * from kv where key=\"charmers.openstack-release-version\";\'")
        print("   python3 this_script.py /tmp/some_db_file  \"\"\"select * from kv;\"\"\"")
        print("   python3 this_script.py /tmp/some_db_file  \"\"\"update kv set data='\\\"queens\\\"' where key='charmers.openstack-release-version';\"\"\"")

    else:
        main(sys.argv[1], sys.argv[2])
