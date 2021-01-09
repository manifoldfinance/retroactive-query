 BEGIN

CREATE TEMPORARY TABLE all_txes AS (
  WITH hashes as (
    SELECT transaction_hash
    FROM wrappers_query
  )
  SELECT from_address, to_address, transaction_hash
       FROM   `bigquery-public-data.crypto_ethereum.traces`
       -- take all transactions that used Uniswap and in their trace DSProxys execute is called
       WHERE (transaction_hash IN (SELECT transaction_hash FROM hashes) AND input LIKE '0x1cff79cd%')
);

CREATE TABLE user_proxy AS (
  WITH cte AS (
    SELECT 
        to_address as proxy,
        transaction_hash,
        ROW_NUMBER() OVER (
            PARTITION BY 
                to_address
            ORDER BY 
                to_address
        ) row_num
     FROM 
        all_txes
    ) 
   SELECT proxy, transaction_hash FROM cte WHERE row_num = 1
);

END;
