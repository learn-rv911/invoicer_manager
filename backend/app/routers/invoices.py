from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from ..db import get_db
from ..schemas import InvoiceCreate, InvoiceOut
from ..crud import invoices as crud
from datetime import date

router = APIRouter(prefix="/invoices", tags=["Invoices"])


@router.get("/next-number")
def get_next_invoice_number(
    company_id: int = Query(...),
    issue_date: date = Query(...),
    db: Session = Depends(get_db)
):
    """Get the next invoice sequence number for a company and year"""
    next_seq = crud.get_next_invoice_sequence(db, company_id, issue_date)
    return {"next_sequence": next_seq}


@router.get("/", response_model=list[InvoiceOut])
def list_invoices(client_id: int | None = None, project_id: int | None = None, status: str | None = None, company_id: int | None = None,
                  db: Session = Depends(get_db)):
    return [InvoiceOut.model_validate(x) for x in crud.list_invoices(db, client_id, project_id, status, company_id)]


@router.post("/", response_model=InvoiceOut)
def create_invoice(payload: InvoiceCreate, db: Session = Depends(get_db)):
    return InvoiceOut.model_validate(crud.create_invoice(db, payload))
