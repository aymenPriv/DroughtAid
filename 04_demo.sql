-- 04_demo.sql
-- Demo script for AI-Assisted Drought Intelligence and Aid Allocation System

-- 1. Check dashboard summary
SELECT * FROM vw_dashboard_summary;


-- 2. Show latest drought status for all regions
SELECT
    region_id,
    region_name,
    rainfall_mm,
    water_level_percent,
    vegetation_index,
    severity_level
FROM vw_region_drought_status
ORDER BY region_id;


-- 3. Test function: calculate drought score
SELECT
    region_id,
    region_name,
    pkg_drought_aid.calculate_drought_score(region_id) AS drought_score,
    pkg_drought_aid.get_priority_level(
        pkg_drought_aid.calculate_drought_score(region_id)
    ) AS priority_level
FROM regions
WHERE region_id IN (1, 2, 3);


-- 4. Test function: allocation percentage
SELECT
    pkg_drought_aid.calculate_allocation_percentage(1000, 750) AS allocation_percentage
FROM dual;


-- 5. Test procedure: add a new drought report
DECLARE
    v_report_id NUMBER;
BEGIN
    pkg_drought_aid.add_drought_report(
        p_region_id => 1,
        p_rainfall_mm => 10,
        p_water_level_percent => 18,
        p_vegetation_index => 0.15,
        p_report_id => v_report_id
    );

    COMMIT;
END;
/


-- 6. Check that BEFORE trigger set severity automatically
SELECT
    report_id,
    region_id,
    rainfall_mm,
    water_level_percent,
    vegetation_index,
    severity_level,
    report_date
FROM drought_reports
WHERE region_id = 1
ORDER BY report_id DESC
FETCH FIRST 1 ROW ONLY;


-- 7. Test procedure: submit a new aid request
DECLARE
    v_request_id NUMBER;
BEGIN
    pkg_drought_aid.submit_aid_request(
        p_region_id => 1,
        p_aid_item_id => 2,
        p_requested_quantity => 250,
        p_urgency_level => 'EMERGENCY',
        p_request_id => v_request_id
    );

    COMMIT;
END;
/


-- 8. Check the new pending request
SELECT
    request_id,
    region_id,
    aid_item_id,
    requested_quantity,
    urgency_level,
    request_status,
    request_date
FROM aid_requests
WHERE region_id = 1
ORDER BY request_id DESC
FETCH FIRST 1 ROW ONLY;


-- 9. Test procedure: allocate aid for the latest pending request
DECLARE
    v_request_id NUMBER;
    v_note VARCHAR2(500) := 'Demo allocation from 04_demo.sql';
    v_allocated_quantity NUMBER;
BEGIN
    SELECT MAX(request_id)
    INTO v_request_id
    FROM aid_requests
    WHERE region_id = 1
      AND aid_item_id = 2
      AND request_status = 'PENDING';

    pkg_drought_aid.allocate_aid(
        p_request_id => v_request_id,
        p_operator_note => v_note,
        p_allocated_quantity => v_allocated_quantity
    );

    COMMIT;
END;
/


-- 10. Check allocation result
SELECT
    allocation_id,
    request_id,
    region_name,
    item_name,
    requested_quantity,
    allocated_quantity,
    priority_score,
    allocation_status,
    operator_note
FROM vw_allocation_details
ORDER BY allocation_id DESC
FETCH FIRST 1 ROW ONLY;


-- 11. Check that AFTER trigger created an audit record
SELECT
    audit_id,
    allocation_id,
    action_type,
    action_date,
    description
FROM allocation_audit
ORDER BY audit_id DESC
FETCH FIRST 1 ROW ONLY;


-- 12. Show updated dashboard summary
SELECT * FROM vw_dashboard_summary;


-- 13. Test cursor, record, nested table, and associative array procedure
BEGIN
    pkg_drought_aid.generate_priority_list;
END;
/


-- 14. Expected error test: invalid quantity
DECLARE
    v_request_id NUMBER;
BEGIN
    pkg_drought_aid.submit_aid_request(
        p_region_id => 1,
        p_aid_item_id => 1,
        p_requested_quantity => -50,
        p_urgency_level => 'HIGH',
        p_request_id => v_request_id
    );
END;
/