from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.schemas import transaction_schema
from app.database.crud import transaction_crud
from app.database.database import get_db

router = APIRouter(prefix="/api/v1")


@router.post("/transactions", response_model=transaction_schema.TransactionCreateResponse, status_code=201)
async def create_transaction(transaction_data: transaction_schema.TransactionCreate, db: Session = Depends(get_db)):
    new_transaction = transaction_crud.create_transaction(
        db, transaction_data=transaction_data)

    if not new_transaction:
        raise HTTPException(
            status_code=400, detail="Failed to create transaction")

    return new_transaction


@router.get("/transactions", response_model=transaction_schema.TransactionListResponse)
def read_transactions(db: Session = Depends(get_db)):
    transactions = transaction_crud.get_transactions(db)
    return {"transactions": transactions}


@router.get("/transactions/{transaction_id}", response_model=transaction_schema.TransactionResponse)
def read_transaction(transaction_id: int, db: Session = Depends(get_db)):
    db_transaction = transaction_crud.get_transaction_by_id(
        db, transaction_id=transaction_id)
    if db_transaction is None:
        raise HTTPException(status_code=404, detail="Transaction not found")
    return db_transaction


@router.get("/transactions/types/{type}", response_model=transaction_schema.TransactionListResponse)
def read_transactions_types(type: str, db: Session = Depends(get_db)):
    transactions = transaction_crud.get_transactions_by_type(db, type=type)
    return {"transactions": transactions}


@router.delete("/transactions/{transaction_id}", status_code=204)
def delete_transaction(transaction_id: int, db: Session = Depends(get_db)):
    db_transaction = transaction_crud.get_transaction_by_id(
        db, transaction_id=transaction_id)
    if db_transaction is None:
        raise HTTPException(status_code=404, detail="Transaction not found")

    transaction_crud.delete_transaction(db, transaction_id=transaction_id)
    return None


@router.put("/transactions/{transaction_id}",  status_code=204)
def update_transaction(
    transaction_id: int,
    transaction_data: transaction_schema.TransactionUpdate,
    db: Session = Depends(get_db)
):
    db_transaction = transaction_crud.get_transaction_by_id(
        db, transaction_id=transaction_id)
    if db_transaction is None:
        raise HTTPException(status_code=404, detail="Transaction not found")

    try:
        transaction_crud.update_transaction(
            db, transaction_id=transaction_id, transaction_data=transaction_data)
    except:
        raise HTTPException(
            status_code=400, detail="Failed to update transaction")
