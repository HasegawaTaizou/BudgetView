from pydantic import BaseModel
from typing import List


class IconCreate(BaseModel):
    icon: bytes

    class Config:
        from_attributes = True


class IconResponse(BaseModel):
    id: int
    icon: str

    class Config:
        from_attributes = True


class IconListResponse(BaseModel):
    icons: List[IconResponse]

    class Config:
        from_attributes = True
