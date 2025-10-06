import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from datetime import date, timedelta
from decimal import Decimal

from app.main import app
from app.db import Base, get_db
from app.models import Invoice, Payment, Company, Client, Project

# Create test database
SQLALCHEMY_TEST_DATABASE_URL = "sqlite:///./test.db"
engine = create_engine(SQLALCHEMY_TEST_DATABASE_URL, connect_args={"check_same_thread": False})
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


def override_get_db():
    try:
        db = TestingSessionLocal()
        yield db
    finally:
        db.close()


app.dependency_overrides[get_db] = override_get_db


@pytest.fixture(scope="function")
def test_db():
    """Create and drop tables for each test"""
    Base.metadata.create_all(bind=engine)
    yield
    Base.metadata.drop_all(bind=engine)


@pytest.fixture
def client(test_db):
    """Create test client"""
    return TestClient(app)


@pytest.fixture
def sample_data(test_db):
    """Create sample data for testing"""
    db = TestingSessionLocal()
    
    # Create company
    company = Company(id=1, name="Test Company", address="123 Test St")
    db.add(company)
    
    # Create client
    client = Client(id=1, name="Test Client", company_id=1)
    db.add(client)
    
    # Create project
    project = Project(id=1, name="Test Project", company_id=1, client_id=1)
    db.add(project)
    
    # Create invoices with different dates
    today = date.today()
    invoices = [
        Invoice(
            id=1,
            invoice_number="INV-001",
            client_id=1,
            project_id=1,
            issue_date=today - timedelta(days=10),
            status="paid",
            currency="USD",
            subtotal=Decimal("1000.00"),
            tax=Decimal("100.00"),
            total=Decimal("1100.00")
        ),
        Invoice(
            id=2,
            invoice_number="INV-002",
            client_id=1,
            project_id=1,
            issue_date=today - timedelta(days=5),
            status="sent",
            currency="USD",
            subtotal=Decimal("2000.00"),
            tax=Decimal("200.00"),
            total=Decimal("2200.00")
        ),
        Invoice(
            id=3,
            invoice_number="INV-003",
            client_id=1,
            project_id=1,
            issue_date=today,
            status="draft",
            currency="USD",
            subtotal=Decimal("3000.00"),
            tax=Decimal("300.00"),
            total=Decimal("3300.00")
        ),
    ]
    for inv in invoices:
        db.add(inv)
    
    # Create payments
    payments = [
        Payment(
            id=1,
            payment_number="PAY-001",
            invoice_id=1,
            project_id=1,
            client_id=1,
            company_id=1,
            amount=Decimal("1100.00"),
            payment_date=today - timedelta(days=8),
            method="bank_transfer"
        ),
        Payment(
            id=2,
            payment_number="PAY-002",
            invoice_id=2,
            project_id=1,
            client_id=1,
            company_id=1,
            amount=Decimal("1000.00"),
            payment_date=today - timedelta(days=3),
            method="cash"
        ),
    ]
    for pay in payments:
        db.add(pay)
    
    db.commit()
    db.close()


def test_dashboard_summary_no_filters(client, sample_data):
    """Test dashboard summary endpoint without filters"""
    response = client.get("/dashboard/summary")
    assert response.status_code == 200
    
    data = response.json()
    assert "metrics" in data
    assert "recent_invoices" in data
    assert "recent_payments" in data
    
    metrics = data["metrics"]
    assert metrics["total_invoices"] == 3
    assert metrics["total_amount"] == 6600.0
    assert metrics["total_paid"] == 2100.0
    assert metrics["outstanding"] == 4500.0
    
    assert len(data["recent_invoices"]) == 3
    assert len(data["recent_payments"]) == 2


def test_dashboard_summary_with_date_filter(client, sample_data):
    """Test dashboard summary with date range filter"""
    today = date.today()
    from_date = (today - timedelta(days=7)).isoformat()
    
    response = client.get(f"/dashboard/summary?from_date={from_date}")
    assert response.status_code == 200
    
    data = response.json()
    metrics = data["metrics"]
    
    # Should only include invoices from last 7 days (2 invoices)
    assert metrics["total_invoices"] == 2
    assert metrics["total_amount"] == 5500.0  # INV-002 + INV-003


def test_dashboard_summary_with_company_filter(client, sample_data):
    """Test dashboard summary with company filter"""
    response = client.get("/dashboard/summary?company_id=1")
    assert response.status_code == 200
    
    data = response.json()
    # Should return payments filtered by company
    assert len(data["recent_payments"]) == 2


def test_dashboard_summary_with_client_filter(client, sample_data):
    """Test dashboard summary with client filter"""
    response = client.get("/dashboard/summary?client_id=1")
    assert response.status_code == 200
    
    data = response.json()
    assert data["metrics"]["total_invoices"] == 3


def test_dashboard_summary_with_project_filter(client, sample_data):
    """Test dashboard summary with project filter"""
    response = client.get("/dashboard/summary?project_id=1")
    assert response.status_code == 200
    
    data = response.json()
    assert data["metrics"]["total_invoices"] == 3


def test_dashboard_summary_with_combined_filters(client, sample_data):
    """Test dashboard summary with multiple filters"""
    today = date.today()
    from_date = (today - timedelta(days=6)).isoformat()
    to_date = today.isoformat()
    
    response = client.get(
        f"/dashboard/summary?from_date={from_date}&to_date={to_date}&client_id=1&project_id=1"
    )
    assert response.status_code == 200
    
    data = response.json()
    metrics = data["metrics"]
    assert metrics["total_invoices"] == 2


def test_dashboard_export_csv(client, sample_data):
    """Test CSV export functionality"""
    response = client.get("/dashboard/export?format=csv")
    assert response.status_code == 200
    assert response.headers["content-type"] == "text/csv; charset=utf-8"
    assert "attachment" in response.headers["content-disposition"]
    assert "dashboard_export" in response.headers["content-disposition"]
    
    # Check CSV content
    content = response.text
    assert "INVOICES" in content
    assert "PAYMENTS" in content
    assert "INV-001" in content
    assert "PAY-001" in content


def test_dashboard_export_json(client, sample_data):
    """Test JSON export functionality"""
    response = client.get("/dashboard/export?format=json")
    assert response.status_code == 200
    assert response.headers["content-type"] == "application/json"
    
    data = response.json()
    assert "exported_at" in data
    assert "filters" in data
    assert "invoices" in data
    assert "payments" in data
    assert len(data["invoices"]) == 3
    assert len(data["payments"]) == 2


def test_dashboard_export_with_filters(client, sample_data):
    """Test export with filters"""
    today = date.today()
    from_date = (today - timedelta(days=7)).isoformat()
    
    response = client.get(f"/dashboard/export?format=json&from_date={from_date}")
    assert response.status_code == 200
    
    data = response.json()
    # Should only include recent invoices
    assert len(data["invoices"]) == 2
    assert data["filters"]["from_date"] == from_date


def test_dashboard_export_invalid_format(client, sample_data):
    """Test export with invalid format"""
    response = client.get("/dashboard/export?format=xml")
    assert response.status_code == 422  # Validation error


def test_dashboard_summary_empty_database(client, test_db):
    """Test dashboard with no data"""
    response = client.get("/dashboard/summary")
    assert response.status_code == 200
    
    data = response.json()
    assert data["metrics"]["total_invoices"] == 0
    assert data["metrics"]["total_amount"] == 0.0
    assert data["metrics"]["total_paid"] == 0.0
    assert data["metrics"]["outstanding"] == 0.0
    assert len(data["recent_invoices"]) == 0
    assert len(data["recent_payments"]) == 0

