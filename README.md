# Data Analysis Assessment: SQL Solutions

This repository contains SQL scripts developed to solve four business-critical data questions based on a financial platform. Each question explores different facets of customer behavior, financial engagement, and strategic decision-making. Below is a breakdown of how I approached each task, as well as any challenges I encountered during the process.

---

## Question 1: High-Value Customers with Multiple Products

**Scenario:**  
The business wants to identify high-value users who are engaged in both savings and investment products — an opportunity for cross-selling and deeper financial engagement.

**Task:**  
Find customers who have:
- At least one **funded savings plan** (`confirmed_amount > 0`), and
- At least one **funded investment plan** (`amount > 0`),
- Then, sort the results by total deposits across both.

**Approach:**  
I started by selecting customers from the `users_customuser` table. I then joined this table with two subqueries:
- The first subquery summarizes savings activity (count and sum of confirmed savings).
- The second summarizes investment activity (count and sum of investment amounts).

Finally, I combined the savings and investment totals into a single `total_deposits` metric and sorted the results in descending order.

**Challenges:**  
No major technical hurdles here, but I had to be careful with column naming and aliases to ensure readability and avoid conflicts when joining subqueries. I also validated that only genuinely "funded" records were included.

---

## Question 2: Inactive Plans with Money In

**Scenario:**  
The business is interested in identifying plans that have money in them but are not active.

**Task:**  
Find inactive plans (`status_id != 1`) where:
- `amount > 0`, and
- Include relevant user info such as `owner_id`, `name`, and `email`.

**Approach:**  
I filtered the `plans_plan` table to select only records where the `status_id` was not active and the plan had some form of balance (either `amount` or `cowry_amount`). I joined this with the `users_customuser` table to attach customer metadata.

**Challenges:**  
The main consideration here was interpreting what “inactive” meant — I assumed `status_id != 1` based on convention. I also included both `amount` and `cowry_amount` as valid indicators of balance, given their usage in the schema.

---

## Question 3: Customer Lifetime Value (CLV) Estimation

**Scenario:**  
We want to estimate the long-term profitability of each customer.

**Task:**  
- Calculate customer **tenure in months** using the `date_joined` field.
- Count total number of **funded savings transactions**.
- Estimate **profit per transaction** as 0.1% of `confirmed_amount`.
- Use the formula:

CLV = (total_transactions / tenure) * 12 * avg_profit_per_transaction


**Approach:**  
I used a common table expression (CTE) to calculate the total transactions and total confirmed deposit amount per customer. I then joined this with the users table to get the `date_joined` value and compute tenure in months using `TIMESTAMPDIFF`.

The final step was to apply the CLV formula, converting kobo to naira for the output.

**Challenges:**  
MySQL doesn't support `DATE_TRUNC`, which led to a syntax error initially. I resolved this by switching to `TIMESTAMPDIFF(MONTH, ...)`, which worked well for calculating monthly tenure. I also used `NULLIF` to prevent division-by-zero issues when computing averages.

---

## Question 4: Withdrawals and Plan Link

**Scenario:**  
The team wants visibility into how much has been withdrawn from each savings/investment plan and when.

**Task:**  
- Show all withdrawals with plan and user details.
- Sort by withdrawal amount (descending).

**Approach:**  
I started with the `withdrawals_withdrawal` table as the primary source. I joined this with the `plans_plan` and `users_customuser` tables to pull in additional context like plan name, customer name, and email. I ordered the results by withdrawal amount in descending order to highlight the largest withdrawals first.

**Challenges:**  
Most of the challenge here was ensuring clarity in the output, especially making sure that withdrawal amounts were matched to the correct user and plan. I also had to double-check column names and join keys (`plan_id`, `owner_id`) across all three tables to avoid mismatches.

---

## Final Notes

Each query is saved in a separate `.sql` file and documented with inline comments to make them easy to understand and maintain. The goal was not only to answer the questions correctly but also to write clean and readable SQL queries.

Thanks for reviewing!
