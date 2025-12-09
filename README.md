Smart Appointment & Ticketing Management System


📋 Project Overview
A comprehensive Oracle PL/SQL-based database solution for managing appointments, bookings, and digital ticketing across multiple service providers. This system enables efficient scheduling, real-time queue management, QR-based ticketing, and business intelligence analytics.

Student: Ruhongeka Kevin
Student ID: 27168
Course: Database Development with PL/SQL (INSY 8311)
University: Adventist University of Central Africa (AUCA)
Lecturer: Eric Maniraguha
Academic Year: 2025-2026 | Semester: I
Project Completion Date: December 7, 2025

🎯 Problem Statement
Businesses and service providers (hospitals, event organizers, gyms, universities) struggle with inefficient manual appointment scheduling, long customer queues, paper-based ticketing, and lack of real-time management capabilities, leading to poor customer experience and operational inefficiencies.

🚀 Solution Features
Online Appointment Scheduling with real-time availability

QR Code Digital Tickets for secure validation

Real-time Queue Management with live updates

Multi-vendor Marketplace support

Comprehensive Business Intelligence with dashboards

Advanced Auditing & Compliance tracking

Weekday/Holiday Restriction Rules (Critical Business Rule)

Predictive Analytics for capacity planning

🛠️ Technologies Used
Database: Oracle Database 19c/21c

Programming: PL/SQL (Procedures, Functions, Packages, Triggers)

Tools: SQL Developer, Oracle Enterprise Manager

Version Control: Git/GitHub

Documentation: Markdown, PowerPoint

📁 Repository Structure
text
smart-appointment-system/
│
├── database/
│   ├── scripts/
│   │   ├── 01_database_setup.sql          # Database creation
│   │   ├── 02_tables_creation.sql         # Table definitions
│   │   ├── 03_constraints_indexes.sql     # Constraints & indexes
│   │   ├── 04_sample_data.sql            # Test data (500+ records)
│   │   ├── 05_procedures_functions.sql    # PL/SQL procedures
│   │   ├── 06_packages.sql               # Package implementation
│   │   ├── 07_triggers.sql               # Business rule triggers
│   │   └── 08_business_rules.sql         # Critical rules
│   │
│   └── documentation/
│       ├── database_design.md            # ER diagrams & design
│       ├── data_dictionary.md           # Complete data dictionary
│       └── architecture_diagram.md      # System architecture
│
├── queries/
│   ├── data_retrieval/                   # SELECT queries
│   │   ├── basic_queries.sql            # Simple retrievals
│   │   ├── joins_subqueries.sql         # Multi-table queries
│   │   └── aggregations.sql             # Group by queries
│   │
│   ├── analytics/                        # BI queries
│   │   ├── kpi_queries.sql              # Key performance indicators
│   │   ├── trend_analysis.sql           # Time series analysis
│   │   ├── revenue_analytics.sql        # Financial analysis
│   │   └── predictive_analytics.sql     # Forecasting queries
│   │
│   └── audit/                           # Compliance queries
│       ├── audit_reports.sql            # Audit log queries
│       ├── compliance_check.sql         # Rule compliance
│       └── security_monitoring.sql      # Security audits
│
├── business_intelligence/
│   ├── bi_requirements.md               # BI specifications
│   ├── kpi_definitions.md              # KPI definitions & targets
│   ├── dashboards.md                   # Dashboard designs
│   ├── dashboard_mockups/              # UI mockups
│   └── reports/                        # Report templates
│
├── tests/
│   ├── unit_tests.sql                  # Individual component tests
│   ├── integration_tests.sql           # System integration tests
│   └── performance_tests.sql           # Performance benchmarks
│
├── screenshots/
│   ├── database/                       # Database structure screenshots
│   ├── execution/                      # Code execution proofs
│   ├── results/                        # Query results
│   └── dashboards/                     # Dashboard previews
│
└── documentation/
    ├── project_overview.md             # Complete project documentation
    ├── user_manual.md                  # System usage guide
    ├── technical_spec.md               # Technical specifications
    ├── presentation/                   # Final presentation
    │   ├── capstone_presentation.pptx
    │   └── speaker_notes.md
    └── README.md                       # This file
🗄️ Database Schema
Core Tables (10 Tables):
USERS - System users (admin/vendor/customer)

VENDORS - Service providers

SERVICES - Services offered

APPOINTMENTS - Booked appointments

TICKETS - Event tickets

PAYMENTS - Payment transactions

HOLIDAYS - Public holidays (for business rules)

AUDIT_LOG - Comprehensive operation tracking

NOTIFICATIONS - System alerts

FEEDBACK - Customer feedback

Database Name:
text
tue_27168_kevin_appticket_db
⚙️ Critical Business Rule Implementation
Rule: "Employees CANNOT INSERT/UPDATE/DELETE on WEEKDAYS (Monday-Friday) or PUBLIC HOLIDAYS"

Implementation Components:
HOLIDAYS Table - Stores public holiday dates

check_restricted_day() Function - Validates current day

Database Triggers - Enforce rule on all main tables

AUDIT_LOG System - Records all attempts (success/denial)

Sample Trigger Code:
sql
-- Example trigger enforcing the business rule
CREATE OR REPLACE TRIGGER trg_appointments_restrict
BEFORE INSERT OR UPDATE OR DELETE ON appointments
FOR EACH ROW
DECLARE
    v_restricted BOOLEAN;
BEGIN
    v_restricted := check_restricted_day();
    
    IF v_restricted THEN
        RAISE_APPLICATION_ERROR(-20001, 
            'Operations on appointments are not allowed on weekdays or public holidays.');
    END IF;
END;
/
📊 Key PL/SQL Components
1. Procedures (5+ Implemented)
book_appointment() - Complete booking with validation

cancel_appointment() - Cancellation with refund calculation

checkin_appointment() - QR code validation & check-in

generate_daily_report() - Comprehensive reporting

bulk_update_appointments() - Efficient bulk operations

2. Functions (5+ Implemented)
calculate_wait_time() - Service efficiency metrics

validate_qr_code() - Security validation

get_next_available_slot() - Smart scheduling

calculate_revenue() - Financial calculations

is_holiday_or_weekend() - Business rule validation

3. Packages
appointment_mgmt_pkg - Groups related business logic

4. Triggers (8+ Implemented)
Business rule enforcement triggers

Audit logging triggers

Data validation triggers

Compound triggers for complex logic

5. Advanced Features
Window functions (ROW_NUMBER, RANK, LAG/LEAD)

Bulk operations with BULK COLLECT

Autonomous transactions for auditing

Custom exception handling

Performance-optimized cursors

📈 Business Intelligence Implementation
Dashboard Portfolio:
Executive Dashboard - Strategic overview for management

Operations Dashboard - Real-time operational monitoring

Vendor Dashboard - Performance tracking for providers

Finance Dashboard - Revenue and financial analytics

Audit Dashboard - Compliance and security monitoring

Key Performance Indicators (KPIs):
Operational: Appointment volume, wait times, utilization rates

Financial: Daily revenue, payment success, average ticket value

Customer: Satisfaction scores, repeat rates, lifetime value

Vendor: Performance scores, on-time rates, quality metrics

🔐 Security & Auditing
Comprehensive audit trail for all operations

Business rule violation tracking

User activity monitoring

Data change history

Security incident logging

Compliance reporting

🚀 Quick Start Guide
1. Database Setup:
sql
-- Connect to Oracle as sysdba
CONNECT / AS SYSDBA;

-- Create pluggable database
CREATE PLUGGABLE DATABASE tue_27168_kevin_appticket_db
ADMIN USER admin IDENTIFIED BY kevin;

-- Open the database
ALTER PLUGGABLE DATABASE tue_27168_kevin_appticket_db OPEN;

-- Run setup scripts in order:
@database/scripts/01_database_setup.sql
@database/scripts/02_tables_creation.sql
@database/scripts/03_constraints_indexes.sql
@database/scripts/04_sample_data.sql
@database/scripts/05_procedures_functions.sql
@database/scripts/06_packages.sql
@database/scripts/07_triggers.sql
@database/scripts/08_business_rules.sql
2. Test Business Rules:
sql
-- Test 1: Try to insert appointment on weekday (should fail)
INSERT INTO appointments (user_id, service_id, appointment_date) 
VALUES (1, 1, SYSDATE);

-- Test 2: Check audit log for violation
SELECT * FROM audit_log WHERE status = 'DENIED';

-- Test 3: Test successful weekend operation (if weekend)
-- First check: SELECT check_restricted_day() FROM dual;
3. Run Sample Queries:
sql
-- View today's appointments
@queries/data_retrieval/basic_queries.sql

-- Check KPI metrics
@queries/analytics/kpi_queries.sql

-- Monitor compliance
@queries/audit/audit_reports.sql
🧪 Testing & Validation
Test Scenarios Covered:
✅ Weekday operations - DENIED

✅ Weekend operations - ALLOWED

✅ Holiday operations - DENIED

✅ Business rule violations - Logged

✅ Data integrity - Maintained

✅ Performance - Optimized

✅ Error handling - Comprehensive

Sample Test Results:
text
Test Case 1: Weekday Insert - DENIED ✓
Test Case 2: Audit Logging - VERIFIED ✓
Test Case 3: Data Validation - PASSED ✓
Test Case 4: Performance - WITHIN LIMITS ✓
📋 Project Deliverables
Completed Phases:
Phase I: Problem Identification ✓

Phase II: Business Process Modeling ✓

Phase III: Logical Database Design ✓

Phase IV: Database Creation ✓

Phase V: Table Implementation ✓

Phase VI: PL/SQL Development ✓

Phase VII: Advanced Programming ✓

Phase VIII: Final Documentation ✓

Submitted Files:
Complete GitHub Repository

Database Scripts (All SQL files)

PowerPoint Presentation (10 slides)

Business Intelligence Requirements

KPI Definitions & Dashboard Designs

Screenshots with Project Name

Comprehensive Documentation

👨‍💻 Author
Ruhongeka Kevin
Bachelor of Science in Information Systems
Adventist University of Central Africa
Email: [Your Email]
GitHub: [Your GitHub Profile]

🙏 Acknowledgments
Lecturer: Eric Maniraguha for guidance and mentorship

AUCA Faculty for academic support

Oracle Corporation for database technology

Open Source Community for tools and resources

📄 License
This project is developed as part of academic coursework at Adventist University of Central Africa. All code and documentation are original work by the student.

📧 Contact & Submission
Submitted to: Eric Maniraguha
Email: eric.maniraguha@auca.ac.rw
Submission Date: December 7, 2025


Verse: "Whatever you do, work at it with all your heart, as working for the Lord, not for human masters." — Colossians 3:23 (NIV)

© 2025 Ruhongeka Kevin | AUCA | PL/SQL Capstone Project
