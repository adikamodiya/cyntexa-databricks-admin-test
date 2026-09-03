
--  customers ingestion-----------

create or refresh streaming table dev.bronze.customers_bronze  as  
select *  , _metadata.file_name as file_name, _metadata.file_path as file_path  , current_timestamp() as ingestion_ts
from stream(read_files(
'/Volumes/dev/bronze/my_volume/customers/',
inferColumnTypes => true,
schemaEvolutionMode => 'addNewColumns'
));
-- ------------------------------

--  Accounts  ingestion-----------

create or refresh streaming table dev.bronze.accounts_bronze  as  
select *  , _metadata.file_name as file_name, _metadata.file_path as file_path  , current_timestamp() as ingestion_ts
from stream(read_files(
'/Volumes/dev/bronze/my_volume/accounts/',
inferColumnTypes => true,
schemaEvolutionMode => 'addNewColumns'
));

--  -------------------------------------------


--  Transactions ingestion-----------

create or refresh streaming table dev.bronze.transactions_bronze  as  
select *  , _metadata.file_name as file_name, _metadata.file_path as file_path  , current_timestamp() as ingestion_ts
from stream(read_files(
'/Volumes/dev/bronze/my_volume/transactions/',
inferColumnTypes => true,
schemaEvolutionMode => 'addNewColumns'
));
-- ------------------------------

--  Branches ingestion-----------

create or refresh streaming table dev.bronze.branches_bronze  as  
select *  , _metadata.file_name as file_name, _metadata.file_path as file_path  , current_timestamp() as ingestion_ts
from stream(read_files(
'/Volumes/dev/bronze/my_volume/branches/',
inferColumnTypes => true,
schemaEvolutionMode => 'addNewColumns'
));









