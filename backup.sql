-- =====================================================
-- BACKUP & DOCUMENTATION MODULE
-- FREELANCER MARKETPLACE APP
-- =====================================================

USE freelancer_app;

-- =====================================================
-- 1. DATABASE BACKUP TABLES
-- =====================================================

-- USERS BACKUP

CREATE TABLE users_backup AS

SELECT *
FROM users;

-- GIGS BACKUP

CREATE TABLE gigs_backup AS

SELECT *
FROM gigs;

-- ORDERS BACKUP

CREATE TABLE orders_backup AS

SELECT *
FROM orders;

-- PAYMENTS BACKUP

CREATE TABLE payments_backup AS

SELECT *
FROM payments;

-- SUBSCRIPTIONS BACKUP

CREATE TABLE subscriptions_backup AS

SELECT *
FROM subscriptions;

-- =====================================================
-- 2. VERIFY BACKUP TABLES
-- =====================================================

SELECT * FROM users_backup;

SELECT * FROM gigs_backup;

SELECT * FROM orders_backup;

SELECT * FROM payments_backup;

SELECT * FROM subscriptions_backup;

-- =====================================================
-- 3. EXPORT DATABASE BACKUP COMMAND
-- =====================================================

-- Run this in CMD / Terminal

-- mysqldump -u root -p freelancer_app > freelancer_backup.sql

-- =====================================================
-- 4. RESTORE DATABASE COMMAND
-- =====================================================

-- Run this in CMD / Terminal

-- mysql -u root -p freelancer_app < freelancer_backup.sql

-- =====================================================
-- 5. SHOW ALL TABLES
-- =====================================================

SHOW TABLES;

-- =====================================================
-- 6. DOCUMENTATION : USERS TABLE
-- =====================================================

DESCRIBE users;

-- =====================================================
-- 7. DOCUMENTATION : GIGS TABLE
-- =====================================================

DESCRIBE gigs;

-- =====================================================
-- 8. DOCUMENTATION : ORDERS TABLE
-- =====================================================

DESCRIBE orders;

-- =====================================================
-- 9. DOCUMENTATION : PAYMENTS TABLE
-- =====================================================

DESCRIBE payments;

-- =====================================================
-- 10. DOCUMENTATION : SUBSCRIPTIONS TABLE
-- =====================================================

DESCRIBE subscriptions;

-- =====================================================
-- 11. DOCUMENTATION QUERY
-- =====================================================

SELECT

    TABLE_NAME,

    COLUMN_NAME,

    DATA_TYPE,

    IS_NULLABLE,

    COLUMN_KEY

FROM INFORMATION_SCHEMA.COLUMNS

WHERE TABLE_SCHEMA = 'freelancer_app';

-- =====================================================
-- 12. BACKUP CREATION DATE
-- =====================================================

SELECT
    NOW() AS backup_created_time;

-- =====================================================
-- 13. TOTAL DATABASE TABLES
-- =====================================================

SELECT
    COUNT(*) AS total_tables

FROM INFORMATION_SCHEMA.TABLES

WHERE TABLE_SCHEMA = 'freelancer_app';

-- =====================================================
-- 14. TABLE STORAGE INFORMATION
-- =====================================================

SELECT

    table_name,

    ROUND((data_length + index_length)/1024,2)
    AS table_size_kb

FROM information_schema.tables

WHERE table_schema = 'freelancer_app';

-- =====================================================
-- 15. VIEW DATABASE STATUS
-- =====================================================

SHOW TABLE STATUS;

-- =====================================================
-- 16. CREATE DATABASE DOCUMENTATION VIEW
-- =====================================================

CREATE VIEW database_documentation AS

SELECT

    TABLE_NAME,

    COLUMN_NAME,

    DATA_TYPE,

    COLUMN_KEY

FROM INFORMATION_SCHEMA.COLUMNS

WHERE TABLE_SCHEMA = 'freelancer_app';

-- =====================================================
-- 17. DISPLAY DOCUMENTATION VIEW
-- =====================================================

SELECT *
FROM database_documentation;

