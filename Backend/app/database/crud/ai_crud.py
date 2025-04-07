from sqlalchemy import func
from sqlalchemy.orm import Session
from app.models import category_model, type_model, icon_model
from app.schemas import category_schema, ai_schema
from app.utils.ai_utils import predict, update_model_with_new_data
from typing import Optional

import base64


def categorize(db: Session, categorize_data: ai_schema.Categorize) -> Optional[category_model.CategoryModel]:
    predicted_category = predict(categorize_data.name)

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
        .filter(func.lower(category_model.CategoryModel.name) == predicted_category.lower())
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


def train(train_data: ai_schema.Train):
    update_model_with_new_data(train_data)
