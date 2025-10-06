from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from ..db import get_db
from ..schemas import PaymentCreate, PaymentOut
from ..crud import payments as crud

router = APIRouter(prefix="/payments", tags=["Payments"])


@router.get("/", response_model=list[PaymentOut])
def list_payments(company_id: int | None = None, client_id: int | None = None, project_id: int | None = None,
                  db: Session = Depends(get_db)):
    return [PaymentOut.model_validate(x) for x in crud.list_payments(db, company_id, client_id, project_id)]


@router.post("/", response_model=PaymentOut)
def create_payment(payload: PaymentCreate, db: Session = Depends(get_db)):
    return PaymentOut.model_validate(crud.create_payment(db, payload))
