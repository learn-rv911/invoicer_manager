# Invoicer - Invoice Management System

A Flutter-based invoice management application for businesses to manage invoicing, payments, clients, companies, and projects.

## Tech Stack

### Frontend
- **Framework**: Flutter (Dart 3.7.2+)
- **State Management**: Riverpod (Provider pattern)
- **Navigation**: GoRouter (declarative routing)
- **HTTP Client**: Dio
- **UI**: Material Design 3
- **Internationalization**: Intl package

### Backend
- **Database**: MySQL
- **API**: RESTful API (configured for local development)

## Database Schema (MySQL)

### Tables

#### Users
```sql
users (
  id INT PRIMARY KEY,
  email VARCHAR(255),
  password VARCHAR(255),
  created_at TIMESTAMP
)
```

#### Companies
```sql
companies (
  id INT PRIMARY KEY,
  name VARCHAR(255),
  address TEXT,
  gst_percent INT,
  created_by INT,
  created_at TIMESTAMP
)
```

#### Clients
```sql
clients (
  id INT PRIMARY KEY,
  name VARCHAR(255),
  address TEXT,
  gst_percent INT,
  created_by INT,
  company_id INT,
  created_at TIMESTAMP
)
```

#### Projects
```sql
projects (
  id INT PRIMARY KEY,
  name VARCHAR(255),
  address TEXT,
  status VARCHAR(50),
  notes TEXT,
  created_by INT,
  company_id INT,
  client_id INT,
  created_at TIMESTAMP
)
```

#### Invoices
```sql
invoices (
  id INT PRIMARY KEY,
  invoice_number VARCHAR(100),
  client_id INT,
  project_id INT,
  issue_date DATE,
  status VARCHAR(50),
  currency VARCHAR(10),
  subtotal DECIMAL(10,2),
  tax DECIMAL(10,2),
  total DECIMAL(10,2),
  notes TEXT,
  created_at TIMESTAMP
)
```

#### Payments
```sql
payments (
  id INT PRIMARY KEY,
  payment_number VARCHAR(100),
  invoice_id INT,
  project_id INT,
  client_id INT,
  company_id INT,
  amount DECIMAL(10,2),
  payment_date DATE,
  method VARCHAR(50),
  bank VARCHAR(100),
  transaction_no VARCHAR(100),
  notes TEXT,
  created_at TIMESTAMP
)
```

## Architecture

### Clean Architecture Pattern
```
lib/
├── application/     # State Management (Riverpod Providers)
├── data/           # Data Layer (Models, Repositories, Services)
├── presentation/   # UI Layer (Screens, Widgets, Routing)
├── core/          # Configuration & Shared Utilities
└── utils/         # Helper Functions
```

### Data Flow
```
UI Layer → Application Layer → Data Layer → Backend API
   ↓              ↓              ↓
Screens      State Management   HTTP Calls
Widgets      Business Logic     Data Models
Routing      Controllers        Repositories
```

### State Management (Riverpod)
- **Providers**: Dependency injection and state management
- **Controllers**: Business logic and state updates
- **State Classes**: Immutable state with copyWith methods

### Key Features
- **Authentication**: Login/logout with proper error handling
- **Dashboard**: Financial overview with KPIs and recent activity
- **Multi-tenant**: Company-based data organization
- **Filtering**: Time-based and entity-based data filtering
- **Responsive Design**: Works on mobile and desktop
- **Material Design 3**: Modern UI with proper theming
