from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from ..db import get_db
from ..schemas import CompanyCreate, CompanyOut
from ..crud import companies as crud

router = APIRouter(prefix="/companies", tags=["Companies"])


@router.get("/", response_model=list[CompanyOut])
def list_companies(q: str | None = None, skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    return [CompanyOut.model_validate(c) for c in crud.list_companies(db, q, skip, limit)]


@router.post("/", response_model=CompanyOut)
def create_company(payload: CompanyCreate, db: Session = Depends(get_db)):
    return CompanyOut.model_validate(crud.create_company(db, payload))
