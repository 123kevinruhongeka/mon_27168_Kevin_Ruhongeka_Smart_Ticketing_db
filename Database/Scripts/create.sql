-- File: 01_create_tables.sql
SET SERVEROUTPUT ON
SET FEEDBACK ON

PROMPT Creating sequences...
CREATE SEQUENCE seq_users START WITH 1001 INCREMENT BY 1;
CREATE SEQUENCE seq_vendors START WITH 2001 INCREMENT BY 1;
CREATE SEQUENCE seq_services START WITH 3001 INCREMENT BY 1;
CREATE SEQUENCE seq_appointments START WITH 4001 INCREMENT BY 1;
CREATE SEQUENCE seq_tickets START WITH 5001 INCREMENT BY 1;
CREATE SEQUENCE seq_payments START WITH 6001 INCREMENT BY 1;
CREATE SEQUENCE seq_notifications START WITH 7001 INCREMENT BY 1;
CREATE SEQUENCE seq_audit_log START WITH 8001 INCREMENT BY 1;
CREATE SEQUENCE seq_holidays START WITH 9001 INCREMENT BY 1;

PROMPT Creating tables...

-- 1. USERS TABLE
CREATE TABLE users (
    user_id NUMBER(10) PRIMARY KEY,
    full_name VARCHAR2(100) NOT NULL,
    email VARCHAR2(100) UNIQUE NOT NULL,
    phone VARCHAR2(15) NOT NULL,
    password_hash VARCHAR2(255) NOT NULL,
    role VARCHAR2(20) DEFAULT 'customer' CHECK (role IN ('admin', 'vendor', 'customer')),
    created_at DATE DEFAULT SYSDATE,
    last_login DATE,
    is_active CHAR(1) DEFAULT 'Y' CHECK (is_active IN ('Y', 'N'))
);

-- 2. VENDORS TABLE
CREATE TABLE vendors (
    vendor_id NUMBER(10) PRIMARY KEY,
    vendor_name VARCHAR2(150) NOT NULL,
    category VARCHAR2(50) NOT NULL CHECK (category IN ('hospital', 'event', 'gym', 'salon', 'university', 'government')),
    location VARCHAR2(200) NOT NULL,
    contact_email VARCHAR2(100) NOT NULL,
    contact_phone VARCHAR2(15) NOT NULL,
    created_by NUMBER(10) REFERENCES users(user_id),
    created_at DATE DEFAULT SYSDATE,
    is_active CHAR(1) DEFAULT 'Y' CHECK (is_active IN ('Y', 'N'))
);

-- 3. SERVICES TABLE
CREATE TABLE services (
    service_id NUMBER(10) PRIMARY KEY,
    vendor_id NUMBER(10) NOT NULL REFERENCES vendors(vendor_id),
    service_name VARCHAR2(100) NOT NULL,
    description VARCHAR2(500),
    duration_minutes NUMBER(4) NOT NULL CHECK (duration_minutes > 0),
    price NUMBER(10,2) DEFAULT 0.00,
    max_capacity NUMBER(4) DEFAULT 1,
    is_active CHAR(1) DEFAULT 'Y' CHECK (is_active IN ('Y', 'N')),
    created_at DATE DEFAULT SYSDATE
);

-- 4. APPOINTMENTS TABLE
CREATE TABLE appointments (
    appointment_id NUMBER(10) PRIMARY KEY,
    user_id NUMBER(10) NOT NULL REFERENCES users(user_id),
    service_id NUMBER(10) NOT NULL REFERENCES services(service_id),
    appointment_date DATE NOT NULL,
    appointment_time TIMESTAMP NOT NULL,
    status VARCHAR2(20) DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'completed', 'cancelled', 'no-show')),
    ticket_code VARCHAR2(50) UNIQUE,
    notes VARCHAR2(500),
    created_at DATE DEFAULT SYSDATE
);

-- 5. TICKETS TABLE
CREATE TABLE tickets (
    ticket_id NUMBER(10) PRIMARY KEY,
    user_id NUMBER(10) NOT NULL REFERENCES users(user_id),
    vendor_id NUMBER(10) NOT NULL REFERENCES vendors(vendor_id),
    event_name VARCHAR2(150) NOT NULL,
    event_date DATE NOT NULL,
    event_time TIMESTAMP NOT NULL,
    seat_number VARCHAR2(10),
    qr_code VARCHAR2(100) UNIQUE NOT NULL,
    ticket_price NUMBER(10,2) NOT NULL,
    status VARCHAR2(20) DEFAULT 'valid' CHECK (status IN ('valid', 'used', 'cancelled', 'expired')),
    created_at DATE DEFAULT SYSDATE
);

-- 6. PAYMENTS TABLE
CREATE TABLE payments (
    payment_id NUMBER(10) PRIMARY KEY,
    user_id NUMBER(10) NOT NULL REFERENCES users(user_id),
    appointment_id NUMBER(10) REFERENCES appointments(appointment_id),
    ticket_id NUMBER(10) REFERENCES tickets(ticket_id),
    amount NUMBER(10,2) NOT NULL CHECK (amount > 0),
    payment_method VARCHAR2(20) NOT NULL CHECK (payment_method IN ('momo', 'visa', 'mastercard', 'cash')),
    transaction_id VARCHAR2(50) UNIQUE,
    payment_status VARCHAR2(20) DEFAULT 'pending' CHECK (payment_status IN ('pending', 'completed', 'failed', 'refunded')),
    payment_time TIMESTAMP DEFAULT SYSTIMESTAMP
);

-- 7. NOTIFICATIONS TABLE
CREATE TABLE notifications (
    notification_id NUMBER(10) PRIMARY KEY,
    user_id NUMBER(10) NOT NULL REFERENCES users(user_id),
    appointment_id NUMBER(10) REFERENCES appointments(appointment_id),
    ticket_id NUMBER(10) REFERENCES tickets(ticket_id),
    message_type VARCHAR2(30) NOT NULL CHECK (message_type IN ('confirmation', 'reminder', 'cancellation', 'update')),
    message_content VARCHAR2(1000) NOT NULL,
    sent_via VARCHAR2(20) DEFAULT 'email' CHECK (sent_via IN ('email', 'sms', 'push')),
    sent_status VARCHAR2(20) DEFAULT 'pending' CHECK (sent_status IN ('pending', 'sent', 'failed')),
    sent_time TIMESTAMP,
    created_at DATE DEFAULT SYSDATE
);

-- 8. AUDIT_LOG TABLE
CREATE TABLE audit_log (
    audit_id NUMBER(10) PRIMARY KEY,
    table_name VARCHAR2(50) NOT NULL,
    action_type VARCHAR2(10) NOT NULL CHECK (action_type IN ('INSERT', 'UPDATE', 'DELETE')),
    record_id VARCHAR2(100) NOT NULL,
    old_values CLOB,
    new_values CLOB,
    user_id NUMBER(10) REFERENCES users(user_id),
    ip_address VARCHAR2(45),
    timestamp TIMESTAMP DEFAULT SYSTIMESTAMP
);

-- 9. HOLIDAYS TABLE
CREATE TABLE holidays (
    holiday_id NUMBER(10) PRIMARY KEY,
    holiday_name VARCHAR2(100) NOT NULL,
    holiday_date DATE NOT NULL,
    holiday_type VARCHAR2(30) DEFAULT 'public' CHECK (holiday_type IN ('public', 'religious', 'national')),
    country VARCHAR2(50) DEFAULT 'Rwanda',
    created_at DATE DEFAULT SYSDATE,
    created_by NUMBER(10) REFERENCES users(user_id),
    UNIQUE(holiday_date, country)
);

PROMPT Creating indexes...
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_phone ON users(phone);
CREATE INDEX idx_appointments_date ON appointments(appointment_date);
CREATE INDEX idx_appointments_user ON appointments(user_id);
CREATE INDEX idx_appointments_status ON appointments(status);
CREATE INDEX idx_tickets_event_date ON tickets(event_date);
CREATE INDEX idx_payments_status ON payments(payment_status);
CREATE INDEX idx_audit_timestamp ON audit_log(timestamp);

PROMPT Tables created successfully!
SELECT COUNT(*) as table_count FROM user_tables;