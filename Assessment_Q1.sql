-- Q1: High-Value Customers with Multiple Products

-- Step 1: I started by selecting basic customer details
SELECT 
    u.id AS owner_id,         -- Customer's unique ID
    u.name,                   -- Customer's name

    -- Step 4: I pulled in savings and investment stats from subqueries
    s.savings_count,          -- Total funded savings accounts
    p.investment_count,       -- Total funded investment plans
    (s.total_savings + p.total_investments) AS total_deposits -- Total deposits across both

FROM 
    users_customuser u        -- Main user table

-- Step 2: I joined with a subquery that aggregates savings account info
JOIN (
    SELECT 
        owner_id,                           -- Owner of the savings account
        COUNT(*) AS savings_count,          -- Number of funded savings accounts
        SUM(confirmed_amount) AS total_savings -- Sum of confirmed deposits
    FROM savings_savingsaccount
    WHERE confirmed_amount > 0             -- Only funded savings accounts
    GROUP BY owner_id
) s ON u.id = s.owner_id                   -- Match with user table

-- Step 3: I joined with a subquery that aggregates investment plan info
JOIN (
    SELECT 
        owner_id,                           -- Owner of the investment plan
        COUNT(*) AS investment_count,       -- Number of funded investment plans
        SUM(amount) AS total_investments    -- Sum of investment amounts
    FROM plans_plan
    WHERE amount > 0                        -- Only funded investment plans
    GROUP BY owner_id
) p ON u.id = p.owner_id                   -- Match with user table

-- Step 5: I sorted results by total deposits in descending order
ORDER BY 
    total_deposits DESC;
