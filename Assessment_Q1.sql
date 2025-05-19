-- Use Common Table Expressions for savings and investments and Users Tables
WITH savings AS (
    -- Users with at least one funded regular savings account
    SELECT 
        k.owner_id, 
        COUNT(distinct savings_id) AS savings_count, 
        SUM(k.confirmed_amount / 100.0) AS amount -- amount in naira
    FROM savings_savingsaccount k
    LEFT JOIN plans_plan l ON k.plan_id = l.id
    WHERE l.is_regular_savings = 1
      AND k.confirmed_amount > 0
    GROUP BY k.owner_id
    HAVING COUNT(*) >= 1
),

investment AS (
    -- Users with exactly one funded investment (fund) account
    SELECT 
        m.owner_id, 
        COUNT(distinct savings_id) AS investment_count, 
        SUM(m.confirmed_amount / 100.0) AS amount -- amount in naira
    FROM savings_savingsaccount m
    LEFT JOIN plans_plan n ON m.plan_id = n.id
    WHERE n.is_a_fund = 1
      AND m.confirmed_amount > 0 -- ensure customers actually transacted
    GROUP BY m.owner_id
    HAVING COUNT(*) = 1
)

-- Query to get the customers names, total deposits, investment and savings count while filtering out deleted accounts
SELECT 
    CONCAT(a.first_name, ' ', a.last_name) AS Name,
    b.savings_count,
    c.investment_count,
    CAST(b.amount + c.amount AS DECIMAL(10,2)) AS Total_deposits
FROM users_customuser a
JOIN savings b ON a.id = b.owner_id
JOIN investment c ON a.id = c.owner_id
WHERE a.is_account_deleted = 0
  AND a.is_account_deleted_by_owner = 0
ORDER BY Total_deposits DESC;
