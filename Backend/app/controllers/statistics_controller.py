from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.schemas import statistics_schema
from app.database.crud import statistics_crud
from app.database.database import get_db

router = APIRouter(prefix="/api/v1")


@router.get("/statistics", response_model=statistics_schema.StatisticsResponse)
def read_transactions_statistics(db: Session = Depends(get_db)):
    return statistics_crud.get_statistics(db)
