import oracledb
from fastapi import APIRouter, HTTPException

from app.database import get_connection, row_to_dict, rows_to_dicts
from app.schemas import DroughtReportCreate

router = APIRouter(prefix="/api/drought-reports", tags=["Drought Reports"])


@router.get("")
def get_drought_reports():
    try:
        with get_connection() as connection:
            with connection.cursor() as cursor:
                cursor.execute("""
                    SELECT
                        dr.report_id,
                        dr.region_id,
                        r.region_name,
                        dr.report_date,
                        dr.rainfall_mm,
                        dr.water_level_percent,
                        dr.vegetation_index,
                        dr.severity_level
                    FROM drought_reports dr
                    JOIN regions r ON dr.region_id = r.region_id
                    ORDER BY dr.report_id DESC
                """)

                return rows_to_dicts(cursor)

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("")
def add_drought_report(payload: DroughtReportCreate):
    try:
        with get_connection() as connection:
            with connection.cursor() as cursor:
                report_id_var = cursor.var(oracledb.DB_TYPE_NUMBER)

                cursor.callproc(
                    "pkg_drought_aid.add_drought_report",
                    [
                        payload.region_id,
                        payload.rainfall_mm,
                        payload.water_level_percent,
                        payload.vegetation_index,
                        report_id_var
                    ]
                )

                report_id = int(report_id_var.getvalue())
                connection.commit()

                cursor.execute("""
                    SELECT
                        report_id,
                        region_id,
                        rainfall_mm,
                        water_level_percent,
                        vegetation_index,
                        severity_level,
                        report_date
                    FROM drought_reports
                    WHERE report_id = :report_id
                """, {"report_id": report_id})

                report = row_to_dict(cursor)

        return {
            "message": "Drought report added successfully.",
            "report": report
        }

    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))