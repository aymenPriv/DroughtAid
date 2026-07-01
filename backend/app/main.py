from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.database import get_connection
from app.routes import (
    dashboard,
    regions,
    aid_items,
    drought_reports,
    aid_requests,
    allocations,
)

app = FastAPI(
    title="Drought Aid Allocation API",
    description="FastAPI backend for Oracle PL/SQL Drought Aid System",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:5174",
        "http://127.0.0.1:5174",
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(dashboard.router)
app.include_router(regions.router)
app.include_router(aid_items.router)
app.include_router(drought_reports.router)
app.include_router(aid_requests.router)
app.include_router(allocations.router)


@app.get("/")
def root():
    return {
        "message": "Drought Aid Allocation API is running"
    }


@app.get("/health/db")
def database_health_check():
    try:
        with get_connection() as connection:
            with connection.cursor() as cursor:
                cursor.execute("SELECT USER FROM dual")
                row = cursor.fetchone()

        return {
            "status": "success",
            "database_user": row[0],
        }

    except Exception as e:
        return {
            "status": "error",
            "message": str(e),
        }