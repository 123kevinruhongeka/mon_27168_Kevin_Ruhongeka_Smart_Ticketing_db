-- All users
SELECT * FROM users ORDER BY created_at DESC;

-- Active vendors with services
SELECT v.*, COUNT(s.service_id) as service_count 
FROM vendors v 
LEFT JOIN services s ON v.vendor_id = s.vendor_id 
WHERE v.status='ACTIVE' 
GROUP BY v.vendor_id, v.vendor_name;

-- Today's appointments
SELECT a.*, u.full_name, s.service_name, v.vendor_name
FROM appointments a
JOIN users u ON a.user_id = u.user_id
JOIN services s ON a.service_id = s.service_id
JOIN vendors v ON s.vendor_id = v.vendor_id
WHERE TRUNC(a.appointment_date) = TRUNC(SYSDATE);