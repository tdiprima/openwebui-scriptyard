"""
List Tables and Schemas
python inspect_sqlite.py /app/backend/data/webui.db
python inspect_sqlite.py /data/docker/volumes/open-webui/_data/webui.db
"""

import sqlite3
import sys


def inspect_db(db_path):
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    print("📋 Tables in DB:")
    cursor.execute("SELECT name FROM sqlite_master WHERE type='table';")
    tables = cursor.fetchall()
    for (table,) in tables:
        print(f"  - {table}")

    print("\n🔍 Table schemas:")
    for (table,) in tables:
        if "group" not in table:
            print(f"\n-- {table} --")
            try:
                cursor.execute(f"PRAGMA table_info({table});")
                columns = cursor.fetchall()
                for col in columns:
                    cid, name, type_, notnull, dflt_value, pk = col
                    print(f"{name} ({type_}) {'PRIMARY KEY' if pk else ''}")
            except Exception as ex:
                print(ex.message)

    conn.close()


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python inspect_sqlite.py <db_path>")
    else:
        inspect_db(sys.argv[1])

# -- user --
# id (VARCHAR(255))
# name (VARCHAR(255))
# email (VARCHAR(255))
# role (VARCHAR(255))
# profile_image_url (TEXT)
# api_key (VARCHAR(255))
# created_at (INTEGER)
# updated_at (INTEGER)
# last_active_at (INTEGER)
# settings (TEXT)
# info (TEXT)
# oauth_sub (TEXT)
