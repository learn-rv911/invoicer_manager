from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from .core.config import settings
from .db import engine, Base

from .routers import auth, companies, clients, projects, invoices, payments, dashboard

app = FastAPI(title=settings.APP_NAME)

# CORS
origins = [o.strip() for o in settings.BACKEND_CORS_ORIGINS.split(",")] if settings.BACKEND_CORS_ORIGINS else ["*"]
app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Ensure metadata is in sync (does NOT create tables if they already exist in MySQL)
Base.metadata.create_all(bind=engine)


@app.get("/")
def root():
    return {"message": f"{settings.APP_NAME} running!"}


# Routers
app.include_router(auth.router)
app.include_router(companies.router)
app.include_router(clients.router)
app.include_router(projects.router)
app.include_router(invoices.router)
app.include_router(payments.router)
app.include_router(dashboard.router)
