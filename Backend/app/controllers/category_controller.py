from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.schemas import category_schema
from app.database.crud import category_crud
from app.database.database import get_db

router = APIRouter(prefix="/api/v1")


@router.post("/categories", response_model=category_schema.CategoryCreateResponse, status_code=201)
async def create_category(category_data: category_schema.CategoryCreate, db: Session = Depends(get_db)):
    new_category = category_crud.create_category(
        db, category_data=category_data)

    if not new_category:
        raise HTTPException(
            status_code=400, detail="Failed to create category")

    return new_category


@router.get("/categories", response_model=category_schema.CategoryListResponse)
def read_categories(db: Session = Depends(get_db)):
    categories = category_crud.get_categories(db)
    return {"categories": categories}


@router.get("/categories/{category_id}", response_model=category_schema.CategoryResponse)
def read_category(category_id: int, db: Session = Depends(get_db)):
    db_category = category_crud.get_category_by_id(db, category_id=category_id)
    if db_category is None:
        raise HTTPException(status_code=404, detail="Category not found")
    return db_category


@router.delete("/categories/{category_id}", status_code=204)
def delete_category(category_id: int, db: Session = Depends(get_db)):
    db_category = category_crud.get_category_by_id(db, category_id=category_id)
    if db_category is None:
        raise HTTPException(status_code=404, detail="Category not found")

    category_crud.delete_category(db, category_id=category_id)
    return None


@router.get("/categories/types/{type}", response_model=category_schema.CategoryListResponse)
def read_categories_type(type: str, db: Session = Depends(get_db)):
    categories = category_crud.get_categories_by_type(db, type=type)
    return {"categories": categories}


@router.put("/categories/{category_id}",  status_code=204)
def update_category(
    category_id: int,
    category_data: category_schema.CategoryUpdate,
    db: Session = Depends(get_db)
):
    db_category = category_crud.get_category_by_id(
        db, category_id=category_id)
    if db_category is None:
        raise HTTPException(status_code=404, detail="Category not found")

    try:
        category_crud.update_category(
            db, category_id=category_id, category_data=category_data)
    except:
        raise HTTPException(
            status_code=400, detail="Failed to update category")
