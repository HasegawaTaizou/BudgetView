from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.schemas import icon_schema
from app.database.crud import icon_crud
from app.database.database import get_db

router = APIRouter(prefix="/api/v1")


@router.post("/icons", response_model=icon_schema.IconResponse, status_code=201)
async def create_icon(icon_create: icon_schema.IconCreate, db: Session = Depends(get_db)):
    new_icon = icon_crud.create_icon(db, base64_icon=icon_create.icon)

    if not new_icon:
        raise HTTPException(status_code=400, detail="Failed to create icon")

    return new_icon


@router.get("/icons", response_model=icon_schema.IconListResponse)
def read_icons(db: Session = Depends(get_db)):
    icons = icon_crud.get_icons(db)
    return {"icons": icons}


@router.get("/icons/{icon_id}", response_model=icon_schema.IconResponse)
def read_icon(icon_id: int, db: Session = Depends(get_db)):
    db_icon = icon_crud.get_icon_by_id(db, icon_id=icon_id)
    if db_icon is None:
        raise HTTPException(status_code=404, detail="Icon not found")
    return db_icon
