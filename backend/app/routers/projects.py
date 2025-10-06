from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from ..db import get_db
from ..schemas import ProjectCreate, ProjectOut
from ..crud import projects as crud

router = APIRouter(prefix="/projects", tags=["Projects"])


@router.get("/", response_model=list[ProjectOut])
def list_projects(company_id: int | None = None, client_id: int | None = None, q: str | None = None,
                  db: Session = Depends(get_db)):
    return [ProjectOut.model_validate(x) for x in crud.list_projects(db, company_id, client_id, q)]


@router.post("/", response_model=ProjectOut)
def create_project(payload: ProjectCreate, db: Session = Depends(get_db)):
    return ProjectOut.model_validate(crud.create_project(db, payload))
