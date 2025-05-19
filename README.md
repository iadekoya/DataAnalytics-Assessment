# DataAnalytics-Assessment

# Q1
# Q1: Users with Funded Savings and Investment Accounts
Objective
To identify users who have:
At least one funded regular savings account, and
Exactly one funded investment account 


# Database Context
This project uses a database named adashi with four tables. For this question, only the following three tables were used:

users_customuser: Contains customer details and account status.

savings_savingsaccount: Contains deposit transactions.

plans_plan: Contains details of the types of savings or investment plans.

# Approach
To keep the logic clean and readable, Common Table Expressions (CTEs) were used to break the query into logical parts:

1. CTE: savings
This joins the savings_savingsaccount table with plans_plan and Filters for regular savings plans that have a confirmed deposit (confirmed_amount > 0).

2. CTE: investment
This filters for fund-based investment plans instead and returns users with exactly one funded investment account.

3. Final Selection
Joins the users_customuser table with the results from both CTEs; excludes users whose accounts are marked as deleted or deactivated.
Combines the user's first and last name for easy identification as the original name column contains null values and would not be ideal for the report.
Sums savings and investment amounts to get the total deposit value.

Formatting & Sorting
Total deposits are converted to Naira (from Kobo) and rounded to 2 decimal places using DECIMAL(10,2).
Results are ordered by Total_deposits in descending order to highlight top depositors.

Challenges
Used Round() at first to round to 2 decimal places, however, it di not produce the expected output; hence the formatting
It was observed that some users had identical names, however, the IDs were distinct

## Q2
# Q2: Transaction Frequency Analysis
Objective:
Group customers based on how frequently they transact per month, using the following categories:

High Frequency: ≥10 transactions/month

Medium Frequency: 3–9 transactions/month

Low Frequency: ≤2 transactions/month

Approach:
To analyze customer transaction behavior, Common Table Expressions (CTEs) were used to break the logic into clear steps.

CTE – monthly_tran_count:

Extracts the total number of transactions per user per month using DATE_FORMAT(transaction_date, '%Y-%m') for year-month grouping and filters for only funded transactions (confirmed_amount > 0) while excluding deleted accounts.

CTE – avg_tran_per_cust:

Calculates the average number of transactions per user per month.
SUM(tran_count) / COUNT(DISTINCT tran_year_month) was used to ensure an accurate average across active months.

CTE – freq_category:

Assigns each user to a frequency category using a CASE statement based on their average monthly transactions.

Final Query:

Aggregates the number of users in each frequency category.
Computes the average transaction volume for each category.
Results are ordered by average monthly transactions in descending order.

Challenges
Here, I tried using the 'CAST AS DECIMAL' approach, however, I got over 70 null values- these ids didnt fall into any freuency category. I had to use round which gave me the perfect result.


# Q3: Account Inactivity Alert
Objective:
To retrieve all active savings or investment accounts that had at least one transaction historically but no transactions in the last 365 days (i.e., inactive for a year).

Approach:
Accounts are filtered to include only savings or investment types using plan flags.
Only accounts with at least one confirmed transaction (confirmed_amount > 0) and valid transaction_date are considered.
Deleted accounts are excluded using is_deleted = 0.

Date Logic:
The last transaction date per account is obtained using MAX(transaction_date) grouped by plan_id and owner_id.
Inactivity is calculated as the number of days since the last transaction using DATEDIFF(CURDATE(), MAX(transaction_date)).

Inactivity Filter:
The HAVING clause ensures only those accounts with inactivity less than or equal to 365 days are selected.

#  Q4: Customer Lifetime Value (CLV) Estimation

Objective:
To estimate the Customer Lifetime Value (CLV) using a simplified formula based on transaction volume and customer tenure.

Approach:
This analysis uses:
users_customuser – to determine account age (created_on) and customer identity.
savings_savingsaccount – to get the transaction values.

Step 1: Calculate Tenure and Total Transactions (CTE – customer_tran_month)

A Common Table Expression (CTE) is used for clarity.

For each customer:

The account tenure in months is calculated using TIMESTAMPDIFF(MONTH, created_on, CURDATE()).
Total confirmed transaction amount is summed up and converted to Naira by dividing by 100.
Deleted or deactivated users are excluded.

Step 2: Estimated CLV (CTE – clv)

The estimated CLV is computed using the formula:
Est. CLV = (total_transactions / tenure_months) * 12 * (total_transactions / transaction_count * 0.001)

This represents annualized average transactions multiplied by average profit per transaction (assumed to be 0.1% or 0.001 of average transaction value).
To handle very new users with 0 tenure, a CASE statement avoids division by zero by assigning a CLV of 0 when tenure_months = 0.

Output:
Includes customer ID, name, tenure in months, total transactions, and estimated CLV.
Results are sorted by estimated_clv in descending order to highlight the most valuable customers.

Challenge:
The CLV formula got me confused at first, especially the average profit per transaction part; however, I was able to navigate my way through it.







