

USE scalable_app;



SELECT
    user_id,
    username,
    email,
    password_hash,
    account_status
FROM users
WHERE email = 'divya@gmail.com';



UPDATE users
SET last_login = CURRENT_TIMESTAMP
WHERE user_id = 1;



INSERT INTO user_sessions
(
    user_id,
    session_token,
    expires_at
)

VALUES
(
    1,
    'jwt_token_generated_here',
    DATE_ADD(NOW(), INTERVAL 1 DAY)
);


SELECT *
FROM user_sessions
WHERE session_token = 'jwt_token_generated_here'
AND is_active = TRUE
AND expires_at > NOW();



UPDATE user_sessions
SET
    is_active = FALSE
WHERE session_token = 'jwt_token_generated_here';



INSERT INTO login_history
(
    user_id,
    ip_address,
    device_name,
    browser,
    os,
    login_status
)

VALUES
(
    1,
    '192.168.1.1',
    'Windows Laptop',
    'Chrome',
    'Windows 11',
    'SUCCESS'
);



INSERT INTO login_history
(
    user_id,
    ip_address,
    device_name,
    browser,
    os,
    login_status
)

VALUES
(
    1,
    '192.168.1.1',
    'Android Mobile',
    'Chrome',
    'Android',
    'FAILED'
);



INSERT INTO email_verifications
(
    user_id,
    verification_token,
    expires_at
)

VALUES
(
    1,
    'email_verification_token_123',
    DATE_ADD(NOW(), INTERVAL 10 MINUTE)
);



SELECT *
FROM email_verifications
WHERE verification_token =
'email_verification_token_123'
AND verified = FALSE
AND expires_at > NOW();



UPDATE users
SET is_verified = TRUE
WHERE user_id = 1;

UPDATE email_verifications
SET verified = TRUE
WHERE verification_token =
'email_verification_token_123';



INSERT INTO password_resets
(
    user_id,
    reset_token,
    expires_at
)

VALUES
(
    1,
    'reset_token_12345',
    DATE_ADD(NOW(), INTERVAL 15 MINUTE)
);


SELECT *
FROM password_resets
WHERE reset_token = 'reset_token_12345'
AND is_used = FALSE
AND expires_at > NOW();



UPDATE users
SET password_hash =
'$2b$10$newencryptedpassword'
WHERE user_id = 1;



UPDATE password_resets
SET is_used = TRUE
WHERE reset_token = 'reset_token_12345';




SELECT *
FROM users
WHERE user_id = 1
AND account_status = 'ACTIVE';



SELECT *
FROM users
WHERE email = 'divya@gmail.com'
AND is_verified = TRUE
AND account_status = 'ACTIVE';


DELETE FROM user_sessions
WHERE expires_at < NOW();




DELETE FROM password_resets
WHERE expires_at < NOW();



DELETE FROM email_verifications
WHERE expires_at < NOW();



SELECT
    user_id,
    COUNT(*) AS failed_attempts
FROM login_history
WHERE login_status = 'FAILED'
AND login_time >= NOW() - INTERVAL 1 HOUR
GROUP BY user_id
HAVING COUNT(*) >= 5;



UPDATE users
SET account_status = 'SUSPENDED'
WHERE user_id IN (

    SELECT user_id
    FROM (
        SELECT
            user_id,
            COUNT(*) AS failed_attempts
        FROM login_history
        WHERE login_status = 'FAILED'
        AND login_time >= NOW() - INTERVAL 1 HOUR
        GROUP BY user_id
        HAVING COUNT(*) >= 5
    ) suspicious_users
);


SELECT
    u.username,
    us.login_time,
    us.expires_at
FROM users u

JOIN user_sessions us
ON u.user_id = us.user_id

WHERE us.is_active = TRUE;



SELECT COUNT(*) AS active_sessions
FROM user_sessions
WHERE is_active = TRUE;


DELIMITER $$

CREATE TRIGGER update_last_login

AFTER INSERT ON login_history

FOR EACH ROW

BEGIN

    IF NEW.login_status = 'SUCCESS' THEN

        UPDATE users
        SET last_login = CURRENT_TIMESTAMP
        WHERE user_id = NEW.user_id;

    END IF;

END $$

DELIMITER ;



CREATE INDEX idx_session_token
ON user_sessions(session_token(255));

CREATE INDEX idx_reset_token
ON password_resets(reset_token(255));

CREATE INDEX idx_verification_token
ON email_verifications(verification_token(255));

CREATE INDEX idx_login_status
ON login_history(login_status);


CREATE VIEW verified_users AS

SELECT
    user_id,
    username,
    email,
    created_at

FROM users

WHERE is_verified = TRUE
AND account_status = 'ACTIVE';