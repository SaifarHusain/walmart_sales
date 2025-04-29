select * from walmart order by branch asc ,date ;
# 1. What are the different payment methods, and how many transactions and items were sold with each method?

SELECT 
    payment_method,
    COUNT(*) AS transaction,
    ROUND(SUM(quantity), 0) AS No_of_items_sold
FROM
    walmart
GROUP BY payment_method;

# 2. Which category received the highest average rating in each branch?

SELECT * 
FROM (
    SELECT branch, category, AVG(rating) AS average_rating,
           RANK() OVER (PARTITION BY branch ORDER BY AVG(rating) DESC) AS rank1
    FROM walmart
    GROUP BY branch, category
    ORDER BY branch, category DESC
) AS ranked_categories
WHERE rank1 = 1;

# 3.Question: What is the busiest day of the week for each branch based on transaction volume?

SELECT * 
FROM (
    SELECT branch,
           DAYNAME(date) AS day,
           COUNT(*) AS transaction_volume,
           RANK() OVER (PARTITION BY branch ORDER BY COUNT(*) DESC) AS rank1
    FROM walmart
    GROUP BY branch, day
) AS transaction
WHERE rank1 = 1
ORDER BY branch, transaction_volume DESC;


# 4. How man items were sold through each a payment method?

SELECT 
    payment_method, ROUND(SUM(quantity), 0) AS items_sold
FROM
    walmart
GROUP BY payment_method;

# 5.What are the average, minimum, and maximum ratings for each category in each city?

SELECT 
    city, category, AVG(rating) AS avg_rating, MIN(rating) AS min_rating, MAX(rating) AS max_rating
FROM walmart
GROUP BY city, category
ORDER BY city, category;


# 6. What is the total profit for each category, ranked from highest to lowest?

SELECT * FROM (
SELECT 
    branch,
    category,
    ROUND(SUM(profit_margin * Total), 1) AS Profit,
    RANK() over(partition by branch order by SUM(profit_margin * Total)) as rank1
FROM
    walmart
GROUP BY branch , category
ORDER BY branch) AS Total_Profit
ORDER BY branch asc, rank1 desc;

# 7.What is the most frequently used payment method in each branch?
SELECT branch, payment_method, frequency
FROM (
    SELECT 
        branch,
        payment_method,
        COUNT(*) AS frequency,
        RANK() OVER (PARTITION BY branch ORDER BY COUNT(*) DESC) AS rank1
    FROM 
        walmart
    GROUP BY branch, payment_method
) AS payment
WHERE rank1 = 1
ORDER BY branch ASC;

# 8. How many transactions occur in each shift (Morning, Afternoon, Evening) across branches?

 SELECT 
    branch,
    CASE 
        WHEN HOUR(time) BETWEEN 6 AND 12 THEN 'Morning'
        WHEN HOUR(time) BETWEEN 12 AND 16 THEN 'Afternoon'
        ELSE 'Evening'
    END AS shift,
    COUNT(*) AS transaction_count
FROM 
    walmart
GROUP BY 
    branch, shift
ORDER BY 
    branch, shift;
    
# 9.Which branches experienced the largest decrease in revenue compared to the previous year?
WITH REVENUE_22 AS(
SELECT 
    branch, YEAR(date) AS year_2022, SUM(Total) as revenue_2022
FROM
    walmart
WHERE
   YEAR(date)=2022
GROUP BY branch , year_2022
),

REVENUE_23 AS(
SELECT 
    branch, YEAR(date) AS year_2023, SUM(Total) as revenue_2023
FROM
    walmart
WHERE
   YEAR(date)=2023
GROUP BY branch , year_2023)

SELECT 
    r22.branch,
    r22.revenue_2022,
    r23.revenue_2023,
    (r23.revenue_2023 - r22.revenue_2022) AS revenue_difference
FROM 
    REVENUE_22 r22
JOIN 
    REVENUE_23 r23 ON r22.branch = r23.branch
ORDER BY 
    branch ,revenue_difference ASC;
