from sqlalchemy import Column, Integer, String, Float, Date, ForeignKey
from sqlalchemy.orm import relationship
from app.database.database import Base

class TransactionModel(Base):
    __tablename__ = 'TBL_TRANSACTION'

    id = Column(Integer, primary_key=True, index=True, autoincrement=True, nullable=False, name="id_transaction")
    name = Column(String(100), nullable=False, name="name")
    value = Column(Float, nullable=False, name="value")
    date = Column(Date, nullable=False, name="date")
    
    id_category = Column(Integer, ForeignKey('TBL_CATEGORY.id_category'), nullable=False, name="FK_TRANSACTION_CATEGORY")

    category = relationship("CategoryModel", back_populates="transactions")