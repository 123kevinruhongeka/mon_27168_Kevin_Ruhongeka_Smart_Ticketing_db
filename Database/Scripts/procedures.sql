-- =============================================
-- PHASE VI: PL/SQL Procedures
-- File: mon_27168_kevin_procedures.sql
-- =============================================

-- Procedure 1: Book an appointment
CREATE OR REPLACE PROCEDURE book_appointment(
    p_user_id IN NUMBER,
    p_service_id IN NUMBER,
    p_appointment_date IN DATE,
    p_appointment_time IN TIMESTAMP,
    p_notes IN VARCHAR2 DEFAULT NULL,
    p_appointment_id OUT NUMBER
)
IS
    v_available_slots NUMBER;
    v_max_capacity NUMBER;
    v_booked_slots NUMBER;
BEGIN
    -- Check service availability
    SELECT max_capacity INTO v_max_capacity
    FROM services 
    WHERE service_id = p_service_id AND is_active = 'Y';
    
    -- Count booked slots for same time
    SELECT COUNT(*) INTO v_booked_slots
    FROM appointments a
    JOIN services s ON a.service_id = s.service_id
    WHERE a.service_id = p_service_id
      AND a.appointment_date = p_appointment_date
      AND a.status IN ('confirmed', 'pending')
      AND ABS(EXTRACT(HOUR FROM a.appointment_time) - 
          EXTRACT(HOUR FROM p_appointment_time)) < 1;
    
    -- Check if slots available
    IF v_booked_slots >= v_max_capacity THEN
        RAISE_APPLICATION_ERROR(-20001, 'No available slots for this service at selected time');
    END IF;
    
    -- Generate unique ticket code
    DECLARE
        v_ticket_code VARCHAR2(50);
    BEGIN
        v_ticket_code := 'TICKET-' || TO_CHAR(SYSDATE, 'YYYYMMDD') || '-' || 
                        DBMS_RANDOM.STRING('X', 8);
        
        -- Insert appointment
        INSERT INTO appointments (
            appointment_id, user_id, service_id, 
            appointment_date, appointment_time, 
            status, ticket_code, notes
        ) VALUES (
            seq_appointments.NEXTVAL, p_user_id, p_service_id,
            p_appointment_date, p_appointment_time,
            'pending', v_ticket_code, p_notes
        ) RETURNING appointment_id INTO p_appointment_id;
    END;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Appointment booked successfully. ID: ' || p_appointment_id);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20002, 'Service not found or inactive');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END book_appointment;
/

-- Procedure 2: Process payment
CREATE OR REPLACE PROCEDURE process_payment(
    p_user_id IN NUMBER,
    p_appointment_id IN NUMBER DEFAULT NULL,
    p_ticket_id IN NUMBER DEFAULT NULL,
    p_amount IN NUMBER,
    p_payment_method IN VARCHAR2,
    p_transaction_id IN VARCHAR2,
    p_payment_id OUT NUMBER
)
IS
    v_status VARCHAR2(20);
    v_user_exists NUMBER;
BEGIN
    -- Validate user exists
    SELECT COUNT(*) INTO v_user_exists FROM users WHERE user_id = p_user_id;
    IF v_user_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'User not found');
    END IF;
    
    -- Validate at least one ID is provided
    IF p_appointment_id IS NULL AND p_ticket_id IS NULL THEN
        RAISE_APPLICATION_ERROR(-20004, 'Either appointment_id or ticket_id must be provided');
    END IF;
    
    -- Check appointment/ticket status if provided
    IF p_appointment_id IS NOT NULL THEN
        SELECT status INTO v_status FROM appointments 
        WHERE appointment_id = p_appointment_id;
        IF v_status = 'cancelled' THEN
            RAISE_APPLICATION_ERROR(-20005, 'Cannot pay for cancelled appointment');
        END IF;
    END IF;
    
    IF p_ticket_id IS NOT NULL THEN
        SELECT status INTO v_status FROM tickets 
        WHERE ticket_id = p_ticket_id;
        IF v_status = 'cancelled' OR v_status = 'used' THEN
            RAISE_APPLICATION_ERROR(-20006, 'Cannot pay for cancelled/used ticket');
        END IF;
    END IF;
    
    -- Process payment (simulated)
    INSERT INTO payments (
        payment_id, user_id, appointment_id, ticket_id,
        amount, payment_method, transaction_id, payment_status
    ) VALUES (
        seq_payments.NEXTVAL, p_user_id, p_appointment_id, p_ticket_id,
        p_amount, p_payment_method, p_transaction_id, 'completed'
    ) RETURNING payment_id INTO p_payment_id;
    
    -- Update appointment/ticket status
    IF p_appointment_id IS NOT NULL THEN
        UPDATE appointments SET status = 'confirmed' 
        WHERE appointment_id = p_appointment_id;
    END IF;
    
    IF p_ticket_id IS NOT NULL THEN
        UPDATE tickets SET status = 'valid' 
        WHERE ticket_id = p_ticket_id;
    END IF;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Payment processed successfully. Payment ID: ' || p_payment_id);
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END process_payment;
/

-- Procedure 3: Cancel appointment/ticket
CREATE OR REPLACE PROCEDURE cancel_booking(
    p_appointment_id IN NUMBER DEFAULT NULL,
    p_ticket_id IN NUMBER DEFAULT NULL,
    p_reason IN VARCHAR2 DEFAULT NULL
)
IS
    v_current_status VARCHAR2(20);
    v_refund_amount NUMBER;
BEGIN
    -- Cancel appointment
    IF p_appointment_id IS NOT NULL THEN
        SELECT status INTO v_current_status 
        FROM appointments WHERE appointment_id = p_appointment_id;
        
        IF v_current_status = 'cancelled' THEN
            RAISE_APPLICATION_ERROR(-20007, 'Appointment already cancelled');
        END IF;
        
        UPDATE appointments 
        SET status = 'cancelled',
            notes = COALESCE(notes || '; ', '') || 'Cancelled: ' || p_reason
        WHERE appointment_id = p_appointment_id;
        
        -- Process refund if paid
        SELECT COALESCE(SUM(amount), 0) INTO v_refund_amount
        FROM payments 
        WHERE appointment_id = p_appointment_id 
          AND payment_status = 'completed';
          
        IF v_refund_amount > 0 THEN
            INSERT INTO payments (
                payment_id, user_id, appointment_id,
                amount, payment_method, transaction_id, payment_status
            ) VALUES (
                seq_payments.NEXTVAL, 
                (SELECT user_id FROM appointments WHERE appointment_id = p_appointment_id),
                p_appointment_id,
                -v_refund_amount, 'refund', 
                'REFUND-' || TO_CHAR(SYSDATE, 'YYYYMMDD') || '-' || p_appointment_id,
                'completed'
            );
        END IF;
        
        DBMS_OUTPUT.PUT_LINE('Appointment cancelled: ' || p_appointment_id);
    END IF;
    
    -- Cancel ticket
    IF p_ticket_id IS NOT NULL THEN
        SELECT status INTO v_current_status 
        FROM tickets WHERE ticket_id = p_ticket_id;
        
        IF v_current_status = 'cancelled' THEN
            RAISE_APPLICATION_ERROR(-20008, 'Ticket already cancelled');
        END IF;
        
        UPDATE tickets 
        SET status = 'cancelled'
        WHERE ticket_id = p_ticket_id;
        
        -- Process refund if paid
        SELECT COALESCE(SUM(amount), 0) INTO v_refund_amount
        FROM payments 
        WHERE ticket_id = p_ticket_id 
          AND payment_status = 'completed';
          
        IF v_refund_amount > 0 THEN
            INSERT INTO payments (
                payment_id, user_id, ticket_id,
                amount, payment_method, transaction_id, payment_status
            ) VALUES (
                seq_payments.NEXTVAL, 
                (SELECT user_id FROM tickets WHERE ticket_id = p_ticket_id),
                p_ticket_id,
                -v_refund_amount, 'refund', 
                'REFUND-' || TO_CHAR(SYSDATE, 'YYYYMMDD') || '-' || p_ticket_id,
                'completed'
            );
        END IF;
        
        DBMS_OUTPUT.PUT_LINE('Ticket cancelled: ' || p_ticket_id);
    END IF;
    
    COMMIT;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20009, 'Booking not found');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END cancel_booking;
/

-- Procedure 4: Send notification
CREATE OR REPLACE PROCEDURE send_notification(
    p_user_id IN NUMBER,
    p_message_type IN VARCHAR2,
    p_message_content IN VARCHAR2,
    p_appointment_id IN NUMBER DEFAULT NULL,
    p_ticket_id IN NUMBER DEFAULT NULL
)
IS
    v_notification_id NUMBER;
    v_email VARCHAR2(100);
    v_phone VARCHAR2(15);
BEGIN
    -- Get user contact info
    SELECT email, phone INTO v_email, v_phone
    FROM users WHERE user_id = p_user_id;
    
    -- Insert notification
    INSERT INTO notifications (
        notification_id, user_id, appointment_id, ticket_id,
        message_type, message_content, sent_via, sent_status, sent_time
    ) VALUES (
        seq_notifications.NEXTVAL, p_user_id, p_appointment_id, p_ticket_id,
        p_message_type, p_message_content, 'email', 'sent', SYSTIMESTAMP
    ) RETURNING notification_id INTO v_notification_id;
    
    -- Simulate sending SMS
    INSERT INTO notifications (
        notification_id, user_id, appointment_id, ticket_id,
        message_type, message_content, sent_via, sent_status, sent_time
    ) VALUES (
        seq_notifications.NEXTVAL, p_user_id, p_appointment_id, p_ticket_id,
        p_message_type, p_message_content, 'sms', 'sent', SYSTIMESTAMP
    );
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Notification sent to user ' || p_user_id || 
                        ' via email and SMS. Notification ID: ' || v_notification_id);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20010, 'User not found');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END send_notification;
/

-- Procedure 5: Generate daily report
CREATE OR REPLACE PROCEDURE generate_daily_report(
    p_report_date IN DATE DEFAULT TRUNC(SYSDATE)
)
IS
    v_total_appointments NUMBER;
    v_total_tickets NUMBER;
    v_total_revenue NUMBER;
    v_cancellations NUMBER;
BEGIN
    -- Calculate metrics
    SELECT COUNT(*) INTO v_total_appointments
    FROM appointments 
    WHERE TRUNC(appointment_date) = p_report_date;
    
    SELECT COUNT(*) INTO v_total_tickets
    FROM tickets 
    WHERE TRUNC(event_date) = p_report_date;
    
    SELECT COALESCE(SUM(amount), 0) INTO v_total_revenue
    FROM payments 
    WHERE TRUNC(payment_time) = p_report_date 
      AND payment_status = 'completed'
      AND amount > 0;
    
    SELECT COUNT(*) INTO v_cancellations
    FROM (
        SELECT appointment_id FROM appointments 
        WHERE TRUNC(created_at) = p_report_date AND status = 'cancelled'
        UNION ALL
        SELECT ticket_id FROM tickets 
        WHERE TRUNC(created_at) = p_report_date AND status = 'cancelled'
    );
    
    -- Display report
    DBMS_OUTPUT.PUT_LINE('=== DAILY REPORT for ' || TO_CHAR(p_report_date, 'DD-MON-YYYY') || ' ===');
    DBMS_OUTPUT.PUT_LINE('Total Appointments: ' || v_total_appointments);
    DBMS_OUTPUT.PUT_LINE('Total Tickets Sold: ' || v_total_tickets);
    DBMS_OUTPUT.PUT_LINE('Total Revenue: ' || v_total_revenue || ' RWF');
    DBMS_OUTPUT.PUT_LINE('Total Cancellations: ' || v_cancellations);
    DBMS_OUTPUT.PUT_LINE('======================================');
    
    -- Insert into audit log (optional)
    INSERT INTO audit_log (audit_id, table_name, action_type, record_id, new_values)
    VALUES (
        seq_audit_log.NEXTVAL, 
        'DAILY_REPORT', 
        'INSERT',
        TO_CHAR(p_report_date, 'YYYYMMDD'),
        '{"appointments":' || v_total_appointments || 
        ',"tickets":' || v_total_tickets || 
        ',"revenue":' || v_total_revenue || 
        ',"cancellations":' || v_cancellations || '}'
    );
    
    COMMIT;
END generate_daily_report;
/