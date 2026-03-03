"""
Backup + Log Pending Users + Promote (with email domain check)
python promote_users.py /app/backend/data/webui.db
python promote_users.py /data/docker/volumes/open-webui/_data/webui.db
"""
import os
import shutil
import sqlite3
import sys
from datetime import datetime


def backup_db(db_path):
    timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
    backup_path = f"{db_path}.bak.{timestamp}"
    shutil.copy2(db_path, backup_path)
    print(f"🗂️  Backup created: {backup_path}")
    return backup_path


def promote_pending_users(db_path):
    if not os.path.exists(db_path):
        print(f"❌ Database file not found: {db_path}")
        return

    backup_db(db_path)

    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    # Verify table exists
    cursor.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='user'")
    if not cursor.fetchone():
        print("❌ Table 'user' not found.")
        conn.close()
        return

    try:
        cursor.execute("SELECT name, email FROM user WHERE ROLE = 'pending'")
        pending_users = cursor.fetchall()
    except sqlite3.OperationalError as e:
        print(f"❌ Query failed: {e}")
        conn.close()
        return

    if not pending_users:
        print("ℹ️ No users with ROLE='pending' to update.")
        conn.close()
        return

    promoted = []
    skipped = []

    for name, email in pending_users:
        if email.endswith("@stonybrookmedicine.edu"):
            cursor.execute("UPDATE user SET ROLE = 'user' WHERE name = ?", (name,))
            promoted.append((name, email))
        else:
            skipped.append((name, email))

    conn.commit()
    conn.close()

    print(f"\n✅ Promoted {len(promoted)} user(s):")
    for name, email in promoted:
        print(f" - {name} ({email})")

    print(f"\n❌ Skipped {len(skipped)} user(s):")
    for name, email in skipped:
        print(f" - {name} ({email})")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python promote_users.py <path_to_db>")
    else:
        promote_pending_users(sys.argv[1])
