from fastapi import APIRouter, Depends, Query
from fastapi.responses import StreamingResponse
from sqlalchemy.orm import Session
from sqlalchemy import desc, func, and_
from datetime import date, datetime, timedelta
from typing import Optional
import csv
import json
import io
from ..db import get_db
from .. import models
from ..crud.invoices import totals_for_dashboard

router = APIRouter(prefix="/dashboard", tags=["Dashboard"])


def apply_filters(query, model, from_date: Optional[date], to_date: Optional[date], 
                  company_id: Optional[int], client_id: Optional[int], project_id: Optional[int]):
    """Apply common filters to queries"""
    if from_date:
        date_field = model.issue_date if model == models.Invoice else model.payment_date
        query = query.filter(date_field >= from_date)
    if to_date:
        date_field = model.issue_date if model == models.Invoice else model.payment_date
        query = query.filter(date_field <= to_date)
    
    # For invoices, we need to join with projects to filter by company_id
    if model == models.Invoice:
        if company_id:
            query = query.join(models.Project, models.Invoice.project_id == models.Project.id)
            query = query.filter(models.Project.company_id == company_id)
        if client_id:
            query = query.filter(models.Invoice.client_id == client_id)
        if project_id:
            query = query.filter(models.Invoice.project_id == project_id)
    else:  # For payments
        if company_id:
            query = query.filter(model.company_id == company_id)
        if client_id:
            query = query.filter(model.client_id == client_id)
        if project_id:
            query = query.filter(model.project_id == project_id)
    
    return query


@router.get("/summary", summary="Get dashboard summary with optional filters")
def summary(
    db: Session = Depends(get_db),
    from_date: Optional[date] = Query(None, description="Filter from date (YYYY-MM-DD)"),
    to_date: Optional[date] = Query(None, description="Filter to date (YYYY-MM-DD)"),
    company_id: Optional[int] = Query(None, description="Filter by company ID"),
    client_id: Optional[int] = Query(None, description="Filter by client ID"),
    project_id: Optional[int] = Query(None, description="Filter by project ID"),
):
    """
    Get dashboard summary with optional filters.
    
    All filters are optional and can be combined:
    - **from_date**: Start date for filtering invoices/payments
    - **to_date**: End date for filtering invoices/payments
    - **company_id**: Filter by specific company
    - **client_id**: Filter by specific client
    - **project_id**: Filter by specific project
    
    Returns metrics, recent invoices, and recent payments.
    """
    # Build optimized queries with filters
    invoice_query = db.query(models.Invoice)
    payment_query = db.query(models.Payment)
    
    # Apply filters
    invoice_query = apply_filters(invoice_query, models.Invoice, from_date, to_date, company_id, client_id, project_id)
    payment_query = apply_filters(payment_query, models.Payment, from_date, to_date, company_id, client_id, project_id)
    
    # Optimized aggregation in single queries
    invoice_metrics = invoice_query.with_entities(
        func.count(models.Invoice.id).label('total_invoices'),
        func.coalesce(func.sum(models.Invoice.total), 0).label('total_amount')
    ).first()
    
    payment_total = payment_query.with_entities(
        func.coalesce(func.sum(models.Payment.amount), 0)
    ).scalar()
    
    total_invoices = invoice_metrics.total_invoices or 0
    total_amount = float(invoice_metrics.total_amount or 0)
    total_paid = float(payment_total or 0)
    outstanding = total_amount - total_paid
    
    # Get recent items (reuse filtered queries)
    recent_invoices = invoice_query.order_by(desc(models.Invoice.issue_date)).limit(3).all()
    recent_payments = payment_query.order_by(desc(models.Payment.payment_date)).limit(3).all()

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
            "total_invoices": total_invoices,
            "total_amount": total_amount,
            "total_paid": total_paid,
            "outstanding": outstanding,
        },
        "recent_invoices": invoices,
        "recent_payments": payments,
    }


@router.get("/export", summary="Export dashboard data as CSV or JSON")
def export_dashboard(
    format: str = Query("csv", regex="^(csv|json)$", description="Export format: csv or json"),
    db: Session = Depends(get_db),
    from_date: Optional[date] = Query(None, description="Filter from date (YYYY-MM-DD)"),
    to_date: Optional[date] = Query(None, description="Filter to date (YYYY-MM-DD)"),
    company_id: Optional[int] = Query(None, description="Filter by company ID"),
    client_id: Optional[int] = Query(None, description="Filter by client ID"),
    project_id: Optional[int] = Query(None, description="Filter by project ID"),
):
    """
    Export dashboard data with optional filters.
    
    - **format**: Either 'csv' or 'json'
    - All other filters work the same as /dashboard/summary
    
    Returns a downloadable file with filtered invoice and payment data.
    """
    # Build queries with filters
    invoice_query = db.query(models.Invoice)
    payment_query = db.query(models.Payment)
    
    invoice_query = apply_filters(invoice_query, models.Invoice, from_date, to_date, company_id, client_id, project_id)
    payment_query = apply_filters(payment_query, models.Payment, from_date, to_date, company_id, client_id, project_id)
    
    invoices = invoice_query.order_by(desc(models.Invoice.issue_date)).all()
    payments = payment_query.order_by(desc(models.Payment.payment_date)).all()
    
    if format == "csv":
        # Create CSV output
        output = io.StringIO()
        
        # Write invoices section
        output.write("INVOICES\n")
        invoice_writer = csv.writer(output)
        invoice_writer.writerow([
            "ID", "Invoice Number", "Client ID", "Project ID", "Issue Date", 
            "Due Date", "Status", "Currency", "Subtotal", "Tax", "Total", "Notes"
        ])
        for inv in invoices:
            invoice_writer.writerow([
                inv.id, inv.invoice_number, inv.client_id, inv.project_id,
                inv.issue_date.isoformat(), 
                inv.due_date.isoformat() if inv.due_date else "",
                inv.status, inv.currency, float(inv.subtotal), 
                float(inv.tax), float(inv.total), inv.notes or ""
            ])
        
        output.write("\n\nPAYMENTS\n")
        payment_writer = csv.writer(output)
        payment_writer.writerow([
            "ID", "Payment Number", "Invoice ID", "Project ID", "Client ID", 
            "Company ID", "Amount", "Payment Date", "Method", "Bank", 
            "Transaction No", "Notes"
        ])
        for pay in payments:
            payment_writer.writerow([
                pay.id, pay.payment_number, pay.invoice_id or "", pay.project_id,
                pay.client_id or "", pay.company_id or "", float(pay.amount),
                pay.payment_date.isoformat(), pay.method or "", pay.bank or "",
                pay.transaction_no or "", pay.notes or ""
            ])
        
        output.seek(0)
        return StreamingResponse(
            io.BytesIO(output.getvalue().encode('utf-8')),
            media_type="text/csv",
            headers={"Content-Disposition": f"attachment; filename=dashboard_export_{datetime.now().strftime('%Y%m%d_%H%M%S')}.csv"}
        )
    
    else:  # json
        data = {
            "exported_at": datetime.now().isoformat(),
            "filters": {
                "from_date": from_date.isoformat() if from_date else None,
                "to_date": to_date.isoformat() if to_date else None,
                "company_id": company_id,
                "client_id": client_id,
                "project_id": project_id,
            },
            "invoices": [{
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
            } for x in invoices],
            "payments": [{
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
            } for p in payments],
        }
        
        json_str = json.dumps(data, indent=2)
        return StreamingResponse(
            io.BytesIO(json_str.encode('utf-8')),
            media_type="application/json",
            headers={"Content-Disposition": f"attachment; filename=dashboard_export_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"}
        )
