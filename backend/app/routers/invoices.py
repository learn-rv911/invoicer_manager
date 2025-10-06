from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from ..db import get_db
from ..schemas import InvoiceCreate, InvoiceOut
from ..crud import invoices as crud

router = APIRouter(prefix="/invoices", tags=["Invoices"])


@router.get("/", response_model=list[InvoiceOut])
def list_invoices(client_id: int | None = None, project_id: int | None = None, status: str | None = None,
                  db: Session = Depends(get_db)):
    return [InvoiceOut.model_validate(x) for x in crud.list_invoices(db, client_id, project_id, status)]


@router.post("/", response_model=InvoiceOut)
def create_invoice(payload: InvoiceCreate, db: Session = Depends(get_db)):
    return InvoiceOut.model_validate(crud.create_invoice(db, payload))
