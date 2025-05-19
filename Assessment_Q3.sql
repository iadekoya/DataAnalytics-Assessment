SELECT distinct
  s.plan_id,
  s.owner_id,
  CASE 
    WHEN p.is_a_fund = 1 THEN 'Investment'
    WHEN p.is_regular_savings = 1 THEN 'Savings'
  END AS type,
  cast(MAX(s.transaction_date) as date) AS last_transaction_date,
  DATEDIFF(CURDATE(), MAX(s.transaction_date)) AS inactivity_days -- to get the numbers of days since inactivity
FROM savings_savingsaccount s
LEFT JOIN plans_plan p ON s.plan_id = p.id
WHERE s.confirmed_amount > 0 -- to ensure the customer actually transacted
  AND s.transaction_date IS NOT NULL
  AND is_deleted = 0
  AND (p.is_regular_savings = 1 OR p.is_a_fund = 1) -- to ensure either savings or investments are selected
GROUP BY s.plan_id, s.owner_id, type
HAVING inactivity_days <= 365 -- inactivity days in the last one year
ORDER BY inactivity_days DESC;
