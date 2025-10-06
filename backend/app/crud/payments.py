from sqlalchemy.orm import Session
from .. import models
from ..schemas import PaymentCreate


def list_payments(db: Session, company_id: int | None = None, client_id: int | None = None,
                  project_id: int | None = None):
    q = db.query(models.Payment)
    if company_id: q = q.filter(models.Payment.company_id == company_id)
    if client_id: q = q.filter(models.Payment.client_id == client_id)
    if project_id: q = q.filter(models.Payment.project_id == project_id)
    return q.order_by(models.Payment.payment_date.desc()).all()


def create_payment(db: Session, payload: PaymentCreate):
    obj = models.Payment(**payload.dict())
    db.add(obj);
    db.commit();
    db.refresh(obj)
    return obj
