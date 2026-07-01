import oracledb
from fastapi import APIRouter, HTTPException

from app.database import get_connection, rows_to_dicts

router = APIRouter(prefix="/api/regions", tags=["Regions"])


@router.get("")
def get_regions():
    try:
        with get_connection() as connection:
            with connection.cursor() as cursor:
                cursor.execute("""
                    SELECT
                        region_id,
                        region_name,
                        district_name,
                        population,
                        vulnerability_score,
                        report_id,
                        report_date,
                        rainfall_mm,
                        water_level_percent,
                        vegetation_index,
                        severity_level
                    FROM vw_region_drought_status
                    ORDER BY region_id
                """)

                return rows_to_dicts(cursor)

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/{region_id}/score")
def get_region_score(region_id: int):
    try:
        with get_connection() as connection:
            with connection.cursor() as cursor:
                score = cursor.callfunc(
                    "pkg_drought_aid.calculate_drought_score",
                    oracledb.DB_TYPE_NUMBER,
                    [region_id]
                )

                priority = cursor.callfunc(
                    "pkg_drought_aid.get_priority_level",
                    oracledb.DB_TYPE_VARCHAR,
                    [score]
                )

        return {
            "region_id": region_id,
            "drought_score": float(score),
            "priority_level": priority
        }

    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))