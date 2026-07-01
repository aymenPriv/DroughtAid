from fastapi import APIRouter, HTTPException

from app.database import get_connection, rows_to_dicts

router = APIRouter(prefix="/api/aid-items", tags=["Aid Items"])


@router.get("")
def get_aid_items():
    try:
        with get_connection() as connection:
            with connection.cursor() as cursor:
                cursor.execute("""
                    SELECT
                        ai.aid_item_id,
                        ai.item_name,
                        ai.item_category,
                        ai.unit,
                        inv.inventory_id,
                        inv.quantity_available,
                        inv.minimum_stock,
                        inv.last_updated
                    FROM aid_items ai
                    LEFT JOIN aid_inventory inv
                        ON ai.aid_item_id = inv.aid_item_id
                    ORDER BY ai.aid_item_id
                """)

                return rows_to_dicts(cursor)

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))