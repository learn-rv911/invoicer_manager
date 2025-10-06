from sqlalchemy.orm import Session
from .. import models
from ..schemas import CompanyCreate


def list_companies(db: Session, q: str | None = None, skip: int = 0, limit: int = 100):
    query = db.query(models.Company)
    if q:
        like = f"%{q}%"
        query = query.filter(models.Company.name.ilike(like))
    return query.order_by(models.Company.created_at.desc()).offset(skip).limit(limit).all()


def create_company(db: Session, payload: CompanyCreate):
    company = models.Company(**payload.dict())
    db.add(company);
    db.commit();
    db.refresh(company)
    return company


def get_company(db: Session, company_id: int):
    return db.query(models.Company).get(company_id)
