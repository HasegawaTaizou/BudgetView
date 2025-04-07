from sqlalchemy import Column, Integer, Enum
from sqlalchemy.orm import relationship
from app.database.database import Base

import enum

class TypeEnum(enum.Enum):
    EARN = "EARN"
    SPEND = "SPEND"
    
class TypeModel(Base):
    __tablename__ = 'TBL_TYPE'

    id = Column(Integer, primary_key=True, index=True, autoincrement=True, nullable=False, name="id_type")
    type = Column(Enum(TypeEnum), nullable=False, name="type", unique=True)
    
    categories = relationship("CategoryModel", back_populates="type")