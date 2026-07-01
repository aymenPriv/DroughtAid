import os
from decimal import Decimal
from datetime import date, datetime

import oracledb
from dotenv import load_dotenv

load_dotenv()

ORACLE_USER = os.getenv("ORACLE_USER")
ORACLE_PASSWORD = os.getenv("ORACLE_PASSWORD")
ORACLE_DSN = os.getenv("ORACLE_DSN")


def get_connection():
    if not ORACLE_USER or not ORACLE_PASSWORD or not ORACLE_DSN:
        raise RuntimeError("Missing Oracle database environment variables.")

    return oracledb.connect(
        user=ORACLE_USER,
        password=ORACLE_PASSWORD,
        dsn=ORACLE_DSN
    )


def clean_value(value):
    if isinstance(value, Decimal):
        if value == value.to_integral_value():
            return int(value)
        return float(value)

    if isinstance(value, (datetime, date)):
        return value.isoformat()

    return value


def rows_to_dicts(cursor):
    columns = [col[0].lower() for col in cursor.description]
    rows = cursor.fetchall()

    result = []
    for row in rows:
        result.append({
            columns[i]: clean_value(row[i])
            for i in range(len(columns))
        })

    return result


def row_to_dict(cursor):
    columns = [col[0].lower() for col in cursor.description]
    row = cursor.fetchone()

    if row is None:
        return None

    return {
        columns[i]: clean_value(row[i])
        for i in range(len(columns))
    }