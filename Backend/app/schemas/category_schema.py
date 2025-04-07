from pydantic import BaseModel
from typing import List
from .type_schema import TypeEnum


class CategoryCreate(BaseModel):
    name: str
    id_icon: int
    type: TypeEnum

    class Config:
        from_attributes = True


class CategoryUpdate(BaseModel):
    name: str
    id_icon: int
    type: TypeEnum

    class Config:
        from_attributes = True


class CategoryCreateResponse(BaseModel):
    id: int
    name: str
    id_icon: int
    id_type: int

    class Config:
        from_attributes = True


class CategoryResponse(BaseModel):
    id: int
    name: str
    category_type: str
    id_icon: int
    category_icon: str

    class Config:
        from_attributes = True


class CategoryListResponse(BaseModel):
    categories: List[CategoryResponse]

    class Config:
        from_attributes = True
