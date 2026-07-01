-- 02_data.sql
-- Sample data for Drought Aid project

INSERT INTO regions VALUES (seq_regions.NEXTVAL, 'Bay', 'Baidoa', 1200000, 9, SYSDATE);
INSERT INTO regions VALUES (seq_regions.NEXTVAL, 'Bakool', 'Hudur', 850000, 8, SYSDATE);
INSERT INTO regions VALUES (seq_regions.NEXTVAL, 'Gedo', 'Bardhere', 970000, 7, SYSDATE);
INSERT INTO regions VALUES (seq_regions.NEXTVAL, 'Hiran', 'Beledweyne', 760000, 8, SYSDATE);
INSERT INTO regions VALUES (seq_regions.NEXTVAL, 'Lower Shabelle', 'Afgooye', 1400000, 6, SYSDATE);
INSERT INTO regions VALUES (seq_regions.NEXTVAL, 'Middle Shabelle', 'Jowhar', 690000, 5, SYSDATE);
INSERT INTO regions VALUES (seq_regions.NEXTVAL, 'Mudug', 'Galkayo', 720000, 6, SYSDATE);
INSERT INTO regions VALUES (seq_regions.NEXTVAL, 'Bari', 'Bosaso', 650000, 4, SYSDATE);
INSERT INTO regions VALUES (seq_regions.NEXTVAL, 'Sanaag', 'Erigavo', 540000, 5, SYSDATE);
INSERT INTO regions VALUES (seq_regions.NEXTVAL, 'Banadir', 'Mogadishu', 2500000, 3, SYSDATE);

INSERT INTO drought_reports VALUES (seq_drought_reports.NEXTVAL, 1, SYSDATE - 10, 12.5, 22, 0.18, 'CRITICAL');
INSERT INTO drought_reports VALUES (seq_drought_reports.NEXTVAL, 2, SYSDATE - 9, 18.0, 28, 0.21, 'CRITICAL');
INSERT INTO drought_reports VALUES (seq_drought_reports.NEXTVAL, 3, SYSDATE - 8, 31.5, 35, 0.34, 'HIGH');
INSERT INTO drought_reports VALUES (seq_drought_reports.NEXTVAL, 4, SYSDATE - 7, 25.0, 32, 0.29, 'HIGH');
INSERT INTO drought_reports VALUES (seq_drought_reports.NEXTVAL, 5, SYSDATE - 6, 48.0, 46, 0.46, 'MODERATE');
INSERT INTO drought_reports VALUES (seq_drought_reports.NEXTVAL, 6, SYSDATE - 5, 62.0, 55, 0.52, 'MODERATE');
INSERT INTO drought_reports VALUES (seq_drought_reports.NEXTVAL, 7, SYSDATE - 4, 44.0, 41, 0.39, 'MODERATE');
INSERT INTO drought_reports VALUES (seq_drought_reports.NEXTVAL, 8, SYSDATE - 3, 76.0, 70, 0.68, 'LOW');
INSERT INTO drought_reports VALUES (seq_drought_reports.NEXTVAL, 9, SYSDATE - 2, 58.0, 50, 0.48, 'MODERATE');
INSERT INTO drought_reports VALUES (seq_drought_reports.NEXTVAL, 10, SYSDATE - 1, 85.0, 78, 0.74, 'LOW');

INSERT INTO aid_items VALUES (seq_aid_items.NEXTVAL, 'Rice Bags', 'FOOD', 'bags');
INSERT INTO aid_items VALUES (seq_aid_items.NEXTVAL, 'Water Cartons', 'WATER', 'cartons');
INSERT INTO aid_items VALUES (seq_aid_items.NEXTVAL, 'Medical Kits', 'MEDICAL', 'kits');
INSERT INTO aid_items VALUES (seq_aid_items.NEXTVAL, 'Emergency Tents', 'SHELTER', 'tents');
INSERT INTO aid_items VALUES (seq_aid_items.NEXTVAL, 'Blankets', 'SHELTER', 'pieces');
INSERT INTO aid_items VALUES (seq_aid_items.NEXTVAL, 'Hygiene Kits', 'HYGIENE', 'kits');
INSERT INTO aid_items VALUES (seq_aid_items.NEXTVAL, 'ORS Packets', 'MEDICAL', 'packets');
INSERT INTO aid_items VALUES (seq_aid_items.NEXTVAL, 'Milk Powder', 'FOOD', 'boxes');
INSERT INTO aid_items VALUES (seq_aid_items.NEXTVAL, 'Cooking Oil', 'FOOD', 'cartons');
INSERT INTO aid_items VALUES (seq_aid_items.NEXTVAL, 'Water Tanks', 'WATER', 'tanks');

INSERT INTO aid_inventory VALUES (seq_aid_inventory.NEXTVAL, 1, 5000, 500, SYSDATE);
INSERT INTO aid_inventory VALUES (seq_aid_inventory.NEXTVAL, 2, 8000, 1000, SYSDATE);
INSERT INTO aid_inventory VALUES (seq_aid_inventory.NEXTVAL, 3, 900, 100, SYSDATE);
INSERT INTO aid_inventory VALUES (seq_aid_inventory.NEXTVAL, 4, 600, 80, SYSDATE);
INSERT INTO aid_inventory VALUES (seq_aid_inventory.NEXTVAL, 5, 2500, 300, SYSDATE);
INSERT INTO aid_inventory VALUES (seq_aid_inventory.NEXTVAL, 6, 1400, 150, SYSDATE);
INSERT INTO aid_inventory VALUES (seq_aid_inventory.NEXTVAL, 7, 3500, 400, SYSDATE);
INSERT INTO aid_inventory VALUES (seq_aid_inventory.NEXTVAL, 8, 1200, 150, SYSDATE);
INSERT INTO aid_inventory VALUES (seq_aid_inventory.NEXTVAL, 9, 1800, 200, SYSDATE);
INSERT INTO aid_inventory VALUES (seq_aid_inventory.NEXTVAL, 10, 250, 50, SYSDATE);

INSERT INTO aid_requests VALUES (seq_aid_requests.NEXTVAL, 1, 2, 1500, 'EMERGENCY', 'APPROVED', SYSDATE - 5);
INSERT INTO aid_requests VALUES (seq_aid_requests.NEXTVAL, 2, 1, 1200, 'EMERGENCY', 'APPROVED', SYSDATE - 5);
INSERT INTO aid_requests VALUES (seq_aid_requests.NEXTVAL, 3, 3, 300, 'HIGH', 'PARTIAL', SYSDATE - 4);
INSERT INTO aid_requests VALUES (seq_aid_requests.NEXTVAL, 4, 7, 800, 'HIGH', 'APPROVED', SYSDATE - 4);
INSERT INTO aid_requests VALUES (seq_aid_requests.NEXTVAL, 5, 5, 700, 'MEDIUM', 'APPROVED', SYSDATE - 3);
INSERT INTO aid_requests VALUES (seq_aid_requests.NEXTVAL, 6, 6, 500, 'MEDIUM', 'PARTIAL', SYSDATE - 3);
INSERT INTO aid_requests VALUES (seq_aid_requests.NEXTVAL, 7, 9, 650, 'HIGH', 'APPROVED', SYSDATE - 2);
INSERT INTO aid_requests VALUES (seq_aid_requests.NEXTVAL, 8, 4, 120, 'LOW', 'APPROVED', SYSDATE - 2);
INSERT INTO aid_requests VALUES (seq_aid_requests.NEXTVAL, 9, 8, 400, 'MEDIUM', 'APPROVED', SYSDATE - 1);
INSERT INTO aid_requests VALUES (seq_aid_requests.NEXTVAL, 10, 10, 60, 'LOW', 'REJECTED', SYSDATE - 1);

INSERT INTO aid_allocations VALUES (seq_aid_allocations.NEXTVAL, 1, 1500, 92, 'ALLOCATED', SYSDATE - 4, 'Emergency water support approved.');
INSERT INTO aid_allocations VALUES (seq_aid_allocations.NEXTVAL, 2, 1200, 88, 'ALLOCATED', SYSDATE - 4, 'Food support sent to high-risk area.');
INSERT INTO aid_allocations VALUES (seq_aid_allocations.NEXTVAL, 3, 200, 76, 'PARTIAL', SYSDATE - 3, 'Partial medical support due to stock control.');
INSERT INTO aid_allocations VALUES (seq_aid_allocations.NEXTVAL, 4, 800, 79, 'ALLOCATED', SYSDATE - 3, 'ORS packets allocated.');
INSERT INTO aid_allocations VALUES (seq_aid_allocations.NEXTVAL, 5, 700, 58, 'ALLOCATED', SYSDATE - 2, 'Blankets allocated.');
INSERT INTO aid_allocations VALUES (seq_aid_allocations.NEXTVAL, 6, 300, 55, 'PARTIAL', SYSDATE - 2, 'Partial hygiene kits allocation.');
INSERT INTO aid_allocations VALUES (seq_aid_allocations.NEXTVAL, 7, 650, 69, 'ALLOCATED', SYSDATE - 1, 'Cooking oil allocated.');
INSERT INTO aid_allocations VALUES (seq_aid_allocations.NEXTVAL, 8, 120, 35, 'ALLOCATED', SYSDATE - 1, 'Shelter support allocated.');
INSERT INTO aid_allocations VALUES (seq_aid_allocations.NEXTVAL, 9, 400, 52, 'ALLOCATED', SYSDATE, 'Milk powder allocated.');
INSERT INTO aid_allocations VALUES (seq_aid_allocations.NEXTVAL, 10, 0, 25, 'FAILED', SYSDATE, 'Request rejected due to low priority.');

INSERT INTO allocation_audit VALUES (seq_allocation_audit.NEXTVAL, 1, 'INSERT', SYSDATE - 4, 'Allocation record created for request 1.');
INSERT INTO allocation_audit VALUES (seq_allocation_audit.NEXTVAL, 2, 'INSERT', SYSDATE - 4, 'Allocation record created for request 2.');
INSERT INTO allocation_audit VALUES (seq_allocation_audit.NEXTVAL, 3, 'INSERT', SYSDATE - 3, 'Allocation record created for request 3.');
INSERT INTO allocation_audit VALUES (seq_allocation_audit.NEXTVAL, 4, 'INSERT', SYSDATE - 3, 'Allocation record created for request 4.');
INSERT INTO allocation_audit VALUES (seq_allocation_audit.NEXTVAL, 5, 'INSERT', SYSDATE - 2, 'Allocation record created for request 5.');
INSERT INTO allocation_audit VALUES (seq_allocation_audit.NEXTVAL, 6, 'INSERT', SYSDATE - 2, 'Allocation record created for request 6.');
INSERT INTO allocation_audit VALUES (seq_allocation_audit.NEXTVAL, 7, 'INSERT', SYSDATE - 1, 'Allocation record created for request 7.');
INSERT INTO allocation_audit VALUES (seq_allocation_audit.NEXTVAL, 8, 'INSERT', SYSDATE - 1, 'Allocation record created for request 8.');
INSERT INTO allocation_audit VALUES (seq_allocation_audit.NEXTVAL, 9, 'INSERT', SYSDATE, 'Allocation record created for request 9.');
INSERT INTO allocation_audit VALUES (seq_allocation_audit.NEXTVAL, 10, 'INSERT', SYSDATE, 'Allocation record created for request 10.');

COMMIT;


// For Testing Purposes

SELECT COUNT(*) FROM regions;
SELECT COUNT(*) FROM drought_reports;
SELECT COUNT(*) FROM aid_items;
SELECT COUNT(*) FROM aid_inventory;
SELECT COUNT(*) FROM aid_requests;
SELECT COUNT(*) FROM aid_allocations;
SELECT COUNT(*) FROM allocation_audit;

SELECT * FROM vw_dashboard_summary;