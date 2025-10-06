from sqlalchemy.orm import Session
from sqlalchemy import func
from .. import models
from ..schemas import InvoiceCreate


def list_invoices(db: Session, client_id: int | None = None, project_id: int | None = None, status: str | None = None):
    q = db.query(models.Invoice)
    if client_id: q = q.filter(models.Invoice.client_id == client_id)
    if project_id: q = q.filter(models.Invoice.project_id == project_id)
    if status: q = q.filter(models.Invoice.status == status)
    return q.order_by(models.Invoice.issue_date.desc()).all()


def create_invoice(db: Session, payload: InvoiceCreate):
    obj = models.Invoice(**payload.dict())
    db.add(obj);
    db.commit();
    db.refresh(obj)
    return obj


def totals_for_dashboard(db: Session):
    total_amount = db.query(func.coalesce(func.sum(models.Invoice.total), 0)).scalar()
    total_paid = db.query(func.coalesce(func.sum(models.Payment.amount), 0)).scalar()
    outstanding = float(total_amount) - float(total_paid)
    return float(total_amount), float(total_paid), float(outstanding)
