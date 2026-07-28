# Database Architecture & Schema - SafeCore HSE Platform

This document presents the complete relational database architecture for **SafeCore HSE Platform**, engineered to deploy on **PostgreSQL 16** utilizing **Prisma / TypeORM** migrations, supported by **Redis 7** for operational queues and high-velocity ephemeral real-time state.

---

## 1. Multi-Tenant Architectural Strategy (Shared DB / Isolated Rows)
To maximize SaaS cloud compute efficiency while assuring enterprise-grade data segregation:
- Every table strictly embeds a non-nullable `tenant_id` column as a composite primary or indexing key.
- **Automated Query Interception:** Application repositories ingest an automated query context wrapping all SQL operations with mandatory `AND tenant_id = :current_tenant_id` evaluations.
- **Row-Level Security (RLS) Readiness:** PostgreSQL RLS policies can be activated per tenant domain:
```sql
ALTER TABLE safety_assets ENABLE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation_policy ON safety_assets
    USING (tenant_id = current_setting('app.current_tenant_id', true));
```

---

## 2. Comprehensive Entity Descriptions & DDL Specifications

### 2.1 Tenants (White-Label Organizations)
```sql
CREATE TABLE tenants (
    id VARCHAR(36) PRIMARY KEY, -- UUIDv4
    name VARCHAR(255) NOT NULL,
    subdomain VARCHAR(100) UNIQUE NOT NULL,
    logo_url VARCHAR(512),
    primary_color VARCHAR(16) DEFAULT '#1A56DB',
    secondary_color VARCHAR(16) DEFAULT '#0E317A',
    accent_color VARCHAR(16) DEFAULT '#F05252',
    font_family VARCHAR(50) DEFAULT 'IBM Plex Sans Arabic',
    is_rtl BOOLEAN DEFAULT true,
    branches JSONB DEFAULT '[]', -- Array of branch locations
    departments JSONB DEFAULT '[]',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_tenants_subdomain ON tenants(subdomain);
```

### 2.2 Users (RBAC: Admin & Member)
```sql
CREATE TABLE users (
    id VARCHAR(36) PRIMARY KEY,
    tenant_id VARCHAR(36) NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    email VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(150) NOT NULL,
    role VARCHAR(20) NOT NULL CHECK (role IN ('ADMIN', 'MEMBER')),
    avatar_url VARCHAR(512),
    department VARCHAR(100),
    branch VARCHAR(100),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_tenant_email UNIQUE(tenant_id, email)
);
CREATE INDEX idx_users_tenant_role ON users(tenant_id, role);
```

### 2.3 Facility Layouts (Interactive Blueprints)
```sql
CREATE TABLE facility_layouts (
    id VARCHAR(36) PRIMARY KEY,
    tenant_id VARCHAR(36) NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    branch_name VARCHAR(150),
    file_url VARCHAR(512) NOT NULL,
    file_type VARCHAR(20) NOT NULL CHECK (file_type IN ('PDF', 'PNG', 'JPG', 'DWG', 'SVG')),
    width_meters DOUBLE PRECISION NOT NULL DEFAULT 100.0,
    height_meters DOUBLE PRECISION NOT NULL DEFAULT 100.0,
    canvas_resolution_x INT DEFAULT 3000,
    canvas_resolution_y INT DEFAULT 3000,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_layouts_tenant ON facility_layouts(tenant_id);
```

### 2.4 Digital Safety Assets (QR/Barcode Twins)
```sql
CREATE TABLE safety_assets (
    id VARCHAR(36) PRIMARY KEY,
    tenant_id VARCHAR(36) NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    layout_id VARCHAR(36) REFERENCES facility_layouts(id) ON DELETE SET NULL,
    layer_type VARCHAR(50) NOT NULL CHECK (layer_type IN (
        'EXTINGUISHER', 'EMERGENCY_EXIT', 'FIRST_AID', 'ALARM', 
        'ELECTRICAL', 'HAZARD_ZONE', 'SAFETY_EQUIPMENT', 'CAMERA'
    )),
    asset_number VARCHAR(100) NOT NULL, -- Custom asset code (e.g. EXT-001)
    name VARCHAR(255) NOT NULL,
    qr_code VARCHAR(255) UNIQUE NOT NULL,
    barcode VARCHAR(255),
    status VARCHAR(50) NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'MAINTENANCE_REQUIRED', 'EXPIRED', 'DECOMMISSIONED')),
    coord_x DOUBLE PRECISION,
    coord_y DOUBLE PRECISION,
    manufacturer VARCHAR(150),
    installation_date DATE,
    warranty_expiry DATE,
    last_inspection_date TIMESTAMP WITH TIME ZONE,
    next_inspection_date TIMESTAMP WITH TIME ZONE,
    history_log JSONB DEFAULT '[]',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_tenant_asset_num UNIQUE(tenant_id, asset_number)
);
CREATE INDEX idx_assets_tenant_layer ON safety_assets(tenant_id, layer_type, status);
CREATE INDEX idx_assets_qr_code ON safety_assets(qr_code);
```

### 2.5 Inspection Form Schemas (Form Builder)
```sql
CREATE TABLE inspection_forms (
    id VARCHAR(36) PRIMARY KEY,
    tenant_id VARCHAR(36) NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    target_layer VARCHAR(50), -- Links form to Extinguishers, First Aid, etc.
    schedule_frequency VARCHAR(30) NOT NULL CHECK (schedule_frequency IN (
        'DAILY', 'WEEKLY', 'MONTHLY', 'QUARTERLY', 'BIANNUAL', 'ANNUAL', 'ON_DEMAND'
    )),
    form_schema JSONB NOT NULL, -- Array of input element specifications
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_forms_tenant_sched ON inspection_forms(tenant_id, schedule_frequency);
```

### 2.6 Executed Inspection Records
```sql
CREATE TABLE inspection_records (
    id VARCHAR(36) PRIMARY KEY,
    tenant_id VARCHAR(36) NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    form_id VARCHAR(36) NOT NULL REFERENCES inspection_forms(id),
    asset_id VARCHAR(36) REFERENCES safety_assets(id) ON DELETE SET NULL,
    inspector_id VARCHAR(36) NOT NULL REFERENCES users(id),
    status VARCHAR(30) NOT NULL DEFAULT 'COMPLETED' CHECK (status IN ('COMPLETED', 'FAILED_WITH_REMARKS', 'DRAFT_OFFLINE')),
    answers JSONB NOT NULL,
    signature_url VARCHAR(512),
    gps_latitude DOUBLE PRECISION,
    gps_longitude DOUBLE PRECISION,
    executed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    synced_from_offline BOOLEAN DEFAULT false
);
CREATE INDEX idx_inspections_tenant_asset ON inspection_records(tenant_id, asset_id);
```

### 2.7 Incidents & Emergency Center
```sql
CREATE TABLE incidents (
    id VARCHAR(36) PRIMARY KEY,
    tenant_id VARCHAR(36) NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    emergency_type VARCHAR(50) NOT NULL CHECK (emergency_type IN (
        'FIRE', 'INJURY', 'GAS_LEAK', 'ELECTRICAL_SHORT', 'HAZMAT', 'EVACUATION'
    )),
    reported_by_id VARCHAR(36) REFERENCES users(id),
    location_text VARCHAR(255) NOT NULL,
    layout_id VARCHAR(36) REFERENCES facility_layouts(id),
    coord_x DOUBLE PRECISION,
    coord_y DOUBLE PRECISION,
    severity VARCHAR(20) DEFAULT 'CRITICAL',
    status VARCHAR(30) DEFAULT 'ACTIVE_ALARM' CHECK (status IN ('ACTIVE_ALARM', 'UNDER_INVESTIGATION', 'RESOLVED', 'CLOSED')),
    media_urls JSONB DEFAULT '[]', -- Audio, Video, Photos uploaded from site
    corrective_actions TEXT,
    reported_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP WITH TIME ZONE
);
CREATE INDEX idx_incidents_tenant_status ON incidents(tenant_id, status, reported_at);
```

### 2.8 Tasks & Calendar
```sql
CREATE TABLE tasks (
    id VARCHAR(36) PRIMARY KEY,
    tenant_id VARCHAR(36) NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    assigned_to_id VARCHAR(36) NOT NULL REFERENCES users(id),
    created_by_id VARCHAR(36) NOT NULL REFERENCES users(id),
    priority VARCHAR(20) DEFAULT 'NORMAL' CHECK (priority IN ('LOW', 'NORMAL', 'HIGH', 'URGENT')),
    status VARCHAR(30) DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'IN_PROGRESS', 'COMPLETED', 'OVERDUE')),
    progress_percentage INT DEFAULT 0 CHECK (progress_percentage BETWEEN 0 AND 100),
    due_date TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_tasks_tenant_user_due ON tasks(tenant_id, assigned_to_id, due_date, status);
```

### 2.9 Immutable Audit Logs (Append-Only Compliance)
```sql
CREATE TABLE audit_logs (
    id VARCHAR(36) PRIMARY KEY,
    tenant_id VARCHAR(36) NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    actor_id VARCHAR(36) REFERENCES users(id),
    action_type VARCHAR(100) NOT NULL, -- e.g. ASSET_CREATE, INCIDENT_DISPATCH, ROLE_CHANGE
    target_entity VARCHAR(100) NOT NULL, -- e.g. SAFETY_ASSET, USER, LAYOUT
    target_id VARCHAR(36) NOT NULL,
    old_values JSONB,
    new_values JSONB,
    ip_address VARCHAR(50),
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_audit_tenant_time ON audit_logs(tenant_id, timestamp DESC);

-- SECURITY HARDENING: Revoke Modification Permissions at SQL level
-- (In production migrations, execute under administrative credentials)
-- REVOKE UPDATE, DELETE ON audit_logs FROM app_database_user;
```
