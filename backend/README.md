# Invoicer API

A production-ready FastAPI + SQLAlchemy (MySQL) backend for invoice management system.

## Features

- **User Authentication**: Login system with user management
- **Companies Management**: Create and manage companies
- **Clients Management**: Track clients with company associations
- **Projects Management**: Manage projects for clients
- **Invoices**: Create and track invoices with status management
- **Payments**: Record and track payments against invoices
- **Dashboard**: Summary view with metrics and recent activities

## Tech Stack

- **FastAPI** 0.111.0 - Modern, fast web framework
- **SQLAlchemy** 2.0.32 - ORM for database operations
- **MySQL** - Database (via PyMySQL driver)
- **Pydantic** 2.8.2 - Data validation
- **Uvicorn** - ASGI server

## Project Structure

```
invoicer_api/
├─ app/
│  ├─ __init__.py
│  ├─ core/
│  │  └─ config.py          # Configuration settings
│  ├─ db.py                 # Database setup and session
│  ├─ models.py             # SQLAlchemy models
│  ├─ schemas.py            # Pydantic schemas
│  ├─ crud/                 # CRUD operations
│  │  ├─ users.py
│  │  ├─ companies.py
│  │  ├─ clients.py
│  │  ├─ projects.py
│  │  ├─ invoices.py
│  │  └─ payments.py
│  ├─ routers/              # API endpoints
│  │  ├─ auth.py
│  │  ├─ companies.py
│  │  ├─ clients.py
│  │  ├─ projects.py
│  │  ├─ invoices.py
│  │  ├─ payments.py
│  │  └─ dashboard.py
│  └─ main.py               # FastAPI application
├─ .env.example             # Environment variables template
├─ requirements.txt         # Python dependencies
└─ run.sh                   # Helper script to run the server
```

## Installation

### 1. Create `.env` file

Create a `.env` file in the root directory with the following content:

```env
# Application Settings
APP_NAME=Invoicer API
BACKEND_CORS_ORIGINS=*

# Database Connection (supports special characters in password!)
DB_DRIVERNAME=mysql+pymysql
DB_USERNAME=root
DB_PASSWORD=your_password
DB_HOST=localhost
DB_PORT=3306
DB_DATABASE=invoicer
```

**Note:** This approach uses SQLAlchemy's `URL.create()` method which properly handles special characters in passwords (like `@`, `#`, `%`) without URL encoding!

### 2. Create MySQL Database

```sql
CREATE DATABASE invoicer CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

### 3. Setup Python Environment

```bash
# Create virtual environment
python -m venv .venv

# Activate virtual environment
# On macOS/Linux:
source .venv/bin/activate
# On Windows:
# .venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt
```

### 4. Run the Application

```bash
# Using the helper script:
bash run.sh

# Or directly:
uvicorn app.main:app --reload
```

The API will be available at `http://127.0.0.1:8000`

## API Documentation

Once the server is running, visit:
- **Swagger UI**: http://127.0.0.1:8000/docs
- **ReDoc**: http://127.0.0.1:8000/redoc

## API Endpoints

### Auth
- `POST /auth/login` - User login

### Companies
- `GET /companies/` - List companies (with search and pagination)
- `POST /companies/` - Create a new company

### Clients
- `GET /clients/` - List clients (filterable by company)
- `POST /clients/` - Create a new client

### Projects
- `GET /projects/` - List projects (filterable by company/client)
- `POST /projects/` - Create a new project

### Invoices
- `GET /invoices/` - List invoices (filterable by client/project/status)
- `POST /invoices/` - Create a new invoice

### Payments
- `GET /payments/` - List payments (filterable by company/client/project)
- `POST /payments/` - Create a new payment

### Dashboard
- `GET /dashboard/summary` - Get dashboard metrics and recent activities

## Testing the API

### 1. Root Endpoint
```bash
curl http://127.0.0.1:8000/
```

### 2. Login (First create a user in database)
```bash
curl -X POST http://127.0.0.1:8000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"rahul@gmail.com","password":"test@123"}'
```

### 3. Create Company
```bash
curl -X POST http://127.0.0.1:8000/companies/ \
  -H "Content-Type: application/json" \
  -d '{"name":"Tech Corp","address":"123 Main St","gst_percent":18}'
```

### 4. Dashboard Summary
```bash
curl http://127.0.0.1:8000/dashboard/summary
```

## Database Schema

The application automatically creates the following tables:
- `users` - User accounts
- `companies` - Company information
- `clients` - Client records
- `projects` - Project management
- `invoices` - Invoice tracking
- `payments` - Payment records

## Development

### Database Migrations
The application uses `Base.metadata.create_all()` which automatically creates tables on startup. For production, consider using Alembic for proper migrations.

### Adding New Endpoints
1. Create CRUD functions in `app/crud/`
2. Add schemas in `app/schemas.py`
3. Create router in `app/routers/`
4. Register router in `app/main.py`

## Production Notes

- Use proper password hashing (e.g., bcrypt, argon2) instead of plain text
- Implement JWT token-based authentication
- Add proper logging
- Use Alembic for database migrations
- Set up proper CORS origins (not "*")
- Add rate limiting
- Implement input validation and sanitization
- Add comprehensive error handling

## License

This project is provided as-is for educational and development purposes.

