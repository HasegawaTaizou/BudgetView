from pydantic import BaseModel
from enum import Enum
from typing import List

class TypeEnum(str, Enum):
    EARN = "EARN"
    SPEND = "SPEND"

class TypeCreate(BaseModel):
    type: TypeEnum

    class Config:
        from_attributes = True

class TypeResponse(BaseModel):
    id: int
    type: TypeEnum

    class Config:
        from_attributes = True

class TypeListResponse(BaseModel):
    types: List[TypeResponse]

    class Config:
        from_attributes = True
