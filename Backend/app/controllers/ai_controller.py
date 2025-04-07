from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.database.crud import ai_crud
from app.database.database import get_db
from app.schemas import ai_schema, category_schema

router = APIRouter(prefix="/api/v1")


@router.post("/ai/categorize", response_model=category_schema.CategoryResponse)
def categorize(categorize_data: ai_schema.Categorize, db: Session = Depends(get_db)):
    db_ai = ai_crud.categorize(db, categorize_data=categorize_data)
    return db_ai


@router.post("/ai/train")
def categorize(train_data: ai_schema.Train, db: Session = Depends(get_db)):
    ai_crud.train(db, train_data=train_data)
