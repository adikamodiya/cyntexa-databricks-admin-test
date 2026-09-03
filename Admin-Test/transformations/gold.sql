--  Task 6 =======================================

--  dim_customer ==============================================
CREATE OR REFRESH MATERIALIZED VIEW dev.gold.dim_customer
AS
SELECT
  customer_id,
  CONCAT_WS(' ', first_name, last_name) AS full_name,
  first_name,
  last_name,
  date_of_birth,
  dev.gold.email_masked(email) AS email,
  dev.gold.phone_masked(phone) AS phone,
  address,
  city,
  state,
  postal_code,
  customer_segment,
  customer_status,
  CASE WHEN customer_status = 'active' THEN true ELSE false END AS is_active,
  registration_date,
  updated_at
FROM dev.silver.silver_customers;

--  dim_account ================================================
CREATE OR REFRESH MATERIALIZED VIEW dev.gold.dim_account
AS
SELECT
  account_id,
  customer_id,
  branch_id,
  account_type,
  account_status,
  opening_date,
  closing_date,
  currency,
  account_tier,
  interest_rate,
  CASE
    WHEN closing_date IS NOT NULL THEN 'closed'
    WHEN account_status = 'dormant' THEN 'dormant'
    ELSE 'active'
  END AS account_lifecycle_status,
  updated_at
FROM dev.silver.silver_accounts;

--  dim_transactions ===========================================

CREATE OR REFRESH MATERIALIZED VIEW dev.gold.dim_transactions
AS
SELECT
  transaction_id,
  account_id,
  transaction_date,
  transaction_timestamp,
  transaction_type,
  transaction_channel,
  amount,
  currency,
  merchant_name,
  merchant_category,
  transaction_status,
  reference_number,
  created_at,
  CASE
    WHEN amount >= 10000 THEN 'high_value'
    WHEN amount >= 1000 THEN 'medium_value'
    ELSE 'low_value'
  END AS transaction_value_bucket,
  dayofweek(transaction_date) AS transaction_day_of_week,
  CASE WHEN transaction_status = 'success' THEN true ELSE false END AS is_successful
FROM dev.silver.silver_transactions;

--  dim_branch =================================================
CREATE OR REFRESH MATERIALIZED VIEW dev.gold.dim_branch

AS
SELECT
  branch_id,
  branch_code,
  branch_name,
  city,
  state,
  region,
  branch_type,
  manager_name,
  branch_status,
  CASE WHEN branch_status = 'active' THEN true ELSE false END AS is_active,
  opening_date
FROM dev.silver.silver_branches;


-- Task 7 =====================================================================

--  Total transaction value
CREATE OR REFRESH MATERIALIZED VIEW dev.gold.total_transaction_value
select sum(amount) as total_value   from dev.gold.dim_transactions 
where transaction_status ='completed';


--  total transactions count
CREATE OR REFRESH MATERIALIZED VIEW dev.gold.successfull_transactions_count
select count(*) as total_transactions   from dev.gold.dim_transactions 
where transaction_status ='completed';


--  total transaction value by type
CREATE OR REFRESH MATERIALIZED VIEW dev.gold.total_transaction_value_by_type
AS
select transaction_type , sum(amount) as total from dev.gold.dim_transactions 
group by transaction_type  having transaction_type in ('withdrawal','deposit');


--  total transaction value monthwise
CREATE OR REFRESH MATERIALIZED VIEW dev.gold.month_wise_transaction_value 
AS
select  concat(year(transaction_date) ,'-',  month(transaction_date)) as month , sum(amount) as total_amount from dev.gold.dim_transactions 
group by  year(transaction_date) , month(transaction_date);



--  Task 8 ======================================================






