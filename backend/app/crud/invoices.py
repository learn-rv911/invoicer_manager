from sqlalchemy.orm import Session
from sqlalchemy import func, extract, Integer
from .. import models
from ..schemas import InvoiceCreate
from datetime import date


def list_invoices(db: Session, client_id: int | None = None, project_id: int | None = None, status: str | None = None, company_id: int | None = None):
    q = db.query(models.Invoice)
    if client_id: q = q.filter(models.Invoice.client_id == client_id)
    if project_id: q = q.filter(models.Invoice.project_id == project_id)
    if status: q = q.filter(models.Invoice.status == status)
    if company_id: 
        # Join with projects to filter by company_id
        q = q.join(models.Project, models.Invoice.project_id == models.Project.id)
        q = q.filter(models.Project.company_id == company_id)
    return q.order_by(models.Invoice.issue_date.desc(), models.Invoice.invoice_number.desc()).all()


def get_next_invoice_sequence(db: Session, company_id: int, issue_date: date) -> int:
    """
    Get the next invoice sequence number for a given company and year.
    Returns the next sequence starting from 1.
    """
    year = issue_date.year
    
    # Find the max sequence for this company and year by parsing invoice numbers
    # Invoice format: INV{yy}#{seq} where yy is year mod 100, seq is 001-999
    year_suffix = year % 100
    pattern = f"INV{year_suffix:02d}#%"
    
    # Get all invoices matching the pattern for this company
    # We need to join with projects and clients to get company_id
    max_seq = db.query(func.max(
        func.cast(func.substr(models.Invoice.invoice_number, 8, 3), Integer)
    )).join(
        models.Project, models.Invoice.project_id == models.Project.id
    ).filter(
        models.Project.company_id == company_id,
        models.Invoice.invoice_number.like(pattern)
    ).scalar()
    
    return (max_seq or 0) + 1


def create_invoice(db: Session, payload: InvoiceCreate):
    # Exclude items field as it's not part of the Invoice model
    invoice_data = payload.model_dump(exclude={'items'})
    obj = models.Invoice(**invoice_data)
    db.add(obj);
    db.commit();
    db.refresh(obj)
    return obj


def totals_for_dashboard(db: Session):
    total_amount = db.query(func.coalesce(func.sum(models.Invoice.total), 0)).scalar()
    total_paid = db.query(func.coalesce(func.sum(models.Payment.amount), 0)).scalar()
    outstanding = float(total_amount) - float(total_paid)
    return float(total_amount), float(total_paid), float(outstanding)
