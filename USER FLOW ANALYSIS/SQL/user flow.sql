select *
from dbo.user_flow

--funnel summary
SELECT
    COUNT(*) AS total_signups,
    SUM(CASE WHEN email_verified_date IS NOT NULL THEN 1 ELSE 0 END) AS verified_users,
    SUM(CASE WHEN account_created_date IS NOT NULL THEN 1 ELSE 0 END) AS activated_users,
    SUM(CASE WHEN first_transaction_date IS NOT NULL THEN 1 ELSE 0 END) AS transacting_users
FROM dbo.user_flow

--conversion rates
SELECT
    ROUND(100.0 * SUM(CASE WHEN email_verified_date IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*), 2) AS email_verification_rate,
    ROUND(100.0 * SUM(CASE WHEN account_created_date IS NOT NULL THEN 1 ELSE 0 END) / SUM(CASE WHEN email_verified_date IS NOT NULL THEN 1 ELSE 0 END), 2) AS account_creation_rate,
    ROUND(100.0 * SUM(CASE WHEN first_transaction_date IS NOT NULL THEN 1 ELSE 0 END) / SUM(CASE WHEN account_created_date IS NOT NULL THEN 1 ELSE 0 END), 2) AS transaction_rate
FROM dbo.user_flow

--funnel breakdown by marketing source
SELECT
    signup_channel,
    COUNT(*) AS total_users,
    SUM(CASE WHEN email_verified_date IS NOT NULL THEN 1 ELSE 0 END) AS verified_users,
    SUM(CASE WHEN account_created_date IS NOT NULL THEN 1 ELSE 0 END) AS activated_users,
    SUM(CASE WHEN first_transaction_date IS NOT NULL THEN 1 ELSE 0 END) AS transacting_users,
    ROUND(100.0 * SUM(CASE WHEN first_transaction_date IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*), 2) AS conversion_rate
FROM dbo.user_flow
GROUP BY signup_channel
ORDER BY conversion_rate DESC;

--funnel breakdown by country
SELECT
    country,
    COUNT(*) AS total_users,
    SUM(CASE WHEN email_verified_date IS NOT NULL THEN 1 ELSE 0 END) AS verified_users,
    SUM(CASE WHEN account_created_date IS NOT NULL THEN 1 ELSE 0 END) AS activated_users,
    SUM(CASE WHEN first_transaction_date IS NOT NULL THEN 1 ELSE 0 END) AS transacting_users,
    ROUND(100.0 * SUM(CASE WHEN first_transaction_date IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*), 2) AS conversion_rate
FROM dbo.user_flow
GROUP BY country
ORDER BY conversion_rate DESC;

--daily signup trend
SELECT
    CAST(signup_date AS DATE) AS signup_day,
    COUNT(*) AS total_signups,
    SUM(CASE WHEN account_created_date IS NOT NULL THEN 1 ELSE 0 END) AS activated_users,
    SUM(CASE WHEN first_transaction_date IS NOT NULL THEN 1 ELSE 0 END) AS transacting_users
FROM dbo.user_flow
GROUP BY CAST(signup_date AS DATE)
ORDER BY signup_day;

--average time between sign up and first transactions
SELECT
    ROUND(AVG(DATEDIFF(DAY, signup_date, first_transaction_date)), 2) AS avg_days_to_transaction
FROM dbo.user_flow
WHERE first_transaction_date IS NOT NULL;

--where users drop off
SELECT
    COUNT(*) AS total_users,
    COUNT(CASE WHEN email_verified_date IS NULL THEN 1 END) AS dropped_after_signup,
    COUNT(CASE WHEN email_verified_date IS NOT NULL AND account_created_date IS NULL THEN 1 END) AS dropped_after_verification,
    COUNT(CASE WHEN account_created_date IS NOT NULL AND first_transaction_date IS NULL THEN 1 END) AS dropped_after_activation
FROM dbo.user_flow;
















