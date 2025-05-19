
-- create the first table using CTE to get basic customer details as well as transaction volume (count) and value
WITH customer_tran AS (
  SELECT 
    a.id AS customer_id,
    CONCAT(a.first_name, ' ', a.last_name) AS name,
    TIMESTAMPDIFF(MONTH, a.created_on, CURDATE()) AS tenure_months,
    COUNT(b.owner_id) AS tran_volume,  -- total count of transactions
    SUM(b.confirmed_amount) / 100 AS tran_value  -- total transaction value in Naira
  FROM users_customuser a
  JOIN savings_savingsaccount b
    ON a.id = b.owner_id
  WHERE 
    a.is_account_deleted = 0
    AND a.is_account_deleted_by_owner = 0
    and b.confirmed_amount > 0
  GROUP BY a.id,CONCAT(a.first_name, ' ', a.last_name),TIMESTAMPDIFF(MONTH, a.created_on, CURDATE())
),
-- calculate customer lifetime value, and handle division by zero error using case when
clv AS (
  SELECT 
    customer_id,
    name,
    tenure_months,
    tran_volume as total_transactions,

    -- estimated CLV calculation, case when is used to handle customers who have used 0 months (new customers)
    CASE 
      WHEN tenure_months > 0
      THEN ROUND(
        ((tran_volume / tenure_months) * 12) * 
        ((tran_value / tran_volume) * 0.001),
        2
      )
      ELSE 0
    END AS est_clv

  FROM customer_tran
)

-- query block to get the required columns as specified in the assessment instructions, sorted by the estimated CLV in descending order
SELECT 
  customer_id,
  name,
  tenure_months,
  total_transactions,
  est_clv
FROM clv
ORDER BY est_clv DESC;
