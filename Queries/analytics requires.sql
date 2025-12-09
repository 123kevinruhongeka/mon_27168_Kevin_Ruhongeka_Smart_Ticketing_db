-- Daily KPI Dashboard
SELECT 
    TRUNC(SYSDATE) as report_date,
    -- Appointment Metrics
    (SELECT COUNT(*) FROM appointments WHERE TRUNC(appointment_date) = TRUNC(SYSDATE)) as today_appointments,
    (SELECT COUNT(*) FROM appointments WHERE TRUNC(appointment_date) = TRUNC(SYSDATE) AND status = 'COMPLETED') as completed_today,
    (SELECT COUNT(*) FROM appointments WHERE TRUNC(appointment_date) = TRUNC(SYSDATE) AND status = 'CANCELLED') as cancelled_today,
    -- Revenue Metrics
    (SELECT NVL(SUM(s.price), 0) 
     FROM appointments a 
     JOIN services s ON a.service_id = s.service_id 
     WHERE TRUNC(a.appointment_date) = TRUNC(SYSDATE) AND a.status = 'COMPLETED') as today_revenue,
    -- Customer Metrics
    (SELECT COUNT(DISTINCT user_id) FROM appointments WHERE TRUNC(appointment_date) = TRUNC(SYSDATE)) as unique_customers_today,
    -- Wait Time Metrics
    (SELECT ROUND(AVG(EXTRACT(MINUTE FROM (checkin_time - start_time))), 1) 
     FROM appointments 
     WHERE TRUNC(appointment_date) = TRUNC(SYSDATE) AND checkin_time IS NOT NULL) as avg_wait_minutes,
    -- No-Show Rate
    ROUND(
        (SELECT COUNT(*) FROM appointments 
         WHERE TRUNC(appointment_date) = TRUNC(SYSDATE) AND status = 'NO_SHOW') * 100.0 /
        NULLIF((SELECT COUNT(*) FROM appointments WHERE TRUNC(appointment_date) = TRUNC(SYSDATE)), 0), 
    2) as no_show_rate_pct
FROM dual;