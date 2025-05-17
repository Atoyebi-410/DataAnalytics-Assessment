-- Step 1: Calculate total confirmed inflows (in Kobo) and total number of transactions per customer
WITH txn_summary AS (
    SELECT
        owner_id,
        COUNT(*) AS total_transactions,  -- number of inflow transactions
        SUM(confirmed_amount) AS total_transaction_value  -- total value of inflow transactions
    FROM savings_savingsaccount
    WHERE confirmed_amount > 0  -- only inflow transactions
    GROUP BY owner_id
),

-- Step 2: Compute account tenure in months and join with transaction summary
clv_data AS (
    SELECT
        u.id AS customer_id,
        u.name,
        TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()) AS tenure_months,  -- account age in months
        t.total_transactions,
        t.total_transaction_value,
        
        -- average profit per transaction (0.1% of total inflows divided by number of transactions)
        (t.total_transaction_value * 0.001) / NULLIF(t.total_transactions, 0) AS avg_profit_per_transaction
    FROM users_customuser u
    JOIN txn_summary t ON u.id = t.owner_id
    WHERE u.is_active = 1  -- only include active users (optional but sensible)
)

-- Step 3: Calculate estimated CLV using the provided formula
SELECT
    customer_id,
    name,
    tenure_months,
    total_transactions,
    ROUND(
        ((total_transactions / NULLIF(tenure_months, 0)) * 12 * avg_profit_per_transaction) / 100, 2
    ) AS estimated_clv  -- divide by 100 to convert Kobo to Naira
FROM clv_data
ORDER BY estimated_clv DESC;
