from fastapi import APIRouter, HTTPException

from app.database import get_connection, row_to_dict, rows_to_dicts

router = APIRouter(prefix="/api/dashboard", tags=["Dashboard"])


@router.get("")
def get_dashboard():
    try:
        with get_connection() as connection:
            with connection.cursor() as cursor:
                cursor.execute("SELECT * FROM vw_dashboard_summary")
                summary = row_to_dict(cursor)

                cursor.execute("""
                    SELECT
                        region_id,
                        region_name,
                        district_name,
                        population,
                        vulnerability_score,
                        rainfall_mm,
                        water_level_percent,
                        vegetation_index,
                        severity_level
                    FROM vw_region_drought_status
                    ORDER BY
                        CASE severity_level
                            WHEN 'CRITICAL' THEN 1
                            WHEN 'HIGH' THEN 2
                            WHEN 'MODERATE' THEN 3
                            WHEN 'LOW' THEN 4
                            ELSE 5
                        END,
                        vulnerability_score DESC
                """)

                region_status = rows_to_dicts(cursor)

        return {
            "summary": summary,
            "region_status": region_status
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))