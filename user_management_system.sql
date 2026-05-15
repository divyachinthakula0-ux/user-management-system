

DROP DATABASE IF EXISTS scalable_app;

CREATE DATABASE IF NOT EXISTS scalable_app;

USE scalable_app;


CREATE TABLE IF NOT EXISTS users (

    user_id BIGINT PRIMARY KEY AUTO_INCREMENT,

    first_name VARCHAR(50) NOT NULL,

    last_name VARCHAR(50) NOT NULL,

    username VARCHAR(50) UNIQUE NOT NULL,

    email VARCHAR(120) UNIQUE NOT NULL,

    phone VARCHAR(15) UNIQUE,

    password_hash VARCHAR(255) NOT NULL,

    profile_photo TEXT,

    gender ENUM('MALE','FEMALE','OTHER'),

    date_of_birth DATE,

    bio TEXT,

    role ENUM('USER','ADMIN','MODERATOR')
    DEFAULT 'USER',

    is_verified BOOLEAN DEFAULT FALSE,

    account_status ENUM(
        'ACTIVE',
        'BLOCKED',
        'SUSPENDED',
        'DELETED'
    ) DEFAULT 'ACTIVE',

    last_login TIMESTAMP NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    ON UPDATE CURRENT_TIMESTAMP
);



CREATE TABLE IF NOT EXISTS user_settings (

    setting_id BIGINT PRIMARY KEY AUTO_INCREMENT,

    user_id BIGINT NOT NULL,

    email_notifications BOOLEAN DEFAULT TRUE,

    sms_notifications BOOLEAN DEFAULT FALSE,

    dark_mode BOOLEAN DEFAULT FALSE,

    language VARCHAR(30) DEFAULT 'English',

    timezone VARCHAR(50) DEFAULT 'Asia/Kolkata',

    privacy_mode BOOLEAN DEFAULT FALSE,

    FOREIGN KEY (user_id)
    REFERENCES users(user_id)
    ON DELETE CASCADE
);



CREATE TABLE IF NOT EXISTS login_history (

    login_id BIGINT PRIMARY KEY AUTO_INCREMENT,

    user_id BIGINT NOT NULL,

    login_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    logout_time TIMESTAMP NULL,

    ip_address VARCHAR(50),

    device_name VARCHAR(255),

    browser VARCHAR(100),

    os VARCHAR(100),

    login_status ENUM(
        'SUCCESS',
        'FAILED'
    ),

    FOREIGN KEY (user_id)
    REFERENCES users(user_id)
    ON DELETE CASCADE
);



CREATE TABLE IF NOT EXISTS password_resets (

    reset_id BIGINT PRIMARY KEY AUTO_INCREMENT,

    user_id BIGINT NOT NULL,

    reset_token VARCHAR(255) NOT NULL,

    expires_at TIMESTAMP NOT NULL,

    is_used BOOLEAN DEFAULT FALSE,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id)
    REFERENCES users(user_id)
    ON DELETE CASCADE
);



CREATE TABLE IF NOT EXISTS email_verifications (

    verification_id BIGINT PRIMARY KEY AUTO_INCREMENT,

    user_id BIGINT NOT NULL,

    verification_token VARCHAR(255) NOT NULL,

    expires_at TIMESTAMP NOT NULL,

    verified BOOLEAN DEFAULT FALSE,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id)
    REFERENCES users(user_id)
    ON DELETE CASCADE
);



CREATE TABLE IF NOT EXISTS user_sessions (

    session_id BIGINT PRIMARY KEY AUTO_INCREMENT,

    user_id BIGINT NOT NULL,

    session_token TEXT NOT NULL,

    login_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    expires_at TIMESTAMP NOT NULL,

    is_active BOOLEAN DEFAULT TRUE,

    FOREIGN KEY (user_id)
    REFERENCES users(user_id)
    ON DELETE CASCADE
);




CREATE TABLE IF NOT EXISTS premium_plans (

    plan_id BIGINT PRIMARY KEY AUTO_INCREMENT,

    plan_name VARCHAR(100) NOT NULL,

    description TEXT,

    price DECIMAL(10,2) NOT NULL,

    duration_days INT NOT NULL,

    features TEXT,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);



CREATE TABLE IF NOT EXISTS user_subscriptions (

    subscription_id BIGINT PRIMARY KEY AUTO_INCREMENT,

    user_id BIGINT NOT NULL,

    plan_id BIGINT NOT NULL,

    start_date DATE NOT NULL,

    end_date DATE NOT NULL,

    payment_status ENUM(
        'PENDING',
        'PAID',
        'FAILED'
    ) DEFAULT 'PENDING',

    subscription_status ENUM(
        'ACTIVE',
        'EXPIRED',
        'CANCELLED'
    ) DEFAULT 'ACTIVE',

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id)
    REFERENCES users(user_id)
    ON DELETE CASCADE,

    FOREIGN KEY (plan_id)
    REFERENCES premium_plans(plan_id)
);



CREATE TABLE IF NOT EXISTS payments (

    payment_id BIGINT PRIMARY KEY AUTO_INCREMENT,

    user_id BIGINT NOT NULL,

    subscription_id BIGINT NOT NULL,

    amount DECIMAL(10,2) NOT NULL,

    payment_method ENUM(
        'UPI',
        'CARD',
        'NETBANKING',
        'WALLET'
    ),

    transaction_id VARCHAR(255) UNIQUE NOT NULL,

    payment_status ENUM(
        'SUCCESS',
        'FAILED',
        'PENDING',
        'REFUNDED'
    ) DEFAULT 'PENDING',

    paid_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id)
    REFERENCES users(user_id)
    ON DELETE CASCADE,

    FOREIGN KEY (subscription_id)
    REFERENCES user_subscriptions(subscription_id)
    ON DELETE CASCADE
);



CREATE TABLE IF NOT EXISTS security_logs (

    log_id BIGINT PRIMARY KEY AUTO_INCREMENT,

    user_id BIGINT,

    activity TEXT,

    ip_address VARCHAR(50),

    user_agent TEXT,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id)
    REFERENCES users(user_id)
    ON DELETE SET NULL
);


CREATE TABLE IF NOT EXISTS analytics_reports (

    report_id BIGINT PRIMARY KEY AUTO_INCREMENT,

    total_users INT DEFAULT 0,

    active_users INT DEFAULT 0,

    premium_users INT DEFAULT 0,

    total_revenue DECIMAL(15,2) DEFAULT 0,

    generated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);



CREATE INDEX idx_users_email
ON users(email);

CREATE INDEX idx_users_username
ON users(username);

CREATE INDEX idx_users_phone
ON users(phone);

CREATE INDEX idx_users_status
ON users(account_status);

CREATE INDEX idx_login_history_user
ON login_history(user_id);

CREATE INDEX idx_payments_user
ON payments(user_id);

CREATE INDEX idx_subscription_user
ON user_subscriptions(user_id);



INSERT INTO premium_plans
(plan_name, description, price, duration_days, features)

VALUES

(
    'Basic Plan',
    'Access to standard premium features',
    199.00,
    30,
    'No Ads, Faster Support'
),

(
    'Pro Plan',
    'Advanced premium access',
    499.00,
    90,
    'Priority Support, Analytics, Unlimited Access'
),

(
    'Enterprise Plan',
    'Complete enterprise package',
    1999.00,
    365,
    'Dedicated Manager, Advanced Security'
);


CREATE VIEW active_users AS

SELECT
    user_id,
    username,
    email,
    role,
    created_at

FROM users

WHERE account_status = 'ACTIVE';



DELIMITER $$

CREATE PROCEDURE GetUserProfile(IN uid BIGINT)

BEGIN

    SELECT
        user_id,
        first_name,
        last_name,
        username,
        email,
        phone,
        role,
        account_status,
        created_at

    FROM users

    WHERE user_id = uid;

END $$

DELIMITER ;


DELIMITER $$

CREATE TRIGGER create_default_settings

AFTER INSERT ON users

FOR EACH ROW

BEGIN

    INSERT INTO user_settings(user_id)

    VALUES (NEW.user_id);

END $$

DELIMITER ;



CREATE TABLE IF NOT EXISTS users_backup AS

SELECT * FROM users;


INSERT INTO users
(
    first_name,
    last_name,
    username,
    email,
    phone,
    password_hash
)

VALUES
(
    'Divya',
    'Chinthakula',
    'divya_01',
    'divya@gmail.com',
    '9876543210',
    '$2b$10$encryptedpassword'
);




INSERT INTO user_subscriptions
(
    user_id,
    plan_id,
    start_date,
    end_date,
    payment_status,
    subscription_status
)

VALUES
(
    1,
    1,
    '2026-05-15',
    '2026-06-15',
    'PAID',
    'ACTIVE'
);



SELECT *
FROM users
WHERE email = 'divya@gmail.com'
AND account_status = 'ACTIVE';



UPDATE users

SET
    bio = 'Software Developer',
    profile_photo = 'profile.jpg'

WHERE user_id = 1;



SELECT COUNT(*) AS total_users
FROM users;



SELECT SUM(amount) AS total_revenue
FROM payments
WHERE payment_status = 'SUCCESS';


SELECT
    u.username,
    p.plan_name,
    us.end_date

FROM users u

JOIN user_subscriptions us
ON u.user_id = us.user_id

JOIN premium_plans p
ON us.plan_id = p.plan_id

WHERE us.subscription_status = 'ACTIVE';