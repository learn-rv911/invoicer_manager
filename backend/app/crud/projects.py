from sqlalchemy.orm import Session
from .. import models
from ..schemas import ProjectCreate


def list_projects(db: Session, company_id: int | None = None, client_id: int | None = None, q: str | None = None):
    query = db.query(models.Project)
    if company_id:
        query = query.filter(models.Project.company_id == company_id)
    if client_id:
        query = query.filter(models.Project.client_id == client_id)
    if q:
        like = f"%{q}%"
        query = query.filter(models.Project.name.ilike(like))
    return query.order_by(models.Project.created_at.desc()).all()


def create_project(db: Session, payload: ProjectCreate):
    obj = models.Project(**payload.dict())
    db.add(obj);
    db.commit();
    db.refresh(obj)
    return obj
