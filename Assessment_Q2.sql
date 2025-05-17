-- Step 1: Counts the number of transactions each customer made per month
WITH monthly_txn_count AS (
    SELECT
        owner_id,  -- the customer ID
        DATE_FORMAT(transaction_date, '%Y-%m') AS txn_month,  -- extract year and month from transaction date
        COUNT(*) AS transactions_in_month  -- count of transactions in that month
    FROM savings_savingsaccount
    GROUP BY owner_id, txn_month  -- group by customer and month
),

-- Step 2: Calculates the average number of monthly transactions for each customer
avg_txn_per_customer AS (
    SELECT
        owner_id,
        AVG(transactions_in_month) AS avg_transactions_per_month  -- average number of monthly transactions
    FROM monthly_txn_count
    GROUP BY owner_id
),

-- Step 3: Categorizes each customer based on their average transaction frequency
categorized AS (
    SELECT
        CASE
            WHEN avg_transactions_per_month >= 10 THEN 'High Frequency'  -- 10 or more transactions per month
            WHEN avg_transactions_per_month BETWEEN 3 AND 9 THEN 'Medium Frequency'  -- 3 to 9 per month
            ELSE 'Low Frequency'  -- 0 to 2 per month
        END AS frequency_category,
        avg_transactions_per_month
    FROM avg_txn_per_customer
)

-- Step 4: Counts how many customers fall into each frequency category and compute the average within the group
SELECT
    frequency_category,  -- category name: High, Medium, Low
    COUNT(*) AS customer_count,  -- number of customers in that category
    ROUND(AVG(avg_transactions_per_month), 1) AS avg_transactions_per_month  -- average frequency (1 decimal place)
FROM categorized
GROUP BY frequency_category;
