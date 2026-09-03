-- ============================================================
-- Column Masking Setup for dev.gold.dim_customer
-- Run this script ONCE in a SQL editor or notebook BEFORE
-- running the pipeline that defines the MASK clause.
-- ============================================================

USE CATALOG dev;
USE SCHEMA gold;

-- 1. Authorized users table — users who can see unmasked PII
CREATE TABLE IF NOT EXISTS authorized_users (
  user_email STRING COMMENT 'Users authorized to view unmasked email and phone'
);

-- 2. Add authorized users (add more as needed)
INSERT INTO authorized_users (user_email)
SELECT 'adityakamodiya@cyntexa.com'
WHERE NOT EXISTS (
  SELECT 1 FROM authorized_users
  WHERE user_email = 'adityakamodiya@cyntexa.com'
);

-- 3. Grant SELECT so any user querying dim_customer can have
--    the mask UDF evaluate the authorized_users lookup
GRANT SELECT ON TABLE authorized_users TO `All Users`;

-- 4. Email mask: authorized users see full email, others see
--    first 2 chars + ****@****
CREATE OR REPLACE FUNCTION mask_email(email_val STRING)
RETURNS STRING
RETURN
  CASE
    WHEN EXISTS (
      SELECT 1 FROM authorized_users
      WHERE user_email = current_user()
    )
    THEN email_val
    ELSE CONCAT(SUBSTRING(email_val, 1, 2), '****@****')
  END;

-- 5. Phone mask: authorized users see full phone, others see 0
CREATE OR REPLACE FUNCTION mask_phone(phone_val LONG)
RETURNS LONG
RETURN
  CASE
    WHEN EXISTS (
      SELECT 1 FROM authorized_users
      WHERE user_email = current_user()
    )
    THEN phone_val
    ELSE 0
  END;

-- ============================================================
-- Alternative: Apply masks via ALTER TABLE after the MV exists
-- (CREATE OR REFRESH preserves MASK metadata across refreshes)
-- ============================================================
-- ALTER TABLE dev.gold.dim_customer
--   ALTER COLUMN email SET MASK dev.gold.mask_email;
--
-- ALTER TABLE dev.gold.dim_customer
--   ALTER COLUMN phone SET MASK dev.gold.mask_phone;
--
-- To remove masks later:
-- ALTER TABLE dev.gold.dim_customer
--   ALTER COLUMN email DROP MASK;
-- ALTER TABLE dev.gold.dim_customer
--   ALTER COLUMN phone DROP MASK;