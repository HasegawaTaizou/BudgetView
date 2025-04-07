from sqlalchemy.orm import Session
from app.models import type_model
from typing import List, Optional

def get_types(db: Session, skip: int = 0, limit: int = 100) -> List[type_model.TypeModel]:
    return db.query(type_model.TypeModel).offset(skip).limit(limit).all()

def get_type_by_id(db: Session, type_id: int) -> Optional[type_model.TypeModel]:
    return db.query(type_model.TypeModel).filter(type_model.TypeModel.id == type_id).first()
