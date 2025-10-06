from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from ..db import get_db
from ..schemas import ClientCreate, ClientOut
from ..crud import clients as crud

router = APIRouter(prefix="/clients", tags=["Clients"])


@router.get("/", response_model=list[ClientOut])
def list_clients(company_id: int | None = None, q: str | None = None, db: Session = Depends(get_db)):
    return [ClientOut.model_validate(c) for c in crud.list_clients(db, company_id, q)]


@router.post("/", response_model=ClientOut)
def create_client(payload: ClientCreate, db: Session = Depends(get_db)):
    return ClientOut.model_validate(crud.create_client(db, payload))
