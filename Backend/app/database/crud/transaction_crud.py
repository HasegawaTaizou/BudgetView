from sqlalchemy.orm import Session
from app.models import transaction_model, category_model, type_model, icon_model
from app.schemas import transaction_schema
from app.models.type_model import TypeEnum
from typing import List, Optional
import base64


def create_transaction(db: Session, transaction_data: transaction_schema.TransactionCreate) -> transaction_model.TransactionModel:
    transaction_dict = transaction_data.model_dump()

    new_transaction = transaction_model.TransactionModel(
        name=transaction_dict["name"],
        value=transaction_dict["value"],
        date=transaction_dict["date"],
        id_category=transaction_dict["id_category"]
    )

    db.add(new_transaction)
    db.commit()
    db.refresh(new_transaction)

    return new_transaction


def get_transactions(db: Session) -> List[transaction_schema.TransactionResponse]:
    transactions = (
        db.query(
            transaction_model.TransactionModel.id,
            transaction_model.TransactionModel.name,
            transaction_model.TransactionModel.value,
            transaction_model.TransactionModel.date,
            transaction_model.TransactionModel.id_category,
            category_model.CategoryModel.name.label("category_name"),
            type_model.TypeModel.type.label("category_type"),
            icon_model.IconModel.icon.label("category_icon")
        )
        .join(category_model.CategoryModel, transaction_model.TransactionModel.id_category == category_model.CategoryModel.id)
        .join(type_model.TypeModel, category_model.CategoryModel.id_type == type_model.TypeModel.id)
        .join(icon_model.IconModel, category_model.CategoryModel.id_icon == icon_model.IconModel.id)
        .order_by(transaction_model.TransactionModel.date.desc())
        .all()
    )

    def encode_icon(icon_data):
        return base64.b64encode(icon_data).decode('utf-8') if icon_data else None

    return [
        transaction_schema.TransactionResponse(
            id=t.id,
            name=t.name,
            value=t.value,
            date=t.date,
            id_category=t.id_category,
            category_name=t.category_name,
            category_type=t.category_type.value,
            category_icon=encode_icon(t.category_icon)
        )
        for t in transactions
    ]


def get_transaction_by_id(db: Session, transaction_id: int) -> Optional[transaction_schema.TransactionResponse]:
    transaction = (
        db.query(
            transaction_model.TransactionModel.id,
            transaction_model.TransactionModel.name,
            transaction_model.TransactionModel.value,
            transaction_model.TransactionModel.date,
            transaction_model.TransactionModel.id_category,
            category_model.CategoryModel.name.label("category_name"),
            type_model.TypeModel.type.label("category_type"),
            icon_model.IconModel.icon.label("category_icon")
        )
        .join(category_model.CategoryModel, transaction_model.TransactionModel.id_category == category_model.CategoryModel.id)
        .join(type_model.TypeModel, category_model.CategoryModel.id_type == type_model.TypeModel.id)
        .join(icon_model.IconModel, category_model.CategoryModel.id_icon == icon_model.IconModel.id)
        .filter(transaction_model.TransactionModel.id == transaction_id)
        .first()
    )

    if not transaction:
        return None

    def encode_icon(icon_data):
        return base64.b64encode(icon_data).decode('utf-8') if icon_data else None

    return transaction_schema.TransactionResponse(
        id=transaction.id,
        name=transaction.name,
        value=transaction.value,
        date=transaction.date.strftime("%d/%m/%Y"),
        id_category=transaction.id_category,
        category_name=transaction.category_name,
        category_type=transaction.category_type.value,
        category_icon=encode_icon(transaction.category_icon)
    )


def get_transactions_by_type(db: Session, type: str) -> transaction_schema.TransactionListResponse:
    try:
        type_enum = TypeEnum[type]
    except KeyError:
        return transaction_schema.TransactionListResponse(transactions=[])

    transactions = (
        db.query(
            transaction_model.TransactionModel.id,
            transaction_model.TransactionModel.name,
            transaction_model.TransactionModel.value,
            transaction_model.TransactionModel.date,
            transaction_model.TransactionModel.id_category,
            category_model.CategoryModel.name.label("category_name"),
            type_model.TypeModel.type.label("category_type"),
            icon_model.IconModel.icon.label("category_icon")
        )
        .join(category_model.CategoryModel, transaction_model.TransactionModel.id_category == category_model.CategoryModel.id)
        .join(type_model.TypeModel, category_model.CategoryModel.id_type == type_model.TypeModel.id)
        .join(icon_model.IconModel, category_model.CategoryModel.id_icon == icon_model.IconModel.id)
        .filter(type_model.TypeModel.type == type_enum)
        .order_by(transaction_model.TransactionModel.date.desc())
        .all()
    )

    def encode_icon(icon_data):
        return base64.b64encode(icon_data).decode('utf-8') if icon_data else None

    return [
        transaction_schema.TransactionResponse(
            id=t.id,
            name=t.name,
            value=t.value,
            date=t.date,
            id_category=t.id_category,
            category_name=t.category_name,
            category_type=t.category_type.value,
            category_icon=encode_icon(t.category_icon)
        )
        for t in transactions
    ]


def delete_transaction(db: Session, transaction_id: int):
    transaction = db.query(transaction_model.TransactionModel).filter(
        transaction_model.TransactionModel.id == transaction_id).first()
    if transaction is None:
        return None

    db.delete(transaction)
    db.commit()


def update_transaction(db: Session, transaction_id: int, transaction_data: transaction_schema.TransactionUpdate):
    transaction = db.query(transaction_model.TransactionModel).filter(
        transaction_model.TransactionModel.id == transaction_id
    ).first()

    if not transaction:
        return None

    update_data = transaction_data.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(transaction, key, value)

    db.commit()
    db.refresh(transaction)
