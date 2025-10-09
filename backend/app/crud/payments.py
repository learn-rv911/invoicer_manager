from sqlalchemy.orm import Session
from .. import models
from ..schemas import PaymentCreate


def list_payments(db: Session, company_id: int | None = None, client_id: int | None = None,
                  project_id: int | None = None, from_date: str | None = None, to_date: str | None = None,
                  limit: int | None = None):
    from datetime import date
    
    q = db.query(models.Payment)
    if company_id: q = q.filter(models.Payment.company_id == company_id)
    if client_id: q = q.filter(models.Payment.client_id == client_id)
    if project_id: q = q.filter(models.Payment.project_id == project_id)
    if from_date: q = q.filter(models.Payment.payment_date >= date.fromisoformat(from_date))
    if to_date: q = q.filter(models.Payment.payment_date <= date.fromisoformat(to_date))
    
    q = q.order_by(models.Payment.payment_date.desc())
    if limit: q = q.limit(limit)
    
    return q.all()


def create_payment(db: Session, payload: PaymentCreate):
    obj = models.Payment(**payload.model_dump())
    db.add(obj);
    db.commit();
    db.refresh(obj)
    return obj
