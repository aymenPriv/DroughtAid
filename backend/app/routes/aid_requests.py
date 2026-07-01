from typing import Optional

import oracledb
from fastapi import APIRouter, HTTPException

from app.database import get_connection, row_to_dict, rows_to_dicts
from app.schemas import AidRequestCreate

router = APIRouter(prefix="/api/aid-requests", tags=["Aid Requests"])


@router.get("")
def get_aid_requests(status: Optional[str] = None):
    try:
        with get_connection() as connection:
            with connection.cursor() as cursor:
                sql = """
                    SELECT
                        ar.request_id,
                        ar.region_id,
                        r.region_name,
                        ar.aid_item_id,
                        ai.item_name,
                        ar.requested_quantity,
                        ar.urgency_level,
                        ar.request_status,
                        ar.request_date
                    FROM aid_requests ar
                    JOIN regions r ON ar.region_id = r.region_id
                    JOIN aid_items ai ON ar.aid_item_id = ai.aid_item_id
                """

                params = {}

                if status:
                    sql += " WHERE ar.request_status = :status"
                    params["status"] = status.upper()

                sql += " ORDER BY ar.request_id DESC"

                cursor.execute(sql, params)
                return rows_to_dicts(cursor)

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("")
def submit_aid_request(payload: AidRequestCreate):
    try:
        with get_connection() as connection:
            with connection.cursor() as cursor:
                request_id_var = cursor.var(oracledb.DB_TYPE_NUMBER)

                cursor.callproc(
                    "pkg_drought_aid.submit_aid_request",
                    [
                        payload.region_id,
                        payload.aid_item_id,
                        payload.requested_quantity,
                        payload.urgency_level,
                        request_id_var,
                    ],
                )

                request_id = int(request_id_var.getvalue())
                connection.commit()

                cursor.execute(
                    """
                    SELECT
                        ar.request_id,
                        ar.region_id,
                        r.region_name,
                        ar.aid_item_id,
                        ai.item_name,
                        ar.requested_quantity,
                        ar.urgency_level,
                        ar.request_status,
                        ar.request_date
                    FROM aid_requests ar
                    JOIN regions r ON ar.region_id = r.region_id
                    JOIN aid_items ai ON ar.aid_item_id = ai.aid_item_id
                    WHERE ar.request_id = :request_id
                    """,
                    {"request_id": request_id},
                )

                request = row_to_dict(cursor)

        return {
            "message": "Aid request submitted successfully.",
            "request": request,
        }

    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))