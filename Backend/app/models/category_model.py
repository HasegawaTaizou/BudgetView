from sqlalchemy import Column, Integer, String, ForeignKey
from sqlalchemy.orm import relationship
from app.database.database import Base

class CategoryModel(Base):
    __tablename__ = 'TBL_CATEGORY'

    id = Column(Integer, primary_key=True, index=True, autoincrement=True, nullable=False, name="id_category")
    name = Column(String(45), nullable=False, unique=True, name="name")
    
    id_icon = Column(Integer, ForeignKey('TBL_ICON.id_icon'), nullable=False, name="FK_CATEGORY_ICON")
    id_type = Column(Integer, ForeignKey('TBL_TYPE.id_type'), nullable=False, name="FK_CATEGORY_TYPE")
    
    icon = relationship("IconModel", back_populates="categories")
    type = relationship("TypeModel", back_populates="categories")
    transactions = relationship("TransactionModel", back_populates="category", cascade="all, delete-orphan")