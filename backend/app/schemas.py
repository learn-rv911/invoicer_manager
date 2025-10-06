from pydantic import BaseModel, ConfigDict
from datetime import date, datetime
from typing import Optional


# ---------- USERS ----------
class UserOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: int
    email: str
    created_at: datetime


class UserCreate(BaseModel):
    email: str
    password: str


# ---------- COMPANIES ----------
class CompanyBase(BaseModel):
    name: str
    address: Optional[str] = None
    gst_percent: Optional[int] = None
    created_by: Optional[int] = None


class CompanyCreate(CompanyBase):
    pass


class CompanyOut(CompanyBase):
    model_config = ConfigDict(from_attributes=True)
    id: int
    created_at: datetime


# ---------- CLIENTS ----------
class ClientBase(BaseModel):
    name: str
    address: Optional[str] = None
    gst_percent: Optional[int] = None
    created_by: Optional[int] = None
    company_id: int


class ClientCreate(ClientBase):
    pass


class ClientOut(ClientBase):
    model_config = ConfigDict(from_attributes=True)
    id: int
    created_at: datetime


# ---------- PROJECTS ----------
class ProjectBase(BaseModel):
    name: str
    address: Optional[str] = None
    status: Optional[str] = None
    notes: Optional[str] = None
    created_by: Optional[int] = None
    company_id: int
    client_id: int


class ProjectCreate(ProjectBase):
    pass


class ProjectOut(ProjectBase):
    model_config = ConfigDict(from_attributes=True)
    id: int
    created_at: datetime


# ---------- INVOICES ----------
class InvoiceBase(BaseModel):
    invoice_number: str
    client_id: int
    project_id: int
    issue_date: date
    due_date: Optional[date] = None
    status: str
    currency: str
    subtotal: float
    tax: float
    total: float
    notes: Optional[str] = None


class InvoiceCreate(InvoiceBase):
    pass


class InvoiceOut(InvoiceBase):
    model_config = ConfigDict(from_attributes=True)
    id: int
    created_at: datetime


# ---------- PAYMENTS ----------
class PaymentBase(BaseModel):
    payment_number: str
    invoice_id: Optional[int] = None
    project_id: int
    client_id: Optional[int] = None
    company_id: Optional[int] = None
    amount: float
    payment_date: date
    method: Optional[str] = None
    bank: Optional[str] = None
    transaction_no: Optional[str] = None
    notes: Optional[str] = None


class PaymentCreate(PaymentBase):
    pass


class PaymentOut(PaymentBase):
    model_config = ConfigDict(from_attributes=True)
    id: int
    created_at: datetime
