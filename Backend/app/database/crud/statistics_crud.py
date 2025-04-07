from sqlalchemy.orm import Session
from app.models import transaction_model, category_model, type_model
from app.models.type_model import TypeEnum


def calculate_percentage(category_total, total):
    return "{:.2f}%".format((category_total / total) * 100) if total > 0 else "0%"


def get_statistics(db: Session):
    transactions = db.query(transaction_model.TransactionModel).join(
        category_model.CategoryModel, transaction_model.TransactionModel.id_category == category_model.CategoryModel.id
    ).join(
        type_model.TypeModel, category_model.CategoryModel.id_type == type_model.TypeModel.id
    ).all()

    if not transactions:
        return {
            "total_spend": "0.00",
            "total_earn": "0.00",
            "earn_statistics": [],
            "spend_statistics": []
        }

    earn_categories = {}
    spend_categories = {}
    total_earn = 0
    total_spend = 0

    for transaction in transactions:
        category_name = transaction.category.name
        transaction_value = transaction.value
        if transaction.category.type.type == TypeEnum.EARN:
            total_earn += transaction_value
            earn_categories[category_name] = earn_categories.get(
                category_name, 0) + transaction_value
        else:
            total_spend += transaction_value
            spend_categories[category_name] = spend_categories.get(
                category_name, 0) + transaction_value

    def process_categories(categories, total, category_type):
        if not categories:
            return []

        sorted_categories = sorted(
            categories.items(), key=lambda x: x[1], reverse=True)
        top_categories = sorted_categories[:3]
        other_total = sum(x[1] for x in sorted_categories[3:])
        processed = [
            {
                "category_name": name,
                "total": "{:.2f}".format(value),
                "percentage": calculate_percentage(value, total)
            }
            for name, value in top_categories
        ]
        if other_total > 0:
            category_name = "Outros (Ganhos)" if category_type == "EARN" else "Outros (Gastos)"
            processed.append({
                "category_name": category_name,
                "total": "{:.2f}".format(other_total),
                "percentage": calculate_percentage(other_total, total)
            })
        return processed

    return {
        "total_spend": "{:.2f}".format(total_spend),
        "total_earn": "{:.2f}".format(total_earn),
        "earn_statistics": process_categories(earn_categories, total_earn, "EARN"),
        "spend_statistics": process_categories(spend_categories, total_spend, "SPEND")
    }
