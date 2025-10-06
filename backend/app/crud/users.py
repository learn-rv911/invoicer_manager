from sqlalchemy.orm import Session
from .. import models
from ..schemas import UserCreate


def create_user(db: Session, payload: UserCreate):
    user = models.User(email=payload.email, password=payload.password)
    db.add(user);
    db.commit();
    db.refresh(user)
    return user


def get_user_by_email(db: Session, email: str):
    return db.query(models.User).filter(models.User.email == email).first()
