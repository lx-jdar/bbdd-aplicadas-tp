import os
import pyodbc
import pandas as pd
from dotenv import load_dotenv

load_dotenv()


def _conn_str() -> str:
    server   = os.getenv("DB_SERVER", "localhost")
    database = os.getenv("DB_NAME", "GestionParquesNacionales")
    driver   = os.getenv("DB_DRIVER", "ODBC Driver 17 for SQL Server")
    user     = os.getenv("DB_USER", "")
    password = os.getenv("DB_PASSWORD", "")

    base = f"DRIVER={{{driver}}};SERVER={server};DATABASE={database};"
    if user and password:
        return base + f"UID={user};PWD={password};"
    return base + "Trusted_Connection=yes;"


def get_conn() -> pyodbc.Connection:
    return pyodbc.connect(_conn_str(), autocommit=True)


def _cursor_to_df(cursor: pyodbc.Cursor) -> pd.DataFrame:
    if cursor.description is None:
        return pd.DataFrame()
    cols = [col[0] for col in cursor.description]
    rows = cursor.fetchall()
    return pd.DataFrame.from_records([tuple(r) for r in rows], columns=cols)


def query_df(sql: str, params: tuple = ()) -> pd.DataFrame:
    conn = get_conn()
    try:
        cursor = conn.cursor()
        cursor.execute(sql, params)
        return _cursor_to_df(cursor)
    finally:
        conn.close()


def exec_sp(sp: str, *params) -> pd.DataFrame:
    """Ejecuta un stored procedure y retorna el primer result set como DataFrame."""
    conn = get_conn()
    try:
        cursor = conn.cursor()
        if params:
            placeholders = ", ".join(["?"] * len(params))
            cursor.execute(f"EXEC {sp} {placeholders}", params)
        else:
            cursor.execute(f"EXEC {sp}")
        return _cursor_to_df(cursor)
    finally:
        conn.close()
