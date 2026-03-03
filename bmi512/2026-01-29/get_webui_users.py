"""
Get All Open WebUI Users
python get_webui_users.py /app/backend/data/webui.db
python get_webui_users.py /data/docker/volumes/open-webui/_data/webui.db
"""
import os
import sqlite3
import sys


def get_all_users(db_path):
    if not os.path.exists(db_path):
        print(f"Database file not found: {db_path}")
        return

    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    # Try fetching from common user-related tables
    try:
        cursor.execute("SELECT id, name, email FROM user ORDER BY email")
    except sqlite3.OperationalError as e:
        print("Failed to query 'users' table. Possible reasons:")
        print("- Table doesn't exist.")
        print("- Schema is different.")
        print("Error:", e)
        conn.close()
        return

    users = cursor.fetchall()
    print(f"\nFound {len(users)} users:\n")
    for user in users:
        print(f"ID: {user[0]}\nName: {user[1]}\nEmail: {user[2]}\n{'-' * 30}")

    conn.close()


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python get_webui_users.py <path_to_sqlite_db>")
    else:
        get_all_users(sys.argv[1])
