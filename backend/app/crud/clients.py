from sqlalchemy.orm import Session
from .. import models
from ..schemas import ClientCreate


def list_clients(db: Session, company_id: int | None = None, q: str | None = None):
    query = db.query(models.Client)
    if company_id:
        query = query.filter(models.Client.company_id == company_id)
    if q:
        like = f"%{q}%"
        query = query.filter(models.Client.name.ilike(like))
    return query.order_by(models.Client.created_at.desc()).all()


def create_client(db: Session, payload: ClientCreate):
    obj = models.Client(**payload.dict())
    db.add(obj);
    db.commit();
    db.refresh(obj)
    return obj


def get_client(db: Session, client_id: int):
    return db.query(models.Client).get(client_id)
