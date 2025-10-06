# Quick Setup Guide

## Prerequisites
- Python 3.10 or higher
- MySQL Server 8.0+
- pip (Python package manager)

## Quick Start (5 minutes)

### Step 1: Create MySQL Database
```sql
CREATE DATABASE invoicer CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

### Step 2: Configure Environment
```bash
cp .env.example .env
```

Edit `.env` and update your MySQL credentials:
```env
DB_USERNAME=root
DB_PASSWORD=YOUR_PASSWORD
DB_HOST=localhost
DB_PORT=3306
DB_DATABASE=invoicer
```

**Bonus:** This approach automatically handles special characters in passwords (like `@`, `#`, `%`) - no URL encoding needed!

### Step 3: Setup Python Environment
```bash
# Create and activate virtual environment
python -m venv .venv
source .venv/bin/activate  # macOS/Linux
# OR
.venv\Scripts\activate     # Windows

# Install dependencies
pip install -r requirements.txt
```

### Step 4: Create First User (in MySQL)
```sql
USE invoicer;
INSERT INTO users (email, password, created_at) 
VALUES ('rahul@gmail.com', 'test@123', NOW());
```

### Step 5: Run the Server
```bash
bash run.sh
# OR
uvicorn app.main:app --reload
```

### Step 6: Test the API
Open your browser:
- API Docs: http://127.0.0.1:8000/docs
- Root: http://127.0.0.1:8000/

## Quick Test Commands

### 1. Test Root
```bash
curl http://127.0.0.1:8000/
```

### 2. Login
```bash
curl -X POST http://127.0.0.1:8000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"rahul@gmail.com","password":"test@123"}'
```

### 3. Create a Company
```bash
curl -X POST http://127.0.0.1:8000/companies/ \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Acme Corporation",
    "address": "123 Business St, Tech City",
    "gst_percent": 18,
    "created_by": 1
  }'
```

### 4. List Companies
```bash
curl http://127.0.0.1:8000/companies/
```

### 5. Create a Client
```bash
curl -X POST http://127.0.0.1:8000/clients/ \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Client ABC",
    "address": "456 Client Ave",
    "gst_percent": 18,
    "company_id": 1,
    "created_by": 1
  }'
```

### 6. Create a Project
```bash
curl -X POST http://127.0.0.1:8000/projects/ \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Website Redesign",
    "address": "Remote",
    "status": "active",
    "notes": "Q4 2024 project",
    "company_id": 1,
    "client_id": 1,
    "created_by": 1
  }'
```

### 7. Create an Invoice
```bash
curl -X POST http://127.0.0.1:8000/invoices/ \
  -H "Content-Type: application/json" \
  -d '{
    "invoice_number": "INV-2024-001",
    "client_id": 1,
    "project_id": 1,
    "issue_date": "2024-10-06",
    "due_date": "2024-11-06",
    "status": "pending",
    "currency": "INR",
    "subtotal": 100000.00,
    "tax": 18000.00,
    "total": 118000.00,
    "notes": "First milestone payment"
  }'
```

### 8. Create a Payment
```bash
curl -X POST http://127.0.0.1:8000/payments/ \
  -H "Content-Type: application/json" \
  -d '{
    "payment_number": "PAY-2024-001",
    "invoice_id": 1,
    "project_id": 1,
    "client_id": 1,
    "company_id": 1,
    "amount": 118000.00,
    "payment_date": "2024-10-06",
    "method": "bank_transfer",
    "bank": "HDFC Bank",
    "transaction_no": "TXN123456789",
    "notes": "Full payment received"
  }'
```

### 9. Dashboard Summary
```bash
curl http://127.0.0.1:8000/dashboard/summary
```

## Common Issues

### Issue: "Can't connect to MySQL server"
- Ensure MySQL is running: `sudo systemctl start mysql` (Linux) or start MySQL from System Preferences (macOS)
- Check your DATABASE_URL credentials in `.env`

### Issue: "Module not found"
- Make sure virtual environment is activated
- Reinstall dependencies: `pip install -r requirements.txt`

### Issue: "Table doesn't exist"
- The tables are auto-created on first run
- If issues persist, manually run the SQL schema or restart the server

## Project Structure Summary

```
app/
├── core/config.py      # Settings & environment variables
├── db.py               # Database connection & session
├── models.py           # SQLAlchemy ORM models
├── schemas.py          # Pydantic validation schemas
├── crud/               # Database operations
│   ├── users.py
│   ├── companies.py
│   ├── clients.py
│   ├── projects.py
│   ├── invoices.py
│   └── payments.py
├── routers/            # API endpoints
│   ├── auth.py
│   ├── companies.py
│   ├── clients.py
│   ├── projects.py
│   ├── invoices.py
│   ├── payments.py
│   └── dashboard.py
└── main.py             # FastAPI app & router registration
```

## Next Steps

1. **Add Authentication**: Implement JWT tokens for secure API access
2. **Password Hashing**: Use bcrypt or passlib for password security
3. **Validation**: Add more robust input validation
4. **Error Handling**: Implement global exception handlers
5. **Logging**: Add structured logging
6. **Testing**: Write unit and integration tests
7. **Migrations**: Use Alembic for database version control
8. **Deployment**: Set up Docker, CI/CD, and production environment

## Support

For issues or questions, please refer to:
- FastAPI Documentation: https://fastapi.tiangolo.com/
- SQLAlchemy Documentation: https://docs.sqlalchemy.org/

