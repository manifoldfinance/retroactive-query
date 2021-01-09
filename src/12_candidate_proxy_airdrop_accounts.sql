 BEGIN -- returns all addresses that performed a call or received tokens in a transaction that interacted with Uniswap up until September 1st 2020, and that were not included in initial airdrop

CREATE TABLE candidate_proxy_airdrop_accounts AS (
  SELECT DISTINCT address
  FROM (
    SELECT DISTINCT from_address AS address, transaction_hash
      FROM `bigquery-public-data.crypto_ethereum.traces` 
    UNION DISTINCT
    SELECT DISTINCT to_address AS address, transaction_hash
      FROM `bigquery-public-data.crypto_ethereum.traces`
    UNION DISTINCT
    SELECT DISTINCT to_address AS address, transaction_hash
      FROM `bigquery-public-data.crypto_ethereum.token_transfers`
  ) AS all_call_sources_and_token_transfer_recipients
  WHERE all_call_sources_and_token_transfer_recipients.transaction_hash IN (
    SELECT transaction_hash
      FROM `bigquery-public-data.crypto_ethereum.traces`
      WHERE to_address IN (
        SELECT contract
          FROM uniswap_contracts
        )
      AND block_timestamp < @cutoff_timestamp
      AND call_type = 'call'
  )
  AND all_call_sources_and_token_transfer_recipients.address NOT IN (
    SELECT address
      FROM all_earnings
  )
);

END;
