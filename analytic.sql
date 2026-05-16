-- =====================================================
-- SUBSCRIPTIONS TABLE
-- =====================================================

CREATE TABLE subscriptions (

    subscription_id INT AUTO_INCREMENT PRIMARY KEY,

    user_id INT NOT NULL,

    plan_name VARCHAR(100) NOT NULL,

    price DECIMAL(10,2) NOT NULL,

    start_date DATE NOT NULL,

    end_date DATE NOT NULL,

    status ENUM(
        'ACTIVE',
        'EXPIRED',
        'CANCELLED'
    ) DEFAULT 'ACTIVE',

    created_at TIMESTAMP
    DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id)
    REFERENCES users(user_id)
    ON DELETE CASCADE
);

-- =====================================================
-- SAMPLE SUBSCRIPTIONS
-- =====================================================

INSERT INTO subscriptions
(
    user_id,
    plan_name,
    price,
    start_date,
    end_date,
    status
)

VALUES

(
    1,
    'Premium Freelancer',
    999,
    CURRENT_DATE,
    DATE_ADD(CURRENT_DATE, INTERVAL 1 MONTH),
    'ACTIVE'
),

(
    2,
    'Client Pro',
    499,
    CURRENT_DATE,
    DATE_ADD(CURRENT_DATE, INTERVAL 1 MONTH),
    'ACTIVE'
);
-- =====================================================
-- ANALYTICS & REPORTS MODULE
-- FREELANCER MARKETPLACE APP
-- =====================================================

USE freelancer_app;

-- =====================================================
-- 1. TOTAL USERS
-- =====================================================

SELECT
    COUNT(*) AS total_users
FROM users;

-- =====================================================
-- 2. TOTAL FREELANCERS
-- =====================================================

SELECT
    COUNT(*) AS total_freelancers
FROM users
WHERE role = 'FREELANCER';

-- =====================================================
-- 3. TOTAL CLIENTS
-- =====================================================

SELECT
    COUNT(*) AS total_clients
FROM users
WHERE role = 'CLIENT';

-- =====================================================
-- 4. ACTIVE USERS
-- =====================================================

SELECT
    COUNT(*) AS active_users
FROM users
WHERE account_status = 'ACTIVE';

-- =====================================================
-- 5. TOTAL GIGS
-- =====================================================

SELECT
    COUNT(*) AS total_gigs
FROM gigs;

-- =====================================================
-- 6. ACTIVE GIGS
-- =====================================================

SELECT
    COUNT(*) AS active_gigs
FROM gigs
WHERE gig_status = 'ACTIVE';

-- =====================================================
-- 7. TOTAL ORDERS
-- =====================================================

SELECT
    COUNT(*) AS total_orders
FROM orders;

-- =====================================================
-- 8. COMPLETED ORDERS
-- =====================================================

SELECT
    COUNT(*) AS completed_orders
FROM orders
WHERE order_status = 'COMPLETED';

-- =====================================================
-- 9. PENDING ORDERS
-- =====================================================

SELECT
    COUNT(*) AS pending_orders
FROM orders
WHERE order_status = 'PENDING';

-- =====================================================
-- 10. TOTAL REVENUE
-- =====================================================

SELECT
    SUM(amount) AS total_revenue
FROM payments
WHERE payment_status = 'SUCCESS';

-- =====================================================
-- 11. MONTHLY REVENUE
-- =====================================================

SELECT

    MONTH(payment_date) AS month,

    YEAR(payment_date) AS year,

    SUM(amount) AS monthly_revenue

FROM payments

WHERE payment_status = 'SUCCESS'

GROUP BY
    YEAR(payment_date),
    MONTH(payment_date)

ORDER BY year, month;

-- =====================================================
-- 12. FAILED PAYMENTS
-- =====================================================

SELECT
    COUNT(*) AS failed_payments
FROM payments
WHERE payment_status = 'FAILED';

-- =====================================================
-- 13. ACTIVE SUBSCRIPTIONS
-- =====================================================

SELECT
    COUNT(*) AS active_subscriptions
FROM subscriptions
WHERE status = 'ACTIVE';

-- =====================================================
-- 14. EXPIRED SUBSCRIPTIONS
-- =====================================================

SELECT
    COUNT(*) AS expired_subscriptions
FROM subscriptions
WHERE status = 'EXPIRED';

-- =====================================================
-- 15. TOP EARNING FREELANCERS
-- =====================================================

SELECT

    u.full_name,

    SUM(o.total_amount) AS total_earnings

FROM users u

JOIN gigs g
ON u.user_id = g.freelancer_id

JOIN orders o
ON g.gig_id = o.gig_id

WHERE o.order_status = 'COMPLETED'

GROUP BY u.full_name

ORDER BY total_earnings DESC;

-- =====================================================
-- 16. MOST ORDERED GIGS
-- =====================================================

SELECT

    g.gig_title,

    COUNT(o.order_id) AS total_orders

FROM gigs g

JOIN orders o
ON g.gig_id = o.gig_id

GROUP BY g.gig_title

ORDER BY total_orders DESC;

-- =====================================================
-- 17. USER ORDER HISTORY
-- =====================================================

SELECT

    u.full_name,

    g.gig_title,

    o.total_amount,

    o.order_status,

    o.order_date

FROM orders o

JOIN users u
ON o.client_id = u.user_id

JOIN gigs g
ON o.gig_id = g.gig_id

ORDER BY o.order_date DESC;

-- =====================================================
-- 18. AVERAGE GIG PRICE
-- =====================================================

SELECT
    AVG(price) AS average_gig_price
FROM gigs;

-- =====================================================
-- 19. HIGHEST PAYMENT
-- =====================================================

SELECT
    MAX(amount) AS highest_payment
FROM payments;

-- =====================================================
-- 20. LOWEST PAYMENT
-- =====================================================

SELECT
    MIN(amount) AS lowest_payment
FROM payments;

-- =====================================================
-- 21. DAILY USER REGISTRATIONS
-- =====================================================

SELECT

    DATE(created_at) AS registration_date,

    COUNT(*) AS total_registrations

FROM users

GROUP BY DATE(created_at)

ORDER BY registration_date DESC;

-- =====================================================
-- 22. PLATFORM SUMMARY REPORT
-- =====================================================

SELECT

(
    SELECT COUNT(*) FROM users
) AS total_users,

(
    SELECT COUNT(*) FROM gigs
) AS total_gigs,

(
    SELECT COUNT(*) FROM orders
) AS total_orders,

(
    SELECT SUM(amount)
    FROM payments
    WHERE payment_status = 'SUCCESS'
) AS total_revenue;

-- =====================================================
-- 23. ACTIVE FREELANCERS VIEW
-- =====================================================

CREATE VIEW active_freelancers_report AS

SELECT

    user_id,

    full_name,

    username,

    skills

FROM users

WHERE role = 'FREELANCER'
AND account_status = 'ACTIVE';

-- =====================================================
-- 24. DISPLAY ACTIVE FREELANCERS
-- =====================================================

SELECT *
FROM active_freelancers_report;