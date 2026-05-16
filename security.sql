-- =====================================================
-- FREELANCER MARKETPLACE APP
-- SECURITY & PERFORMANCE MODULE
-- =====================================================

-- =====================================================
-- CREATE DATABASE
-- =====================================================

DROP DATABASE IF EXISTS freelancer_app;

CREATE DATABASE freelancer_app;

USE freelancer_app;

-- =====================================================
-- USERS TABLE
-- =====================================================

CREATE TABLE users (

    user_id INT AUTO_INCREMENT PRIMARY KEY,

    full_name VARCHAR(100) NOT NULL,

    username VARCHAR(50) UNIQUE NOT NULL,

    email VARCHAR(100) UNIQUE NOT NULL,

    password_hash VARCHAR(255) NOT NULL,

    role ENUM(
        'FREELANCER',
        'CLIENT',
        'ADMIN'
    ) DEFAULT 'CLIENT',

    skills TEXT,

    profile_image VARCHAR(255),

    bio TEXT,

    account_status ENUM(
        'ACTIVE',
        'BLOCKED',
        'SUSPENDED'
    ) DEFAULT 'ACTIVE',

    created_at TIMESTAMP
    DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- GIGS TABLE
-- =====================================================

CREATE TABLE gigs (

    gig_id INT AUTO_INCREMENT PRIMARY KEY,

    freelancer_id INT NOT NULL,

    gig_title VARCHAR(150) NOT NULL,

    gig_description TEXT NOT NULL,

    category VARCHAR(100),

    price DECIMAL(10,2) NOT NULL,

    delivery_days INT NOT NULL,

    gig_status ENUM(
        'ACTIVE',
        'PAUSED',
        'DELETED'
    ) DEFAULT 'ACTIVE',

    created_at TIMESTAMP
    DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (freelancer_id)
    REFERENCES users(user_id)
    ON DELETE CASCADE
);

-- =====================================================
-- ORDERS TABLE
-- =====================================================

CREATE TABLE orders (

    order_id INT AUTO_INCREMENT PRIMARY KEY,

    client_id INT NOT NULL,

    gig_id INT NOT NULL,

    quantity INT DEFAULT 1,

    total_amount DECIMAL(10,2) NOT NULL,

    order_status ENUM(
        'PENDING',
        'IN_PROGRESS',
        'COMPLETED',
        'CANCELLED'
    ) DEFAULT 'PENDING',

    order_date TIMESTAMP
    DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (client_id)
    REFERENCES users(user_id)
    ON DELETE CASCADE,

    FOREIGN KEY (gig_id)
    REFERENCES gigs(gig_id)
    ON DELETE CASCADE
);

-- =====================================================
-- PAYMENTS TABLE
-- =====================================================

CREATE TABLE payments (

    payment_id INT AUTO_INCREMENT PRIMARY KEY,

    order_id INT NOT NULL,

    payer_id INT NOT NULL,

    amount DECIMAL(10,2) NOT NULL,

    payment_method ENUM(
        'UPI',
        'CARD',
        'NET_BANKING',
        'WALLET'
    ) NOT NULL,

    transaction_id VARCHAR(255) UNIQUE NOT NULL,

    payment_status ENUM(
        'SUCCESS',
        'FAILED',
        'PENDING',
        'REFUNDED'
    ) DEFAULT 'PENDING',

    payment_date TIMESTAMP
    DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (order_id)
    REFERENCES orders(order_id)
    ON DELETE CASCADE,

    FOREIGN KEY (payer_id)
    REFERENCES users(user_id)
    ON DELETE CASCADE
);

-- =====================================================
-- REVIEWS TABLE
-- =====================================================

CREATE TABLE reviews (

    review_id INT AUTO_INCREMENT PRIMARY KEY,

    order_id INT NOT NULL,

    reviewer_id INT NOT NULL,

    rating INT NOT NULL,

    review_text TEXT,

    created_at TIMESTAMP
    DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (order_id)
    REFERENCES orders(order_id)
    ON DELETE CASCADE,

    FOREIGN KEY (reviewer_id)
    REFERENCES users(user_id)
    ON DELETE CASCADE
);

-- =====================================================
-- INDEXING FOR PERFORMANCE
-- =====================================================

CREATE INDEX idx_username
ON users(username);

CREATE INDEX idx_email
ON users(email);

CREATE INDEX idx_gig_title
ON gigs(gig_title);

CREATE INDEX idx_gig_category
ON gigs(category);

CREATE INDEX idx_order_status
ON orders(order_status);

CREATE INDEX idx_payment_status
ON payments(payment_status);

-- =====================================================
-- SAMPLE USERS
-- =====================================================

INSERT INTO users
(
    full_name,
    username,
    email,
    password_hash,
    role,
    skills
)

VALUES

(
    'Lohitha',
    'lohitha_designs',
    'lohitha@gmail.com',
    'hashed_password_123',
    'FREELANCER',
    'UI/UX Design, Figma'
),

(
    'Rahul',
    'rahul_client',
    'rahul@gmail.com',
    'hashed_password_456',
    'CLIENT',
    NULL
);

-- =====================================================
-- SAMPLE GIGS
-- =====================================================

INSERT INTO gigs
(
    freelancer_id,
    gig_title,
    gig_description,
    category,
    price,
    delivery_days
)

VALUES

(
    1,
    'Professional UI Design',
    'Modern mobile and website UI designs',
    'Design',
    5000,
    5
),

(
    1,
    'Logo Design',
    'Creative logo designs for startups',
    'Graphics',
    2000,
    2
);

-- =====================================================
-- SAMPLE ORDERS
-- =====================================================

INSERT INTO orders
(
    client_id,
    gig_id,
    total_amount
)

VALUES

(
    2,
    1,
    5000
);

-- =====================================================
-- SAMPLE PAYMENTS
-- =====================================================

INSERT INTO payments
(
    order_id,
    payer_id,
    amount,
    payment_method,
    transaction_id,
    payment_status
)

VALUES

(
    1,
    2,
    5000,
    'UPI',
    'TXN100001',
    'SUCCESS'
);

-- =====================================================
-- SAMPLE REVIEWS
-- =====================================================

INSERT INTO reviews
(
    order_id,
    reviewer_id,
    rating,
    review_text
)

VALUES

(
    1,
    2,
    5,
    'Amazing work and fast delivery'
);

-- =====================================================
-- SQL INJECTION PREVENTION
-- =====================================================

SET @username = 'lohitha_designs';

PREPARE secure_query
FROM 'SELECT * FROM users WHERE username = ?';

EXECUTE secure_query USING @username;

DEALLOCATE PREPARE secure_query;

-- =====================================================
-- STORED PROCEDURE : ADD USER
-- =====================================================

DELIMITER $$

CREATE PROCEDURE AddFreelancer(

    IN p_name VARCHAR(100),

    IN p_username VARCHAR(50),

    IN p_email VARCHAR(100),

    IN p_password VARCHAR(255),

    IN p_role VARCHAR(20),

    IN p_skills TEXT
)

BEGIN

    INSERT INTO users
    (
        full_name,
        username,
        email,
        password_hash,
        role,
        skills
    )

    VALUES
    (
        p_name,
        p_username,
        p_email,
        p_password,
        p_role,
        p_skills
    );

END $$

DELIMITER ;

-- =====================================================
-- VIEW ALL GIGS
-- =====================================================

SELECT

    g.gig_title,

    g.category,

    g.price,

    g.delivery_days,

    u.full_name AS freelancer

FROM gigs g

JOIN users u
ON g.freelancer_id = u.user_id;

-- =====================================================
-- VIEW ORDER DETAILS
-- =====================================================

SELECT

    o.order_id,

    c.full_name AS client_name,

    g.gig_title,

    o.total_amount,

    o.order_status

FROM orders o

JOIN users c
ON o.client_id = c.user_id

JOIN gigs g
ON o.gig_id = g.gig_id;

-- =====================================================
-- TOTAL PLATFORM REVENUE
-- =====================================================

SELECT

    SUM(amount)
    AS total_revenue

FROM payments

WHERE payment_status = 'SUCCESS';

-- =====================================================
-- TOP FREELANCERS
-- =====================================================

SELECT

    u.full_name,

    COUNT(g.gig_id)
    AS total_gigs

FROM users u

JOIN gigs g
ON u.user_id = g.freelancer_id

GROUP BY u.full_name

ORDER BY total_gigs DESC;

-- =====================================================
-- ACTIVE FREELANCERS VIEW
-- =====================================================

CREATE VIEW active_freelancers AS

SELECT

    user_id,

    full_name,

    username,

    skills

FROM users

WHERE role = 'FREELANCER'
AND account_status = 'ACTIVE';

-- =====================================================
-- DISPLAY ACTIVE FREELANCERS
-- =====================================================

SELECT *
FROM active_freelancers;