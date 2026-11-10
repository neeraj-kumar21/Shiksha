import os
import sqlite3

path = "backend/shiksha.db"
if not os.path.exists(path):
    raise SystemExit("shiksha.db nahi mili. Pehle Uvicorn chalaiye.")

c = sqlite3.connect(path)
tables = [r[0] for r in c.execute("SELECT name FROM sqlite_master WHERE type='table'")]
if not tables:
    print("Koi table nhi bani.")
for t in tables:
    cols = [r[1] for r in c.execute(f"pragma table_info({t})")]
    print(t, "->", cols)
    
    
    
    
