-- Databricks notebook source
select * from  dev.gold.authorized_users
-- update dev.gold.authorized_users set email ='ajay@ex.com'

-- COMMAND ----------

select current_user() as user

-- COMMAND ----------

select * from dev.gold.dim_customer

-- COMMAND ----------

create table if not exists  dev.gold.authorized_users(email string);

-- insert into dev.gold.authorized_users values('adityakamodiya@cyntexa.com');



-- select * from dev.gold.authorized_users


-- COMMAND ----------

select * from dev.gold.authorized_users

-- COMMAND ----------

create or replace function dev.gold.email_masked(email string) returns string 

return   case
 when current_user() in (select email from dev.gold.authorized_users) then  email 
 else '***@**.com' end;


-- COMMAND ----------

create or replace function dev.gold .phone_masked(phone bigint) returns bigint 

return   case
 when current_user() in (select email from dev.gold.authorized_users) then  phone 
 else 1111111111 end;


-- COMMAND ----------

-- DBTITLE 1,Apply column masks via ALTER TABLE
select * from dev.gold.month_wise_transaction_value

-- COMMAND ----------



-- COMMAND ----------

desc table dev.silver.silver_customers

-- COMMAND ----------

select sum(amount) as total_value   from dev.silver.silver_transactions 
where transaction_status ='completed'


-- COMMAND ----------


select  concat(year(transaction_date) ,'-',  month(transaction_date)) as month , sum(amount) from dev.gold.dim_transactions 
group by  year(transaction_date) , month(transaction_date);

-- COMMAND ----------

desc table dev.bronze.branches_bronze

-- COMMAND ----------

select branch_status from dev.bronze.branches_bronze group by branch_status

-- COMMAND ----------

desc table dev.bronze.transactions_bronze

-- COMMAND ----------

select transaction_type from  dev.bronze.transactions_bronze group by transaction_type;

-- COMMAND ----------

desc table  dev.bronze.accounts_bronze;

-- desc table dev.bronze.customers_bronze;


-- COMMAND ----------

select account_tier from dev.bronze.accounts_bronze group by account_tier;

-- COMMAND ----------

desc table dev.bronze.customers_bronze;

-- COMMAND ----------

select * from dev.silver.silver_customers;

-- COMMAND ----------

select * from dev.bronze.accounts_bronze limit 20 ;

-- COMMAND ----------

select * from dev.bronze.transactions_bronze limit 20 ;

-- COMMAND ----------

select * from dev.bronze.branches_bronze limit 20 ;