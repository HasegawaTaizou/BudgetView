from sqlalchemy import Column, Integer, LargeBinary
from sqlalchemy.orm import relationship
from app.database.database import Base

class IconModel(Base):
    __tablename__ = "TBL_ICON"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True, nullable=False, name="id_icon")
    icon = Column(LargeBinary, nullable=False, name="icon")
    
    categories = relationship("CategoryModel", back_populates="icon")
