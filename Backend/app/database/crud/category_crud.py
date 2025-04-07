from sqlalchemy.orm import Session
from app.models import category_model, type_model, transaction_model, icon_model
from app.models.type_model import TypeEnum
from app.schemas import category_schema
from typing import List, Optional
import base64


def create_category(db: Session, category_data: category_schema.CategoryCreate) -> category_schema.CategoryResponse:
    type_enum = TypeEnum[category_data.type]

    type = db.query(type_model.TypeModel).filter_by(type=type_enum).first()

    new_category = category_model.CategoryModel(
        name=category_data.name,
        id_icon=category_data.id_icon,
        id_type=type.id
    )

    db.add(new_category)
    db.commit()
    db.refresh(new_category)

    return category_schema.CategoryCreateResponse(
        id=new_category.id,
        name=new_category.name,
        id_icon=new_category.id_icon,
        id_type=new_category.id_type
    )


def get_categories(db: Session, skip: int = 0, limit: int = 100) -> List[category_model.CategoryModel]:
    categories = (
        db.query(
            category_model.CategoryModel.id,
            category_model.CategoryModel.name,
            type_model.TypeModel.type.label("category_type"),
            icon_model.IconModel.id.label("id_icon"),
            icon_model.IconModel.icon.label("category_icon")
        )
        .join(type_model.TypeModel, category_model.CategoryModel.id_type == type_model.TypeModel.id)
        .join(icon_model.IconModel, category_model.CategoryModel.id_icon == icon_model.IconModel.id)
        .order_by(category_model.CategoryModel.name)
        .offset(skip)
        .limit(limit)
        .all()
    )

    def encode_icon(icon_data):
        return base64.b64encode(icon_data).decode('utf-8') if icon_data else None

    return [
        category_schema.CategoryResponse(
            id=c.id,
            name=c.name,
            category_type=c.category_type.value,
            id_icon=c.id_icon,
            category_icon=encode_icon(c.category_icon)
        )
        for c in categories
    ]


def get_category_by_id(db: Session, category_id: int) -> Optional[category_model.CategoryModel]:
    category = (
        db.query(
            category_model.CategoryModel.id,
            category_model.CategoryModel.name,
            type_model.TypeModel.type.label("category_type"),
            icon_model.IconModel.id.label("id_icon"),
            icon_model.IconModel.icon.label("category_icon")
        )
        .join(type_model.TypeModel, category_model.CategoryModel.id_type == type_model.TypeModel.id)
        .join(icon_model.IconModel, category_model.CategoryModel.id_icon == icon_model.IconModel.id)
        .filter(category_model.CategoryModel.id == category_id)
        .first()
    )

    if not category:
        return None

    def encode_icon(icon_data):
        return base64.b64encode(icon_data).decode('utf-8') if icon_data else None

    return category_schema.CategoryResponse(
        id=category.id,
        name=category.name,
        category_type=category.category_type.value,
        id_icon=category.id_icon,
        category_icon=encode_icon(category.category_icon)
    )


def get_categories_by_type(db: Session, type: str) -> category_schema.CategoryListResponse:
    try:
        type_enum = TypeEnum[type]
    except KeyError:
        return category_schema.CategoryListResponse(categories=[])

    categories = (
        db.query(
            category_model.CategoryModel.id,
            category_model.CategoryModel.name,
            type_model.TypeModel.type.label("category_type"),
            icon_model.IconModel.id.label("id_icon"),
            icon_model.IconModel.icon.label("category_icon")
        )
        .join(type_model.TypeModel, category_model.CategoryModel.id_type == type_model.TypeModel.id)
        .join(icon_model.IconModel, category_model.CategoryModel.id_icon == icon_model.IconModel.id)
        .filter(type_model.TypeModel.type == type_enum)
        .order_by(category_model.CategoryModel.name)
        .all()
    )

    def encode_icon(icon_data):
        return base64.b64encode(icon_data).decode('utf-8') if icon_data else None

    return [
        category_schema.CategoryResponse(
            id=c.id,
            name=c.name,
            id_icon=c.id_icon,
            category_type=c.category_type.value,
            category_icon=encode_icon(c.category_icon)
        )
        for c in categories
    ]


def delete_category(db: Session, category_id: int):
    category = db.query(category_model.CategoryModel).filter(
        category_model.CategoryModel.id == category_id).first()
    if category is None:
        return None

    category_type = category.type.type

    if category_type == TypeEnum.EARN:
        generic_category = db.query(category_model.CategoryModel).join(type_model.TypeModel).filter(
            type_model.TypeModel.type == TypeEnum.EARN,
            category_model.CategoryModel.name == "Outros (Ganhos)"
        ).first()
    else:
        generic_category = db.query(category_model.CategoryModel).join(type_model.TypeModel).filter(
            type_model.TypeModel.type == TypeEnum.SPEND,
            category_model.CategoryModel.name == "Outros (Gastos)"
        ).first()

    db.query(transaction_model.TransactionModel).filter(
        transaction_model.TransactionModel.id_category == category_id
    ).update({"id_category": generic_category.id})

    db.delete(category)
    db.commit()



def update_category(db: Session, category_id: int, category_data: category_schema.CategoryUpdate):
    category = db.query(category_model.CategoryModel).filter(
        category_model.CategoryModel.id == category_id
    ).first()

    if not category:
        return None

    update_data = category_data.model_dump(exclude_unset=True)

    if "type" in update_data:
        try:
            type_enum = TypeEnum[update_data["type"]]
        except KeyError:
            raise ValueError(f"Invalid Type: {update_data['type']}")

        type_instance = db.query(type_model.TypeModel).filter_by(
            type=type_enum).first()
        if not type_instance:
            raise ValueError(f"Type '{update_data['type']}' not found")

        category.id_type = type_instance.id
        del update_data["type"]

    for key, value in update_data.items():
        setattr(category, key, value)

    db.commit()
    db.refresh(category)
    return category
