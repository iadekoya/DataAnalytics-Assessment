-- Query to get the monthly tran count per customer, average transaction count per customer and the frequency of transactions
WITH monthly_tran_count AS (
  -- Transactions per user per year_month
  SELECT
    a.id AS owner_id,
    DATE_FORMAT(transaction_date, '%Y-%m') AS tran_year_month, -- to extract both the year and month
    COUNT(*) AS tran_count
  FROM users_customuser a
 LEFT JOIN savings_savingsaccount b ON a.id = b.owner_id
  WHERE confirmed_amount > 0
    AND a.is_account_deleted=0
    and a.is_account_deleted_by_owner=0
  GROUP BY a.id, tran_year_month
),

avg_tran_per_cust AS (
  -- Average monthly transaction per user
  SELECT
    owner_id,
    ROUND(SUM(tran_count) / COUNT(DISTINCT tran_year_month)) AS avg_tran_per_month
  FROM monthly_tran_count
  GROUP BY owner_id
),

freq_category as
  (SELECT
    owner_id,
    avg_tran_per_month,
    CASE                               -- frequency category logic
      WHEN avg_tran_per_month >= 10 THEN 'High Frequency'
      WHEN avg_tran_per_month BETWEEN 3 AND 9 THEN 'Medium Frequency'
      WHEN avg_tran_per_month <= 2 THEN 'Low Frequency'
      ELSE NULL
    END AS frequency_category
  FROM avg_tran_per_cust)


-- resulting query to get the final output
SELECT
  frequency_category,
  COUNT(*) AS customer_count, -- count total customers in each frequency category
  ROUND(AVG(avg_tran_per_month), 1) AS avg_transactions_per_month
FROM freq_category
GROUP BY frequency_category
ORDER BY avg_transactions_per_month DESC; 