from app.database.database import engine, Base
from app.models import type_model, icon_model, category_model, transaction_model
from .seed_db import seed_db
from ..utils.ai_utils import train_and_save_model


def init_db():
    Base.metadata.drop_all(bind=engine)
    print("Creating tables...")
    Base.metadata.create_all(bind=engine)
    print("Tables created successfully!")

    print("Seeding tables...")
    seed_db()
    print("Tables seeded successfully!")

    print("Training model...")
    # train_and_save_model()
    print("Model training successfully...")


init_db()
