from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from ..db import get_db
from ..crud import users as crud_users
from ..schemas import UserOut

router = APIRouter(prefix="/auth", tags=["Auth"])


@router.post("/login", response_model=dict)
def login(payload: dict, db: Session = Depends(get_db)):
    email = payload.get("email");
    password = payload.get("password")
    if not email or not password:
        raise HTTPException(status_code=400, detail="Email and password required")
    user = crud_users.get_user_by_email(db, email=email)
    if not user or user.password != password:
        raise HTTPException(status_code=400, detail="Invalid credentials")
    return {"success": True, "user": UserOut.model_validate(user)}
