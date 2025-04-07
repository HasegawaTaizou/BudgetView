import os
import json
from datetime import datetime
from app.models import type_model, icon_model, category_model, transaction_model
from app.models.type_model import TypeEnum
from sqlalchemy.orm import Session
from app.database.database import get_db
import chardet


def convert_to_utf8(file_path, output_path=None):
    with open(file_path, 'rb') as f:
        raw_data = f.read()

    detected = chardet.detect(raw_data)
    encoding = detected['encoding']

    text = raw_data.decode(encoding)

    output_path = output_path or file_path

    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(text)


def create_default_types(db: Session):
    default_types = ["EARN", "SPEND"]

    existing_types = {t.type for t in db.query(type_model.TypeModel).filter(
        type_model.TypeModel.type.in_(default_types)).all()}

    new_types = [type_model.TypeModel(
        type=t) for t in default_types if t not in existing_types]

    if new_types:
        db.bulk_save_objects(new_types)
        db.commit()


def create_default_icons(db: Session):
    icons_dir = os.path.join(os.getcwd(), "app", "assets", "icons")

    default_icons = [f for f in os.listdir(icons_dir) if os.path.isfile(
        os.path.join(icons_dir, f)) and f.endswith(".png")]

    existing_icons = {icon.id for icon in db.query(icon_model.IconModel).all()}

    new_icons = []
    for icon_filename in default_icons:
        icon_path = os.path.join(icons_dir, icon_filename)

        if os.path.exists(icon_path):
            with open(icon_path, "rb") as icon_file:
                icon_data = icon_file.read()

            if icon_filename not in existing_icons:
                new_icons.append(icon_model.IconModel(icon=icon_data))

    if new_icons:
        db.bulk_save_objects(new_icons)
        db.commit()


def create_default_categories(db: Session):
    json_path = os.path.join(
        os.getcwd(), "app", "database", "seed", "categories.json")

    if not os.path.exists(json_path):
        print(f"File {json_path} not found.")
        return

    with open(json_path, "r", encoding="utf-8") as file:
        default_categories = json.load(file)

    existing_types = db.query(type_model.TypeModel).all()
    earn_type = next(
        (t for t in existing_types if t.type == TypeEnum.EARN), None)
    spend_type = next(
        (t for t in existing_types if t.type == TypeEnum.SPEND), None)

    existing_icons = {icon.id: icon.icon for icon in db.query(
        icon_model.IconModel).all()}

    icons_dir = os.path.join(os.getcwd(), "app", "assets", "icons")

    new_categories = []
    for category in default_categories:
        type = earn_type if category["type"] == "EARN" else spend_type

        icon_name = f"{category['icon']}-icon.png"
        icon_path = os.path.join(icons_dir, icon_name)

        if os.path.exists(icon_path):
            with open(icon_path, "rb") as icon_file:
                icon_data = icon_file.read()

            icon_id = None
            for icon_db_id, icon_db_data in existing_icons.items():
                if icon_db_data == icon_data:
                    icon_id = icon_db_id
                    break

            if icon_id and type:
                new_category = category_model.CategoryModel(
                    name=category["name"],
                    id_type=type.id,
                    id_icon=icon_id
                )
                new_categories.append(new_category)

    if new_categories:
        db.bulk_save_objects(new_categories)
        db.commit()


def create_default_transactions(db: Session):
    json_path = os.path.join(
        os.getcwd(), "app", "database", "seed", "transactions.json")

    if not os.path.exists(json_path):
        print(f"File {json_path} not found.")
        return

    with open(json_path, "r", encoding="utf-8") as file:
        default_transactions = json.load(file)

    new_transactions = []
    for transaction in default_transactions:
        category_record = db.query(category_model.CategoryModel).filter_by(
            name=transaction["category"]).first()

        if not category_record:
            print(
                f"Category '{transaction['category']}' not found.")
            continue

        date_obj = datetime.strptime(transaction["date"], "%d/%m/%Y").date()

        new_transaction = transaction_model.TransactionModel(
            name=transaction["name"],
            value=transaction["value"],
            date=date_obj,
            id_category=category_record.id
        )
        new_transactions.append(new_transaction)

    if new_transactions:
        db.bulk_save_objects(new_transactions)
        db.commit()


def seed_db():
    categories_path = os.path.join(
        os.getcwd(), "app", "database", "seed", "categories.json")
    transactions_path = os.path.join(
        os.getcwd(), "app", "database", "seed", "transactions.json")
    
    convert_to_utf8(categories_path)
    convert_to_utf8(transactions_path)

    db_generator = get_db()
    db = next(db_generator)

    try:
        create_default_types(db)
        create_default_icons(db)
        create_default_categories(db)
        create_default_transactions(db)
    finally:
        db_generator.close()
