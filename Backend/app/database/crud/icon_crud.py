from sqlalchemy.orm import Session
from app.models import icon_model
import base64


import base64
from sqlalchemy.orm import Session
import app.models.icon_model as icon_model

def create_icon(db: Session, base64_icon: str) -> dict:
    icon_data = base64.b64decode(base64_icon)

    db_icon = icon_model.IconModel(icon=icon_data)

    db.add(db_icon)
    db.commit()
    db.refresh(db_icon)

    return {
        "id": db_icon.id,
        "icon": base64.b64encode(db_icon.icon).decode("utf-8")  # <-- importante!
    }



def get_icons(db: Session):
    icons = db.query(icon_model.IconModel).all()
    return [{"id": icon.id, "icon": base64.b64encode(icon.icon).decode('utf-8')} for icon in icons]


def get_icon_by_id(db: Session, icon_id: int):
    icon = db.query(icon_model.IconModel).filter(
        icon_model.IconModel.id == icon_id).first()
    if icon:
        return {"id": icon.id, "icon": base64.b64encode(icon.icon).decode('utf-8')}
    return None
