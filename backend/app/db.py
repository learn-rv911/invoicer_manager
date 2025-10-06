from sqlalchemy import create_engine
from sqlalchemy.engine import URL
from sqlalchemy.orm import sessionmaker, DeclarativeBase

from .core.config import settings

# Create database URL with proper handling of special characters in password
DATABASE_URL = URL.create(
    drivername=settings.DB_DRIVERNAME,
    username=settings.DB_USERNAME,
    password=settings.DB_PASSWORD,
    host=settings.DB_HOST,
    port=settings.DB_PORT,
    database=settings.DB_DATABASE
)

engine = create_engine(DATABASE_URL, pool_pre_ping=True)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

class Base(DeclarativeBase):
    pass

# Dependency
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

