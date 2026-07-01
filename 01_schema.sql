-- 01_schema.sql
-- AI-Assisted Drought Intelligence and Aid Allocation System

-- Sequences
CREATE SEQUENCE seq_regions START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_drought_reports START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_aid_items START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_aid_inventory START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_aid_requests START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_aid_allocations START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_allocation_audit START WITH 1 INCREMENT BY 1 NOCACHE;


-- Regions affected by drought
CREATE TABLE regions (
    region_id NUMBER PRIMARY KEY,
    region_name VARCHAR2(100) NOT NULL,
    district_name VARCHAR2(100) NOT NULL,
    population NUMBER NOT NULL,
    vulnerability_score NUMBER(2) NOT NULL,
    created_at DATE DEFAULT SYSDATE NOT NULL,

    CONSTRAINT uq_regions_region_name UNIQUE (region_name),
    CONSTRAINT chk_regions_population CHECK (population > 0),
    CONSTRAINT chk_regions_vulnerability CHECK (vulnerability_score BETWEEN 1 AND 10)
);


-- Drought reports submitted for each region
CREATE TABLE drought_reports (
    report_id NUMBER PRIMARY KEY,
    region_id NUMBER NOT NULL,
    report_date DATE DEFAULT SYSDATE NOT NULL,
    rainfall_mm NUMBER(6,2) NOT NULL,
    water_level_percent NUMBER(5,2) NOT NULL,
    vegetation_index NUMBER(4,2) NOT NULL,
    severity_level VARCHAR2(20),

    CONSTRAINT fk_drought_reports_region
        FOREIGN KEY (region_id) REFERENCES regions(region_id),

    CONSTRAINT chk_drought_rainfall CHECK (rainfall_mm >= 0),
    CONSTRAINT chk_drought_water_level CHECK (water_level_percent BETWEEN 0 AND 100),
    CONSTRAINT chk_drought_vegetation CHECK (vegetation_index BETWEEN 0 AND 1),
    CONSTRAINT chk_drought_severity CHECK (
        severity_level IN ('LOW', 'MODERATE', 'HIGH', 'CRITICAL')
    )
);


-- Types of aid available in the system
CREATE TABLE aid_items (
    aid_item_id NUMBER PRIMARY KEY,
    item_name VARCHAR2(100) NOT NULL,
    item_category VARCHAR2(30) NOT NULL,
    unit VARCHAR2(30) NOT NULL,

    CONSTRAINT uq_aid_items_name UNIQUE (item_name),
    CONSTRAINT chk_aid_items_category CHECK (
        item_category IN ('FOOD', 'WATER', 'MEDICAL', 'SHELTER', 'HYGIENE')
    )
);


-- Current stock for each aid item
CREATE TABLE aid_inventory (
    inventory_id NUMBER PRIMARY KEY,
    aid_item_id NUMBER NOT NULL,
    quantity_available NUMBER NOT NULL,
    minimum_stock NUMBER DEFAULT 0 NOT NULL,
    last_updated DATE DEFAULT SYSDATE NOT NULL,

    CONSTRAINT fk_inventory_aid_item
        FOREIGN KEY (aid_item_id) REFERENCES aid_items(aid_item_id),

    CONSTRAINT uq_inventory_aid_item UNIQUE (aid_item_id),
    CONSTRAINT chk_inventory_quantity CHECK (quantity_available >= 0),
    CONSTRAINT chk_inventory_minimum CHECK (minimum_stock >= 0)
);


-- Aid requests made by regions
CREATE TABLE aid_requests (
    request_id NUMBER PRIMARY KEY,
    region_id NUMBER NOT NULL,
    aid_item_id NUMBER NOT NULL,
    requested_quantity NUMBER NOT NULL,
    urgency_level VARCHAR2(20) NOT NULL,
    request_status VARCHAR2(20) DEFAULT 'PENDING' NOT NULL,
    request_date DATE DEFAULT SYSDATE NOT NULL,

    CONSTRAINT fk_requests_region
        FOREIGN KEY (region_id) REFERENCES regions(region_id),

    CONSTRAINT fk_requests_aid_item
        FOREIGN KEY (aid_item_id) REFERENCES aid_items(aid_item_id),

    CONSTRAINT chk_requests_quantity CHECK (requested_quantity > 0),
    CONSTRAINT chk_requests_urgency CHECK (
        urgency_level IN ('LOW', 'MEDIUM', 'HIGH', 'EMERGENCY')
    ),
    CONSTRAINT chk_requests_status CHECK (
        request_status IN ('PENDING', 'APPROVED', 'PARTIAL', 'REJECTED')
    )
);


-- Aid allocation decisions
CREATE TABLE aid_allocations (
    allocation_id NUMBER PRIMARY KEY,
    request_id NUMBER NOT NULL,
    allocated_quantity NUMBER NOT NULL,
    priority_score NUMBER(5,2) NOT NULL,
    allocation_status VARCHAR2(20) NOT NULL,
    allocation_date DATE DEFAULT SYSDATE NOT NULL,
    operator_note VARCHAR2(500),

    CONSTRAINT fk_allocations_request
        FOREIGN KEY (request_id) REFERENCES aid_requests(request_id),

    CONSTRAINT uq_allocations_request UNIQUE (request_id),
    CONSTRAINT chk_allocations_quantity CHECK (allocated_quantity >= 0),
    CONSTRAINT chk_allocations_score CHECK (priority_score BETWEEN 0 AND 100),
    CONSTRAINT chk_allocations_status CHECK (
        allocation_status IN ('ALLOCATED', 'PARTIAL', 'FAILED')
    )
);


-- Audit log for allocation actions
CREATE TABLE allocation_audit (
    audit_id NUMBER PRIMARY KEY,
    allocation_id NUMBER NOT NULL,
    action_type VARCHAR2(20) NOT NULL,
    action_date DATE DEFAULT SYSDATE NOT NULL,
    description VARCHAR2(500) NOT NULL,

    CONSTRAINT fk_audit_allocation
        FOREIGN KEY (allocation_id) REFERENCES aid_allocations(allocation_id),

    CONSTRAINT chk_audit_action CHECK (
        action_type IN ('INSERT', 'UPDATE', 'DELETE')
    )
);


-- Latest drought status for each region
CREATE OR REPLACE VIEW vw_region_drought_status AS
SELECT
    r.region_id,
    r.region_name,
    r.district_name,
    r.population,
    r.vulnerability_score,
    dr.report_id,
    dr.report_date,
    dr.rainfall_mm,
    dr.water_level_percent,
    dr.vegetation_index,
    dr.severity_level
FROM regions r
LEFT JOIN (
    SELECT
        report_id,
        region_id,
        report_date,
        rainfall_mm,
        water_level_percent,
        vegetation_index,
        severity_level,
        ROW_NUMBER() OVER (
            PARTITION BY region_id
            ORDER BY report_date DESC, report_id DESC
        ) AS rn
    FROM drought_reports
) dr
    ON r.region_id = dr.region_id
   AND dr.rn = 1;


-- Full allocation information for reports and frontend display
CREATE OR REPLACE VIEW vw_allocation_details AS
SELECT
    aa.allocation_id,
    ar.request_id,
    r.region_id,
    r.region_name,
    r.district_name,
    ai.aid_item_id,
    ai.item_name,
    ai.item_category,
    ai.unit,
    ar.requested_quantity,
    aa.allocated_quantity,
    aa.priority_score,
    aa.allocation_status,
    aa.allocation_date,
    aa.operator_note
FROM aid_allocations aa
JOIN aid_requests ar ON aa.request_id = ar.request_id
JOIN regions r ON ar.region_id = r.region_id
JOIN aid_items ai ON ar.aid_item_id = ai.aid_item_id;


-- Summary values for the dashboard
CREATE OR REPLACE VIEW vw_dashboard_summary AS
SELECT
    (SELECT COUNT(*) FROM regions) AS total_regions,
    (SELECT COUNT(*) FROM drought_reports WHERE severity_level = 'CRITICAL') AS critical_reports,
    (SELECT COUNT(*) FROM aid_requests WHERE request_status = 'PENDING') AS pending_requests,
    (SELECT COUNT(*) FROM aid_inventory WHERE quantity_available <= minimum_stock) AS low_stock_items,
    (SELECT NVL(SUM(allocated_quantity), 0) FROM aid_allocations) AS total_aid_allocated
FROM dual;

SELECT table_name
FROM user_tables
ORDER BY table_name;

SELECT view_name
FROM user_views
ORDER BY view_name;