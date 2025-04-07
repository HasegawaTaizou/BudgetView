from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.schemas import type_schema
from app.database.crud import type_crud
from app.database.database import get_db

router = APIRouter(prefix="/api/v1")

@router.get("/types", response_model=type_schema.TypeListResponse)
def read_types(db: Session = Depends(get_db)):
    types = type_crud.get_types(db)
    return {"types": types}

@router.get("/types/{type_id}", response_model=type_schema.TypeResponse)
def read_type(type_id: int, db: Session = Depends(get_db)):
    db_type = type_crud.get_type_by_id(db, type_id=type_id)
    if db_type is None:
        raise HTTPException(status_code=404, detail="Type not found")
    return db_type


