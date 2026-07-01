from typing import Optional

from pydantic import BaseModel, Field


class DroughtReportCreate(BaseModel):
    region_id: int
    rainfall_mm: float = Field(ge=0)
    water_level_percent: float = Field(ge=0, le=100)
    vegetation_index: float = Field(ge=0, le=1)


class AidRequestCreate(BaseModel):
    region_id: int
    aid_item_id: int
    requested_quantity: int = Field(gt=0)
    urgency_level: str


class AidAllocationCreate(BaseModel):
    request_id: int
    operator_note: Optional[str] = None