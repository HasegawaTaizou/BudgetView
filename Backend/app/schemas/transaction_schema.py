from pydantic import BaseModel, model_validator, field_validator
from datetime import datetime, date
from typing import List

class TransactionCreate(BaseModel):
    name: str
    value: float
    date: str
    id_category: int

    @field_validator("date")
    def parse_date(cls, v):
        try:
            return datetime.strptime(v, "%d/%m/%Y").date()
        except ValueError:
            raise ValueError("Date must be in the format dd/mm/yyyy")

    class Config:
        from_attributes = True

class TransactionCreateResponse(BaseModel):
    id: int
    name: str
    value: float
    date: str
    id_category: int

    @model_validator(mode="before")
    def format_date(cls, values):
        if isinstance(values, dict):
            date_value = values.get("date")
        else:
            date_value = getattr(values, "date", None)

        if date_value and isinstance(date_value, (datetime, date)):
            formatted_date = date_value.strftime("%d/%m/%Y")
            if isinstance(values, dict):
                values["date"] = formatted_date
            else:
                setattr(values, "date", formatted_date)
        
        return values


    class Config:
        from_attributes = True

class TransactionUpdate(BaseModel):
    name: str
    value: float
    date: str
    id_category: int

    @field_validator("date")
    def parse_date(cls, v):
        try:
            return datetime.strptime(v, "%d/%m/%Y").date()
        except ValueError:
            raise ValueError("Date must be in the format dd/mm/yyyy")

    class Config:
        from_attributes = True


class TransactionResponse(BaseModel):
    id: int
    name: str
    value: float
    date: str
    id_category: int
    category_name: str
    category_type: str
    category_icon: str

    @model_validator(mode="before")
    def format_date(cls, values):
        if isinstance(values, dict):
            date_value = values.get("date")
        else:
            date_value = getattr(values, "date", None)

        if date_value and isinstance(date_value, (datetime, date)):
            formatted_date = date_value.strftime("%d/%m/%Y")
            if isinstance(values, dict):
                values["date"] = formatted_date
            else:
                setattr(values, "date", formatted_date)
        
        return values


    class Config:
        from_attributes = True


class TransactionListResponse(BaseModel):
    transactions: List[TransactionResponse]

    class Config:
        from_attributes = True
