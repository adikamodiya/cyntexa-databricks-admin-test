
--  silver customers ===========================================================
CREATE TEMPORARY VIEW customer_cleaned_v(
  CONSTRAINT valid_customer_id
    EXPECT (customer_id IS NOT NULL)
    ON VIOLATION DROP ROW,

  CONSTRAINT valid_email
    EXPECT (email IS NOT NULL AND email LIKE '%@%.%')
    ON VIOLATION DROP ROW,

  CONSTRAINT valid_date_of_birth
    EXPECT (date_of_birth IS NOT NULL)
    ON VIOLATION DROP ROW,

  CONSTRAINT valid_registration_date
    EXPECT (registration_date IS NOT NULL)
    ON VIOLATION DROP ROW,

  CONSTRAINT valid_updated_at
    EXPECT (updated_at IS NOT NULL)
    ON VIOLATION DROP ROW
    ,

      CONSTRAINT valid_postal_code
    EXPECT (postal_code >0)
    ON VIOLATION DROP ROW

)
AS
SELECT 
  TRIM(customer_id) AS customer_id,
  TRIM(LOWER(first_name)) AS first_name,
  TRIM(LOWER(last_name)) AS last_name,
  try_cast(date_of_birth AS DATE) AS date_of_birth,
  LOWER(TRIM(email)) AS email,
  phone,
  TRIM(address) AS address,
  TRIM(LOWER(city)) AS city,
  TRIM(LOWER(state)) AS state,
  postal_code,
  TRIM(customer_segment) AS customer_segment,
  TRIM(customer_status) AS customer_status,
  COALESCE(
    try_to_date(registration_date , "yyyy-MM-dd"),
        try_to_date(registration_date , "MM-yyyy-dd")
  ) as registration_date,
  COALESCE(
    try_to_date(updated_at , "yyyy-MM-dd"),
        try_to_date(updated_at , "MM-yyyy-dd")
  ) as updated_at
FROM STREAM(dev.bronze.customers_bronze)
WHERE (registration_date IS NOT NULL) OR (updated_at IS NOT NULL);




create or refresh streaming table dev.silver.silver_customers ;

apply changes into dev.silver.silver_customers
from STREAM(customer_cleaned_v)
keys(customer_id)
sequence by updated_at
stored as scd type 1;

--  ===============================================================================================================


--  silver Accounts =====================================================


create or refresh streaming table dev.silver.silver_accounts(
  CONSTRAINT valid_account_id
    EXPECT (account_id IS NOT NULL)
    ON VIOLATION DROP ROW,

  CONSTRAINT valid_customer_id
    EXPECT (customer_id IS NOT NULL),

  CONSTRAINT valid_account_status
    EXPECT (account_status IS NOT NULL AND LOWER(account_status) IN ("active", "closed", "dormant")),
    
    
    CONSTRAINT valid_account_type 
    EXPECT(account_type IS NOT NULL AND LOWER(account_type) IN ("savings", "current", "salary", "business")),

        CONSTRAINT valid_account_tier 
    EXPECT(account_tier IS NOT NULL AND LOWER(account_tier) IN ("premium", "standard"))


)
as
select 
TRIM(account_id) as account_id,
TRIM(a.customer_id) as customer_id,
branch_id  ,
TRIM(LOWER(account_type)) as account_type,
TRIM(LOWER(account_status)) as account_status,
COALESCE(
    try_to_date(opening_date , "yyyy-MM-dd"),
    try_to_date(opening_date , "MM-yyyy-dd")
  ) as opening_date,

try_cast(closing_date AS DATE) as closing_date,
TRIM(UPPER(currency)) as currency,
TRIM(LOWER(account_tier)) as account_tier,
COALESCE (
  try_cast(interest_rate as DOUBLE)
) as interest_rate,

COALESCE(
    try_to_date(a.updated_at , "yyyy-MM-dd"),
        try_to_date(a.updated_at , "MM-yyyy-dd")
  ) as updated_at

from STREAM(dev.bronze.accounts_bronze)  a
inner join  STREAM(dev.silver.silver_customers) c
on a.customer_id = c.customer_id

where (opening_date IS NOT NULL)  OR (a.updated_at IS NOT NULL) or (interest_rate IS NOT NULL and interest_rate >=0 );



 

-- apply changes into dev.silver.silver_accounts
-- from STREAM(accounts_cleaned_v)
-- keys(account_id)
-- sequence by updated_at
-- stored as scd type 1;



-- ==============================================
--  transactions silver


CREATE OR REFRESH STREAMING TABLE dev.silver.silver_transactions(
  CONSTRAINT valid_transaction_id
    EXPECT (transaction_id IS NOT NULL)
    ON VIOLATION DROP ROW,

  CONSTRAINT valid_account_id
    EXPECT (account_id IS NOT NULL)
    ON VIOLATION DROP ROW,
  
  CONSTRAINT valid_transaction_date
    EXPECT (transaction_date IS NOT NULL)
    ON VIOLATION DROP ROW,
    
      CONSTRAINT valid_transaction_timestamp
    EXPECT (transaction_timestamp IS NOT NULL)
    ON VIOLATION DROP ROW ,

      CONSTRAINT valid_amount
    EXPECT (try_cast(amount AS DOUBLE) IS NOT NULL AND amount >= 0)
    ON VIOLATION DROP ROW,

  CONSTRAINT valid_transaction_type
    EXPECT (transaction_type IS NOT NULL AND LOWER(transaction_type) IN ( "payment", "deposit", "withdrawal", "transfer", "interest credit", "fee"))
     ON VIOLATION DROP ROW


)
as
SELECT 
  TRIM(t.transaction_id) AS transaction_id,
  TRIM(t.account_id) AS account_id,
  COALESCE(
    try_to_date(t.transaction_date, "yyyy-MM-dd"),
    try_to_date(t.transaction_date, "MM-yyyy-dd")
  ) AS transaction_date,
  try_cast(t.transaction_timestamp AS TIMESTAMP) AS transaction_timestamp,
  TRIM(LOWER(t.transaction_type)) AS transaction_type,
  TRIM(LOWER(t.transaction_channel)) AS transaction_channel,
  t.amount,
  TRIM(UPPER(t.currency)) AS currency,
  TRIM(merchant_name) AS merchant_name,
  TRIM(LOWER(merchant_category)) AS merchant_category,
  TRIM(LOWER(t.transaction_status)) AS transaction_status,
  TRIM(t.reference_number) AS reference_number,
  COALESCE(
    try_to_date(t.created_at, "yyyy-MM-dd"),
    try_to_date(t.created_at, "MM-yyyy-dd")
  ) AS created_at
FROM STREAM(dev.bronze.transactions_bronze) t
inner join STREAM(dev.silver.silver_accounts) a
on t.account_id = a.account_id
WHERE (transaction_date IS NOT NULL) OR (created_at IS NOT NULL);





-- APPLY CHANGES INTO dev.silver.silver_transactions
-- FROM STREAM(transactions_cleaned_v)
-- KEYS(transaction_id)
-- SEQUENCE BY created_at
-- STORED AS SCD TYPE 1;

-- ========================================================================


-- silver branches ==================================================

CREATE OR REFRESH STREAMING TABLE dev.silver.silver_branches 
(
  CONSTRAINT valid_branch_id
    EXPECT (branch_id IS NOT NULL)
    ON VIOLATION DROP ROW,

  CONSTRAINT valid_branch_code
    EXPECT (branch_code IS NOT NULL)
    ON VIOLATION DROP ROW,

  CONSTRAINT valid_opening_date
    EXPECT (opening_date IS NOT NULL)
    ON VIOLATION DROP ROW,

  CONSTRAINT valid_branch_type
    EXPECT (branch_type IS NOT NULL AND LOWER(branch_type) IN ("metro", "urban", "semi urban", "rural"))
    ON VIOLATION DROP ROW,

  CONSTRAINT valid_branch_status
    EXPECT (branch_status IS NOT NULL AND LOWER(branch_status) IN ("active", "closed"))
    ON VIOLATION DROP ROW
)
AS
SELECT 
  TRIM(b.branch_id) AS branch_id,
  TRIM(UPPER(b.branch_code)) AS branch_code,
  TRIM(b.branch_name) AS branch_name,
  TRIM(LOWER(b.city)) AS city,
  TRIM(LOWER(b.state)) AS state,
  TRIM(LOWER(b.region)) AS region,
  TRIM(LOWER(b.branch_type)) AS branch_type,
  TRIM(b.manager_name) AS manager_name,
  TRIM(LOWER(b.branch_status)) AS branch_status,
  COALESCE(
    try_to_date(b.opening_date, "yyyy-MM-dd"),
    try_to_date(b.opening_date, "MM-yyyy-dd")
  ) AS opening_date

FROM STREAM(dev.bronze.branches_bronze) b
    inner join STREAM(dev.silver.silver_accounts) a
    on b.branch_id = a.branch_id
WHERE (b.opening_date IS NOT NULL);







