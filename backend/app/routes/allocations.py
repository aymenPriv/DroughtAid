import oracledb
from fastapi import APIRouter, HTTPException

from app.database import get_connection, row_to_dict, rows_to_dicts
from app.schemas import AidAllocationCreate

router = APIRouter(prefix="/api/allocations", tags=["Allocations"])


@router.get("")
def get_allocations():
    try:
        with get_connection() as connection:
            with connection.cursor() as cursor:
                cursor.execute("""
                    SELECT
                        allocation_id,
                        request_id,
                        region_id,
                        region_name,
                        district_name,
                        aid_item_id,
                        item_name,
                        item_category,
                        unit,
                        requested_quantity,
                        allocated_quantity,
                        priority_score,
                        allocation_status,
                        allocation_date,
                        operator_note
                    FROM vw_allocation_details
                    ORDER BY allocation_id DESC
                """)

                return rows_to_dicts(cursor)

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("")
def allocate_aid(payload: AidAllocationCreate):
    try:
        with get_connection() as connection:
            with connection.cursor() as cursor:
                note_var = cursor.var(oracledb.DB_TYPE_VARCHAR, size=500)
                allocated_var = cursor.var(oracledb.DB_TYPE_NUMBER)

                note_var.setvalue(0, payload.operator_note or "Processed from FastAPI")

                cursor.callproc(
                    "pkg_drought_aid.allocate_aid",
                    [
                        payload.request_id,
                        note_var,
                        allocated_var
                    ]
                )

                allocated_quantity = int(allocated_var.getvalue())
                final_note = note_var.getvalue()

                connection.commit()

                cursor.execute("""
                    SELECT
                        allocation_id,
                        request_id,
                        region_name,
                        item_name,
                        requested_quantity,
                        allocated_quantity,
                        priority_score,
                        allocation_status,
                        operator_note,
                        allocation_date
                    FROM vw_allocation_details
                    WHERE request_id = :request_id
                """, {"request_id": payload.request_id})

                allocation = row_to_dict(cursor)

        return {
            "message": "Aid allocation processed successfully.",
            "allocated_quantity": allocated_quantity,
            "operator_note": final_note,
            "allocation": allocation
        }

    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.get("/audit")
def get_allocation_audit():
    try:
        with get_connection() as connection:
            with connection.cursor() as cursor:
                cursor.execute("""
                    SELECT
                        audit_id,
                        allocation_id,
                        action_type,
                        action_date,
                        description
                    FROM allocation_audit
                    ORDER BY audit_id DESC
                """)

                return rows_to_dicts(cursor)

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))