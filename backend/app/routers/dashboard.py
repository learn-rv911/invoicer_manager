from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from sqlalchemy import desc
from ..db import get_db
from .. import models
from ..crud.invoices import totals_for_dashboard

router = APIRouter(prefix="/dashboard", tags=["Dashboard"])


@router.get("/summary")
def summary(db: Session = Depends(get_db)):
    total_amount, total_paid, outstanding = totals_for_dashboard(db)

    recent_invoices = db.query(models.Invoice).order_by(desc(models.Invoice.issue_date)).limit(3).all()
    recent_payments = db.query(models.Payment).order_by(desc(models.Payment.payment_date)).limit(3).all()

    invoices = [{
        "id": x.id,
        "invoice_number": x.invoice_number,
        "client_id": x.client_id,
        "project_id": x.project_id,
        "issue_date": x.issue_date.isoformat(),
        "due_date": x.due_date.isoformat() if x.due_date else None,
        "status": x.status,
        "currency": x.currency,
        "subtotal": float(x.subtotal),
        "tax": float(x.tax),
        "total": float(x.total),
        "notes": x.notes,
        "created_at": x.created_at.isoformat() if x.created_at else None,
    } for x in recent_invoices]

    payments = [{
        "id": p.id,
        "payment_number": p.payment_number,
        "invoice_id": p.invoice_id,
        "project_id": p.project_id,
        "client_id": p.client_id,
        "company_id": p.company_id,
        "amount": float(p.amount),
        "payment_date": p.payment_date.isoformat(),
        "method": p.method,
        "bank": p.bank,
        "transaction_no": p.transaction_no,
        "notes": p.notes,
        "created_at": p.created_at.isoformat() if p.created_at else None,
    } for p in recent_payments]

    return {
        "metrics": {
            "total_invoices": db.query(models.Invoice).count(),
            "total_amount": total_amount,
            "total_paid": total_paid,
            "outstanding": outstanding,
        },
        "recent_invoices": invoices,
        "recent_payments": payments,
    }
