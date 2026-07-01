-- 03_plsql.sql
-- AI-Assisted Drought Intelligence and Aid Allocation System



CREATE OR REPLACE PACKAGE pkg_drought_aid AS

    FUNCTION calculate_drought_score (
        p_region_id IN NUMBER
    ) RETURN NUMBER;

    FUNCTION get_priority_level (
        p_score IN NUMBER
    ) RETURN VARCHAR2;

    FUNCTION calculate_allocation_percentage (
        p_requested_quantity IN NUMBER,
        p_allocated_quantity IN NUMBER
    ) RETURN NUMBER;

    PROCEDURE add_drought_report (
        p_region_id IN NUMBER,
        p_rainfall_mm IN NUMBER,
        p_water_level_percent IN NUMBER,
        p_vegetation_index IN NUMBER,
        p_report_id OUT NUMBER
    );

    PROCEDURE submit_aid_request (
        p_region_id IN NUMBER,
        p_aid_item_id IN NUMBER,
        p_requested_quantity IN NUMBER,
        p_urgency_level IN VARCHAR2,
        p_request_id OUT NUMBER
    );

    PROCEDURE update_request_status (
        p_request_id IN NUMBER,
        p_new_status IN VARCHAR2
    );

    PROCEDURE allocate_aid (
        p_request_id IN NUMBER,
        p_operator_note IN OUT VARCHAR2,
        p_allocated_quantity OUT NUMBER
    );

    PROCEDURE generate_priority_list;

END pkg_drought_aid;
/

CREATE OR REPLACE PACKAGE BODY pkg_drought_aid AS

    e_invalid_quantity EXCEPTION;
    e_invalid_score EXCEPTION;
    e_invalid_status EXCEPTION;
    e_invalid_report_data EXCEPTION;
    e_request_not_pending EXCEPTION;

    FUNCTION calculate_drought_score (
        p_region_id IN NUMBER
    ) RETURN NUMBER
    IS
        v_rainfall NUMBER;
        v_water_level NUMBER;
        v_vegetation NUMBER;
        v_vulnerability NUMBER;
        v_score NUMBER;
    BEGIN
        SELECT
            r.vulnerability_score,
            dr.rainfall_mm,
            dr.water_level_percent,
            dr.vegetation_index
        INTO
            v_vulnerability,
            v_rainfall,
            v_water_level,
            v_vegetation
        FROM regions r
        JOIN (
            SELECT region_id, rainfall_mm, water_level_percent, vegetation_index
            FROM (
                SELECT
                    region_id,
                    rainfall_mm,
                    water_level_percent,
                    vegetation_index,
                    ROW_NUMBER() OVER (
                        PARTITION BY region_id
                        ORDER BY report_date DESC, report_id DESC
                    ) AS rn
                FROM drought_reports
            )
            WHERE rn = 1
        ) dr ON r.region_id = dr.region_id
        WHERE r.region_id = p_region_id;

        v_score :=
            CASE
                WHEN v_rainfall < 20 THEN 30
                WHEN v_rainfall < 40 THEN 22
                WHEN v_rainfall < 70 THEN 12
                ELSE 5
            END
            +
            CASE
                WHEN v_water_level < 30 THEN 30
                WHEN v_water_level < 50 THEN 22
                WHEN v_water_level < 70 THEN 12
                ELSE 5
            END
            +
            CASE
                WHEN v_vegetation < 0.25 THEN 25
                WHEN v_vegetation < 0.45 THEN 18
                WHEN v_vegetation < 0.65 THEN 10
                ELSE 4
            END
            +
            (v_vulnerability * 1.5);

        RETURN LEAST(100, ROUND(v_score, 2));

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20010, 'No drought data found for this region.');
        WHEN TOO_MANY_ROWS THEN
            RAISE_APPLICATION_ERROR(-20011, 'More than one latest drought report found.');
        WHEN VALUE_ERROR THEN
            RAISE_APPLICATION_ERROR(-20012, 'Invalid value while calculating drought score.');
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20013, 'Error calculating drought score: ' || SQLERRM);
    END calculate_drought_score;

    FUNCTION get_priority_level (
        p_score IN NUMBER
    ) RETURN VARCHAR2
    IS
    BEGIN
        IF p_score IS NULL OR p_score < 0 OR p_score > 100 THEN
            RAISE e_invalid_score;
        END IF;

        IF p_score >= 80 THEN
            RETURN 'CRITICAL';
        ELSIF p_score >= 60 THEN
            RETURN 'HIGH';
        ELSIF p_score >= 35 THEN
            RETURN 'MODERATE';
        ELSE
            RETURN 'LOW';
        END IF;

    EXCEPTION
        WHEN e_invalid_score THEN
            RAISE_APPLICATION_ERROR(-20020, 'Priority score must be between 0 and 100.');
        WHEN VALUE_ERROR THEN
            RAISE_APPLICATION_ERROR(-20021, 'Invalid value for priority score.');
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20022, 'Error getting priority level: ' || SQLERRM);
    END get_priority_level;

    FUNCTION calculate_allocation_percentage (
        p_requested_quantity IN NUMBER,
        p_allocated_quantity IN NUMBER
    ) RETURN NUMBER
    IS
    BEGIN
        IF p_requested_quantity <= 0 THEN
            RAISE e_invalid_quantity;
        END IF;

        RETURN ROUND((p_allocated_quantity / p_requested_quantity) * 100, 2);

    EXCEPTION
        WHEN e_invalid_quantity THEN
            RAISE_APPLICATION_ERROR(-20030, 'Requested quantity must be greater than zero.');
        WHEN ZERO_DIVIDE THEN
            RAISE_APPLICATION_ERROR(-20031, 'Cannot divide by zero.');
        WHEN VALUE_ERROR THEN
            RAISE_APPLICATION_ERROR(-20032, 'Invalid value while calculating allocation percentage.');
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20033, 'Error calculating allocation percentage: ' || SQLERRM);
    END calculate_allocation_percentage;

    PROCEDURE add_drought_report (
        p_region_id IN NUMBER,
        p_rainfall_mm IN NUMBER,
        p_water_level_percent IN NUMBER,
        p_vegetation_index IN NUMBER,
        p_report_id OUT NUMBER
    )
    IS
        v_region_id regions.region_id%TYPE;
    BEGIN
        IF p_rainfall_mm < 0
           OR p_water_level_percent < 0
           OR p_water_level_percent > 100
           OR p_vegetation_index < 0
           OR p_vegetation_index > 1 THEN
            RAISE e_invalid_report_data;
        END IF;

        SELECT region_id
        INTO v_region_id
        FROM regions
        WHERE region_id = p_region_id;

        p_report_id := seq_drought_reports.NEXTVAL;

        INSERT INTO drought_reports (
            report_id,
            region_id,
            report_date,
            rainfall_mm,
            water_level_percent,
            vegetation_index,
            severity_level
        ) VALUES (
            p_report_id,
            p_region_id,
            SYSDATE,
            p_rainfall_mm,
            p_water_level_percent,
            p_vegetation_index,
            NULL
        );

    EXCEPTION
        WHEN e_invalid_report_data THEN
            RAISE_APPLICATION_ERROR(-20040, 'Invalid drought report data.');
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20041, 'Region does not exist.');
        WHEN VALUE_ERROR THEN
            RAISE_APPLICATION_ERROR(-20042, 'Invalid value while adding drought report.');
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20043, 'Error adding drought report: ' || SQLERRM);
    END add_drought_report;

    PROCEDURE submit_aid_request (
        p_region_id IN NUMBER,
        p_aid_item_id IN NUMBER,
        p_requested_quantity IN NUMBER,
        p_urgency_level IN VARCHAR2,
        p_request_id OUT NUMBER
    )
    IS
        v_region_id regions.region_id%TYPE;
        v_aid_item_id aid_items.aid_item_id%TYPE;
    BEGIN
        IF p_requested_quantity <= 0 THEN
            RAISE e_invalid_quantity;
        END IF;

        IF UPPER(p_urgency_level) NOT IN ('LOW', 'MEDIUM', 'HIGH', 'EMERGENCY') THEN
            RAISE e_invalid_status;
        END IF;

        SELECT region_id
        INTO v_region_id
        FROM regions
        WHERE region_id = p_region_id;

        SELECT aid_item_id
        INTO v_aid_item_id
        FROM aid_items
        WHERE aid_item_id = p_aid_item_id;

        p_request_id := seq_aid_requests.NEXTVAL;

        INSERT INTO aid_requests (
            request_id,
            region_id,
            aid_item_id,
            requested_quantity,
            urgency_level,
            request_status,
            request_date
        ) VALUES (
            p_request_id,
            p_region_id,
            p_aid_item_id,
            p_requested_quantity,
            UPPER(p_urgency_level),
            'PENDING',
            SYSDATE
        );

    EXCEPTION
        WHEN e_invalid_quantity THEN
            RAISE_APPLICATION_ERROR(-20050, 'Requested quantity must be greater than zero.');
        WHEN e_invalid_status THEN
            RAISE_APPLICATION_ERROR(-20051, 'Invalid urgency level.');
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20052, 'Region or aid item does not exist.');
        WHEN VALUE_ERROR THEN
            RAISE_APPLICATION_ERROR(-20053, 'Invalid value while submitting aid request.');
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20054, 'Error submitting aid request: ' || SQLERRM);
    END submit_aid_request;

    PROCEDURE update_request_status (
        p_request_id IN NUMBER,
        p_new_status IN VARCHAR2
    )
    IS
    BEGIN
        IF UPPER(p_new_status) NOT IN ('PENDING', 'APPROVED', 'PARTIAL', 'REJECTED') THEN
            RAISE e_invalid_status;
        END IF;

        UPDATE aid_requests
        SET request_status = UPPER(p_new_status)
        WHERE request_id = p_request_id;

        IF SQL%ROWCOUNT = 0 THEN
            RAISE NO_DATA_FOUND;
        END IF;

    EXCEPTION
        WHEN e_invalid_status THEN
            RAISE_APPLICATION_ERROR(-20060, 'Invalid request status.');
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20061, 'Aid request not found.');
        WHEN VALUE_ERROR THEN
            RAISE_APPLICATION_ERROR(-20062, 'Invalid value while updating request status.');
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20063, 'Error updating request status: ' || SQLERRM);
    END update_request_status;

    PROCEDURE allocate_aid (
        p_request_id IN NUMBER,
        p_operator_note IN OUT VARCHAR2,
        p_allocated_quantity OUT NUMBER
    )
    IS
        v_request aid_requests%ROWTYPE;
        v_inventory aid_inventory%ROWTYPE;
        v_priority_score NUMBER;
        v_status aid_allocations.allocation_status%TYPE;
        v_request_status aid_requests.request_status%TYPE;
    BEGIN
        SELECT *
        INTO v_request
        FROM aid_requests
        WHERE request_id = p_request_id;

        IF v_request.request_status <> 'PENDING' THEN
            RAISE e_request_not_pending;
        END IF;

        SELECT *
        INTO v_inventory
        FROM aid_inventory
        WHERE aid_item_id = v_request.aid_item_id
        FOR UPDATE;

        v_priority_score := calculate_drought_score(v_request.region_id);

        IF v_inventory.quantity_available >= v_request.requested_quantity THEN
            p_allocated_quantity := v_request.requested_quantity;
            v_status := 'ALLOCATED';
            v_request_status := 'APPROVED';
        ELSIF v_inventory.quantity_available > 0 THEN
            p_allocated_quantity := v_inventory.quantity_available;
            v_status := 'PARTIAL';
            v_request_status := 'PARTIAL';
        ELSE
            p_allocated_quantity := 0;
            v_status := 'FAILED';
            v_request_status := 'REJECTED';
        END IF;

        UPDATE aid_inventory
        SET quantity_available = quantity_available - p_allocated_quantity,
            last_updated = SYSDATE
        WHERE inventory_id = v_inventory.inventory_id;

        p_operator_note :=
            NVL(p_operator_note, 'Processed by drought aid system')
            || ' | Priority: '
            || get_priority_level(v_priority_score);

        INSERT INTO aid_allocations (
            allocation_id,
            request_id,
            allocated_quantity,
            priority_score,
            allocation_status,
            allocation_date,
            operator_note
        ) VALUES (
            seq_aid_allocations.NEXTVAL,
            p_request_id,
            p_allocated_quantity,
            v_priority_score,
            v_status,
            SYSDATE,
            p_operator_note
        );

        update_request_status(p_request_id, v_request_status);

    EXCEPTION
        WHEN e_request_not_pending THEN
            RAISE_APPLICATION_ERROR(-20070, 'This request has already been processed.');
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20071, 'Request or inventory record not found.');
        WHEN DUP_VAL_ON_INDEX THEN
            RAISE_APPLICATION_ERROR(-20072, 'This request already has an allocation.');
        WHEN VALUE_ERROR THEN
            RAISE_APPLICATION_ERROR(-20073, 'Invalid value while allocating aid.');
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20074, 'Error allocating aid: ' || SQLERRM);
    END allocate_aid;

    PROCEDURE generate_priority_list
    IS
        CURSOR cur_pending_requests IS
            SELECT
                ar.request_id,
                ar.region_id,
                r.region_name,
                ai.item_name,
                ar.requested_quantity
            FROM aid_requests ar
            JOIN regions r ON ar.region_id = r.region_id
            JOIN aid_items ai ON ar.aid_item_id = ai.aid_item_id
            WHERE ar.request_status = 'PENDING'
            ORDER BY ar.request_date;

        v_request aid_requests%ROWTYPE;

        TYPE priority_rec IS RECORD (
            request_id NUMBER,
            region_name VARCHAR2(100),
            item_name VARCHAR2(100),
            requested_quantity NUMBER,
            score NUMBER,
            priority_level VARCHAR2(20)
        );

        TYPE priority_tab IS TABLE OF priority_rec;
        TYPE score_arr IS TABLE OF NUMBER INDEX BY PLS_INTEGER;

        v_priority_list priority_tab := priority_tab();
        v_scores score_arr;
        v_index PLS_INTEGER;
        v_pos PLS_INTEGER;
    BEGIN
        FOR rec IN cur_pending_requests LOOP
            SELECT *
            INTO v_request
            FROM aid_requests
            WHERE request_id = rec.request_id;

            v_priority_list.EXTEND;
            v_index := v_priority_list.COUNT;

            v_priority_list(v_index).request_id := rec.request_id;
            v_priority_list(v_index).region_name := rec.region_name;
            v_priority_list(v_index).item_name := rec.item_name;
            v_priority_list(v_index).requested_quantity := rec.requested_quantity;
            v_priority_list(v_index).score := calculate_drought_score(rec.region_id);
            v_priority_list(v_index).priority_level := get_priority_level(v_priority_list(v_index).score);

            v_scores(v_index) := v_priority_list(v_index).score;
        END LOOP;

        DBMS_OUTPUT.PUT_LINE('Pending Request Priority List');
        DBMS_OUTPUT.PUT_LINE('-----------------------------');

        IF v_priority_list.COUNT = 0 THEN
            DBMS_OUTPUT.PUT_LINE('No pending aid requests found.');
        ELSE
            v_pos := v_scores.FIRST;

            WHILE v_pos IS NOT NULL LOOP
                IF v_scores.EXISTS(v_pos) THEN
                    DBMS_OUTPUT.PUT_LINE(
                        'Request ID: ' || v_priority_list(v_pos).request_id ||
                        ', Region: ' || v_priority_list(v_pos).region_name ||
                        ', Aid: ' || v_priority_list(v_pos).item_name ||
                        ', Score: ' || v_scores(v_pos) ||
                        ', Priority: ' || v_priority_list(v_pos).priority_level
                    );
                END IF;

                v_pos := v_scores.NEXT(v_pos);
            END LOOP;
        END IF;

        v_priority_list.DELETE;
        v_scores.DELETE;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20080, 'Data missing while generating priority list.');
        WHEN VALUE_ERROR THEN
            RAISE_APPLICATION_ERROR(-20081, 'Invalid value while generating priority list.');
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20082, 'Error generating priority list: ' || SQLERRM);
    END generate_priority_list;

END pkg_drought_aid;
/

CREATE OR REPLACE TRIGGER trg_drought_reports_before_insert
BEFORE INSERT ON drought_reports
FOR EACH ROW
BEGIN
    IF :NEW.report_id IS NULL THEN
        :NEW.report_id := seq_drought_reports.NEXTVAL;
    END IF;

    IF :NEW.report_date IS NULL THEN
        :NEW.report_date := SYSDATE;
    END IF;

    IF :NEW.rainfall_mm < 20 AND :NEW.water_level_percent < 30 THEN
        :NEW.severity_level := 'CRITICAL';
    ELSIF :NEW.rainfall_mm < 40 OR :NEW.water_level_percent < 45 THEN
        :NEW.severity_level := 'HIGH';
    ELSIF :NEW.rainfall_mm < 70 OR :NEW.water_level_percent < 65 THEN
        :NEW.severity_level := 'MODERATE';
    ELSE
        :NEW.severity_level := 'LOW';
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20100, 'Error in drought report trigger: ' || SQLERRM);
END;
/

CREATE OR REPLACE TRIGGER trg_aid_allocations_after_insert
AFTER INSERT ON aid_allocations
FOR EACH ROW
BEGIN
    INSERT INTO allocation_audit (
        audit_id,
        allocation_id,
        action_type,
        action_date,
        description
    ) VALUES (
        seq_allocation_audit.NEXTVAL,
        :NEW.allocation_id,
        'INSERT',
        SYSDATE,
        'Allocation created for request ' || :NEW.request_id ||
        ' with status ' || :NEW.allocation_status || '.'
    );

EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20110, 'Error in allocation audit trigger: ' || SQLERRM);
END;
/

CREATE OR REPLACE TRIGGER trg_aid_inventory_before_update
BEFORE UPDATE ON aid_inventory
FOR EACH ROW
BEGIN
    IF :NEW.quantity_available < 0 THEN
        RAISE_APPLICATION_ERROR(-20120, 'Inventory quantity cannot become negative.');
    END IF;

    :NEW.last_updated := SYSDATE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20121, 'Error in inventory trigger: ' || SQLERRM);
END;
/

SELECT object_name, object_type, status
FROM user_objects
WHERE object_type IN ('PACKAGE', 'PACKAGE BODY', 'TRIGGER')
ORDER BY object_type, object_name;