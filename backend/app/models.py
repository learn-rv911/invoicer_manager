from sqlalchemy import Column, BigInteger, Integer, String, Text, Date, DateTime, ForeignKey, Numeric
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship, Mapped, mapped_column
from datetime import datetime, date
from decimal import Decimal

from .db import Base


# USERS
class User(Base):
    __tablename__ = "users"
    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    email: Mapped[str] = mapped_column(String(255), unique=True, nullable=False)
    password: Mapped[str] = mapped_column(String(255), nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, server_default=func.current_timestamp())


# COMPANIES
class Company(Base):
    __tablename__ = "companies"
    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    name: Mapped[str] = mapped_column(String(255), nullable=False)
    address: Mapped[str | None] = mapped_column(Text)
    gst_percent: Mapped[int | None] = mapped_column(Integer)
    created_by: Mapped[int | None] = mapped_column(BigInteger, ForeignKey("users.id"))
    created_at: Mapped[datetime] = mapped_column(DateTime, server_default=func.current_timestamp())


# CLIENTS
class Client(Base):
    __tablename__ = "clients"
    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    name: Mapped[str] = mapped_column(String(255), nullable=False)
    address: Mapped[str | None] = mapped_column(Text)
    gst_percent: Mapped[int | None] = mapped_column(Integer)
    created_by: Mapped[int | None] = mapped_column(BigInteger, ForeignKey("users.id"))
    company_id: Mapped[int] = mapped_column(BigInteger, ForeignKey("companies.id"), nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, server_default=func.current_timestamp())


# PROJECTS
class Project(Base):
    __tablename__ = "projects"
    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    name: Mapped[str] = mapped_column(String(255), nullable=False)
    address: Mapped[str | None] = mapped_column(Text)
    status: Mapped[str | None] = mapped_column(String(50))
    notes: Mapped[str | None] = mapped_column(Text)
    created_by: Mapped[int | None] = mapped_column(BigInteger, ForeignKey("users.id"))
    company_id: Mapped[int] = mapped_column(BigInteger, ForeignKey("companies.id"), nullable=False)
    client_id: Mapped[int] = mapped_column(BigInteger, ForeignKey("clients.id"), nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, server_default=func.current_timestamp())


# INVOICES
class Invoice(Base):
    __tablename__ = "invoices"
    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    invoice_number: Mapped[str] = mapped_column(String(32), unique=True, nullable=False)
    client_id: Mapped[int] = mapped_column(BigInteger, ForeignKey("clients.id"), nullable=False)
    project_id: Mapped[int] = mapped_column(BigInteger, ForeignKey("projects.id"), nullable=False)
    issue_date: Mapped[date] = mapped_column(Date, nullable=False)
    due_date: Mapped[date | None] = mapped_column(Date)
    status: Mapped[str] = mapped_column(String(20), nullable=False)
    currency: Mapped[str] = mapped_column(String(10), nullable=False)
    subtotal: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False)
    tax: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False)
    total: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False)
    notes: Mapped[str | None] = mapped_column(Text)
    created_at: Mapped[datetime] = mapped_column(DateTime, server_default=func.current_timestamp())


# PAYMENTS
class Payment(Base):
    __tablename__ = "payments"
    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    payment_number: Mapped[str] = mapped_column(String(32), unique=True, nullable=False)
    invoice_id: Mapped[int | None] = mapped_column(BigInteger, ForeignKey("invoices.id"))
    project_id: Mapped[int] = mapped_column(BigInteger, ForeignKey("projects.id"), nullable=False)
    client_id: Mapped[int | None] = mapped_column(BigInteger, ForeignKey("clients.id"))
    company_id: Mapped[int | None] = mapped_column(BigInteger, ForeignKey("companies.id"))
    amount: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False)
    payment_date: Mapped[date] = mapped_column(Date, nullable=False)
    method: Mapped[str | None] = mapped_column(String(20))
    bank: Mapped[str | None] = mapped_column(String(100))
    transaction_no: Mapped[str | None] = mapped_column(String(100))
    notes: Mapped[str | None] = mapped_column(Text)
    created_at: Mapped[datetime] = mapped_column(DateTime, server_default=func.current_timestamp())
