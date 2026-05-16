

USE scalable_app;


CREATE TABLE IF NOT EXISTS plans (

    plan_id INT AUTO_INCREMENT PRIMARY KEY,

    plan_name VARCHAR(50) NOT NULL,

    price DECIMAL(10,2) NOT NULL,

    duration_months INT NOT NULL,

    features TEXT,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);



CREATE TABLE IF NOT EXISTS subscriptions (

    subscription_id INT AUTO_INCREMENT PRIMARY KEY,

    user_id BIGINT NOT NULL,

    plan_id INT NOT NULL,

    start_date DATE NOT NULL,

    end_date DATE NOT NULL,

    status ENUM(
        'ACTIVE',
        'EXPIRED',
        'CANCELLED',
        'PENDING'
    ) DEFAULT 'ACTIVE',

    payment_status ENUM(
        'PAID',
        'UNPAID',
        'FAILED'
    ) DEFAULT 'UNPAID',

    auto_renew BOOLEAN DEFAULT FALSE,

    cancelled_at TIMESTAMP NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_subscription_user
    FOREIGN KEY (user_id)
    REFERENCES users(user_id)
    ON DELETE CASCADE,

    CONSTRAINT fk_subscription_plan
    FOREIGN KEY (plan_id)
    REFERENCES plans(plan_id)
    ON DELETE CASCADE
);


CREATE INDEX idx_subscriptions_user
ON subscriptions(user_id);

CREATE INDEX idx_subscriptions_status
ON subscriptions(status);



INSERT INTO plans
(plan_name, price, duration_months, features)

VALUES

(
    'Basic',
    199.00,
    1,
    'Ad Free Access'
),

(
    'Premium',
    499.00,
    3,
    'Priority Support + Analytics'
),

(
    'Enterprise',
    1999.00,
    12,
    'Full Business Features'
);



INSERT INTO subscriptions
(
    user_id,
    plan_id,
    start_date,
    end_date,
    status,
    payment_status
)

VALUES
(
    1,
    2,
    CURRENT_DATE,
    DATE_ADD(CURRENT_DATE, INTERVAL 3 MONTH),
    'ACTIVE',
    'PAID'
);


UPDATE subscriptions

SET
    plan_id = 3,
    start_date = CURRENT_DATE,
    end_date = DATE_ADD(CURRENT_DATE, INTERVAL 12 MONTH),
    payment_status = 'PAID'

WHERE user_id = 1
AND status = 'ACTIVE';



UPDATE subscriptions

SET
    plan_id = 1,
    start_date = CURRENT_DATE,
    end_date = DATE_ADD(CURRENT_DATE, INTERVAL 1 MONTH)

WHERE user_id = 1
AND status = 'ACTIVE';



SELECT

    s.subscription_id,
    u.username,
    u.email,
    p.plan_name,
    p.price,
    s.start_date,
    s.end_date,
    s.status

FROM subscriptions s

JOIN users u
ON s.user_id = u.user_id

JOIN plans p
ON s.plan_id = p.plan_id;


UPDATE subscriptions

SET
    status = 'CANCELLED',
    cancelled_at = CURRENT_TIMESTAMP

WHERE subscription_id = 1;



