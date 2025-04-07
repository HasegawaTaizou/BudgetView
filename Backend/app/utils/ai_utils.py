import pandas as pd
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.naive_bayes import MultinomialNB
from sklearn.pipeline import make_pipeline
import joblib
import json
import os

from ..schemas.ai_schema import Train

DATA_PATH = os.path.abspath("./app/ai/transactions_data.json")
MODEL_PATH = os.path.abspath("./app/ai/categorizer_model.pkl")


def load_data():
    if os.path.exists(DATA_PATH):
        with open(DATA_PATH, "r", encoding="utf-8") as f:
            return json.load(f)
    return []


def train_and_save_model(model_path=MODEL_PATH):
    data = pd.DataFrame(load_data())
    if not data.empty:
        X = data["name"]
        y = data["category"]
        model = make_pipeline(TfidfVectorizer(), MultinomialNB())
        model.fit(X, y)
        joblib.dump(model, model_path)


if not os.path.exists(MODEL_PATH):
    os.makedirs(os.path.dirname(MODEL_PATH), exist_ok=True)
    train_and_save_model()


model = joblib.load(MODEL_PATH)


def predict(transaction_name: str) -> str:
    category_predicted = model.predict([transaction_name])[0]

    return category_predicted


def update_model_with_new_data(new_data: Train, model_path=MODEL_PATH):
    existing_data = load_data()

    combined_data = existing_data + new_data

    with open(DATA_PATH, "w", encoding="utf-8") as f:
        json.dump(combined_data, f, ensure_ascii=False, indent=4)

    train_and_save_model(model_path=model_path)
