from pydantic import BaseModel
from dotenv import load_dotenv
import os

load_dotenv()


class Settings(BaseModel):
    APP_NAME: str = os.getenv("APP_NAME", "Invoicer API")
    
    # Database connection parameters
    DB_DRIVERNAME: str = os.getenv("DB_DRIVERNAME", "mysql+pymysql")
    DB_USERNAME: str = os.getenv("DB_USERNAME", "root")
    DB_PASSWORD: str = os.getenv("DB_PASSWORD", "")
    DB_HOST: str = os.getenv("DB_HOST", "localhost")
    DB_PORT: int = int(os.getenv("DB_PORT", "3306"))
    DB_DATABASE: str = os.getenv("DB_DATABASE", "invoicer")
    
    BACKEND_CORS_ORIGINS: str = os.getenv("BACKEND_CORS_ORIGINS", "*")


settings = Settings()
