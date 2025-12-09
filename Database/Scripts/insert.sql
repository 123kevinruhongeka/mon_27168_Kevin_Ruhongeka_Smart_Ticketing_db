-- File: 02_insert_data.sql
SET SERVEROUTPUT ON
SET FEEDBACK OFF

PROMPT Inserting data into USERS table (100 rows)...
INSERT INTO users (user_id, full_name, email, phone, password_hash, role) VALUES
(seq_users.NEXTVAL, 'Alice Uwase', 'alice.uwase@email.com', '0781234567', 'hash1', 'customer');
INSERT INTO users (user_id, full_name, email, phone, password_hash, role) VALUES
(seq_users.NEXTVAL, 'Bob Kagabo', 'bob.kagabo@email.com', '0782234567', 'hash2', 'customer');
INSERT INTO users (user_id, full_name, email, phone, password_hash, role) VALUES
(seq_users.NEXTVAL, 'Claire Uwimana', 'claire.uwimana@email.com', '0783234567', 'hash3', 'customer');
INSERT INTO users (user_id, full_name, email, phone, password_hash, role) VALUES
(seq_users.NEXTVAL, 'David Niyonzima', 'david.niyonzima@email.com', '0784234567', 'hash4', 'customer');
INSERT INTO users (user_id, full_name, email, phone, password_hash, role) VALUES
(seq_users.NEXTVAL, 'Eric Maniraguha', 'eric.maniraguha@auca.ac.rw', '0785234567', 'hash5', 'admin');
INSERT INTO users (user_id, full_name, email, phone, password_hash, role) VALUES
(seq_users.NEXTVAL, 'Faith Muhire', 'faith.muhire@email.com', '0786234567', 'hash6', 'vendor');

-- Add more users with a loop
BEGIN
    FOR i IN 7..100 LOOP
        INSERT INTO users (user_id, full_name, email, phone, password_hash, role)
        VALUES (seq_users.NEXTVAL, 
                'User ' || i, 
                'user' || i || '@email.com',
                '078' || LPAD(1000+i, 7, '0'),
                'hash' || i,
                CASE MOD(i, 10) 
                    WHEN 0 THEN 'admin' 
                    WHEN 1 THEN 'vendor' 
                    ELSE 'customer' 
                END);
    END LOOP;
    COMMIT;
END;
/

PROMPT Inserting data into VENDORS table (20 rows)...
INSERT INTO vendors (vendor_id, vendor_name, category, location, contact_email, contact_phone, created_by) VALUES
(seq_vendors.NEXTVAL, 'King Faisal Hospital', 'hospital', 'Kigali, Rwanda', 'info@kfh.rw', '0781000001', 1005);
INSERT INTO vendors (vendor_id, vendor_name, category, location, contact_email, contact_phone, created_by) VALUES
(seq_vendors.NEXTVAL, 'Kigali Arena', 'event', 'Kigali, Rwanda', 'events@kigaliarena.rw', '0781000002', 1005);
INSERT INTO vendors (vendor_id, vendor_name, category, location, contact_email, contact_phone, created_by) VALUES
(seq_vendors.NEXTVAL, 'FitLife Gym', 'gym', 'Kacyiru, Kigali', 'info@fitlife.rw', '0781000003', 1005);

BEGIN
    FOR i IN 4..20 LOOP
        INSERT INTO vendors (vendor_id, vendor_name, category, location, contact_email, contact_phone, created_by)
        VALUES (seq_vendors.NEXTVAL,
                'Vendor ' || i,
                CASE MOD(i, 5) 
                    WHEN 0 THEN 'hospital'
                    WHEN 1 THEN 'event'
                    WHEN 2 THEN 'gym'
                    WHEN 3 THEN 'salon'
                    ELSE 'university'
                END,
                'Location ' || i || ', Kigali',
                'vendor' || i || '@email.com',
                '078' || LPAD(2000+i, 7, '0'),
                1005);
    END LOOP;
    COMMIT;
END;
/

PROMPT Inserting data into SERVICES table (50 rows)...
INSERT INTO services (service_id, vendor_id, service_name, description, duration_minutes, price) VALUES
(seq_services.NEXTVAL, 2001, 'General Checkup', 'Basic health assessment', 30, 5000);
INSERT INTO services (service_id, vendor_id, service_name, description, duration_minutes, price) VALUES
(seq_services.NEXTVAL, 2001, 'Dental Consultation', 'Teeth examination', 45, 8000);
INSERT INTO services (service_id, vendor_id, service_name, description, duration_minutes, price) VALUES
(seq_services.NEXTVAL, 2002, 'Basketball Game', 'NBA Africa Game', 120, 15000);

BEGIN
    FOR i IN 4..50 LOOP
        INSERT INTO services (service_id, vendor_id, service_name, description, duration_minutes, price)
        VALUES (seq_services.NEXTVAL,
                2000 + MOD(i, 10) + 1,
                'Service ' || i,
                'Description for service ' || i,
                CASE MOD(i, 4) 
                    WHEN 0 THEN 30
                    WHEN 1 THEN 45
                    WHEN 2 THEN 60
                    ELSE 90
                END,
                MOD(i, 10) * 1000 + 1000);
    END LOOP;
    COMMIT;
END;
/

PROMPT Inserting data into APPOINTMENTS table (200 rows)...
BEGIN
    FOR i IN 1..200 LOOP
        INSERT INTO appointments (appointment_id, user_id, service_id, appointment_date, appointment_time, status, ticket_code)
        VALUES (seq_appointments.NEXTVAL,
                1000 + MOD(i, 90) + 1,
                3000 + MOD(i, 40) + 1,
                SYSDATE + MOD(i, 30),
                TO_TIMESTAMP(TO_CHAR(SYSDATE + MOD(i, 30)) || ' ' || 
                            LPAD(8 + MOD(i, 8), 2, '0') || ':00:00', 'DD-MON-YY HH24:MI:SS'),
                CASE MOD(i, 20)
                    WHEN 0 THEN 'cancelled'
                    WHEN 1 THEN 'no-show'
                    WHEN 2 THEN 'completed'
                    ELSE 'confirmed'
                END,
                'TICKET-' || LPAD(i, 6, '0') || '-' || DBMS_RANDOM.STRING('X', 8));
    END LOOP;
    COMMIT;
END;
/

PROMPT Inserting data into TICKETS table (150 rows)...
BEGIN
    FOR i IN 1..150 LOOP
        INSERT INTO tickets (ticket_id, user_id, vendor_id, event_name, event_date, event_time, qr_code, ticket_price, status)
        VALUES (seq_tickets.NEXTVAL,
                1000 + MOD(i, 90) + 1,
                2000 + MOD(i, 8) + 1,
                CASE MOD(i, 5)
                    WHEN 0 THEN 'Music Concert'
                    WHEN 1 THEN 'Sports Game'
                    WHEN 2 THEN 'Conference'
                    WHEN 3 THEN 'Workshop'
                    ELSE 'Festival'
                END || ' ' || (2025 + MOD(i, 3)),
                SYSDATE + MOD(i, 60),
                TO_TIMESTAMP(TO_CHAR(SYSDATE + MOD(i, 60)) || ' ' || 
                            LPAD(14 + MOD(i, 6), 2, '0') || ':00:00', 'DD-MON-YY HH24:MI:SS'),
                'QR-' || LPAD(i, 6, '0') || '-' || DBMS_RANDOM.STRING('X', 10),
                CASE MOD(i, 4)
                    WHEN 0 THEN 5000
                    WHEN 1 THEN 10000
                    WHEN 2 THEN 15000
                    ELSE 20000
                END,
                CASE MOD(i, 20)
                    WHEN 0 THEN 'cancelled'
                    WHEN 1 THEN 'expired'
                    WHEN 2 THEN 'used'
                    ELSE 'valid'
                END);
    END LOOP;
    COMMIT;
END;
/

PROMPT Inserting data into PAYMENTS table (250 rows)...
BEGIN
    -- Payments for appointments
    FOR i IN 1..200 LOOP
        INSERT INTO payments (payment_id, user_id, appointment_id, amount, payment_method, transaction_id, payment_status)
        VALUES (seq_payments.NEXTVAL,
                1000 + MOD(i, 90) + 1,
                4000 + i,
                CASE MOD(i, 4)
                    WHEN 0 THEN 5000
                    WHEN 1 THEN 10000
                    WHEN 2 THEN 15000
                    ELSE 20000
                END,
                CASE MOD(i, 4)
                    WHEN 0 THEN 'momo'
                    WHEN 1 THEN 'visa'
                    WHEN 2 THEN 'mastercard'
                    ELSE 'cash'
                END,
                'TX-APP-' || LPAD(i, 6, '0'),
                CASE MOD(i, 20)
                    WHEN 0 THEN 'failed'
                    WHEN 1 THEN 'refunded'
                    ELSE 'completed'
                END);
    END LOOP;
    
    -- Payments for tickets
    FOR i IN 1..50 LOOP
        INSERT INTO payments (payment_id, user_id, ticket_id, amount, payment_method, transaction_id, payment_status)
        VALUES (seq_payments.NEXTVAL,
                1000 + MOD(i, 90) + 1,
                5000 + i,
                CASE MOD(i, 4)
                    WHEN 0 THEN 5000
                    WHEN 1 THEN 10000
                    WHEN 2 THEN 15000
                    ELSE 20000
                END,
                CASE MOD(i, 4)
                    WHEN 0 THEN 'momo'
                    WHEN 1 THEN 'visa'
                    WHEN 2 THEN 'mastercard'
                    ELSE 'cash'
                END,
                'TX-TICK-' || LPAD(i, 6, '0'),
                CASE MOD(i, 20)
                    WHEN 0 THEN 'failed'
                    WHEN 1 THEN 'refunded'
                    ELSE 'completed'
                END);
    END LOOP;
    COMMIT;
END;
/

PROMPT Inserting holidays...
INSERT INTO holidays (holiday_id, holiday_name, holiday_date, holiday_type) VALUES
(seq_holidays.NEXTVAL, 'Christmas Day', DATE '2025-12-25', 'religious');
INSERT INTO holidays (holiday_id, holiday_name, holiday_date, holiday_type) VALUES
(seq_holidays.NEXTVAL, 'New Years Day', DATE '2026-01-01', 'public');
COMMIT;

PROMPT Data insertion complete!
SELECT 'USERS: ' || COUNT(*) FROM users
UNION ALL SELECT 'VENDORS: ' || COUNT(*) FROM vendors
UNION ALL SELECT 'SERVICES: ' || COUNT(*) FROM services
UNION ALL SELECT 'APPOINTMENTS: ' || COUNT(*) FROM appointments
UNION ALL SELECT 'TICKETS: ' || COUNT(*) FROM tickets
UNION ALL SELECT 'PAYMENTS: ' || COUNT(*) FROM payments;