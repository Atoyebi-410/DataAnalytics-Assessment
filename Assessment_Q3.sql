-- Step 1: Get the latest inflow transaction date for each active savings or investment plan
WITH latest_inflow AS (
    SELECT
        plan_id,
        MAX(transaction_date) AS last_transaction_date  -- most recent inflow for each plan
    FROM savings_savingsaccount
    WHERE confirmed_amount > 0  -- only inflows
    GROUP BY plan_id
)

-- Step 2: Filter active plans and join with inflow info
SELECT
    p.id AS plan_id,  -- plan identifier
    p.owner_id,       -- customer who owns the plan
    CASE 
        WHEN p.is_regular_savings = 1 THEN 'Savings'  -- categorize as Savings
        WHEN p.is_a_fund = 1 THEN 'Investment'        -- categorize as Investment
        ELSE 'Other'
    END AS type,
    li.last_transaction_date,  -- last inflow date
    DATEDIFF(CURDATE(), li.last_transaction_date) AS inactivity_days  -- days since last inflow
FROM plans_plan p
LEFT JOIN latest_inflow li ON p.id = li.plan_id
WHERE
    (p.is_regular_savings = 1 OR p.is_a_fund = 1)  -- only Savings or Investment accounts
    AND p.is_deleted = 0
    AND p.is_archived = 0
    AND (li.last_transaction_date IS NULL OR DATEDIFF(CURDATE(), li.last_transaction_date) > 365)  -- inactive for over a year
ORDER BY inactivity_days DESC;
