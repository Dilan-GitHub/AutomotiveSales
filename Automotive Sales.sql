-- Sales Performance Analysis

-- Total Sales and Profits by Salesperson
SELECT 
    c.consultant_id,
    c.name,
    SUM(s.sale_price) AS total_sales,
    SUM(s.profit) AS total_profit
FROM 
    Sales s
JOIN 
    consultant c ON s.consultant_id = c.consultant_id
GROUP BY 
    c.consultant_id, c.name
ORDER BY 
    total_sales DESC;

-- Average Sale Price by Salesperson
SELECT 
    c.consultant_id,
    c.name,
    AVG(s.sale_price) AS avg_sale_price
FROM 
    Sales s
JOIN 
    consultant c ON s.consultant_id = c.consultant_id
GROUP BY 
    c.consultant_id, c.name
ORDER BY 
    avg_sale_price DESC;

-- Total Sales Per Month For Each Year

SELECT 
    YEAR(sale_date) AS sale_year,
    MONTH(sale_date) AS sale_month,
    SUM(sale_price) AS total_sales
FROM Sales
WHERE YEAR(sale_date) IN (2014, 2015, 2016)
GROUP BY YEAR(sale_date), MONTH(sale_date)
ORDER BY YEAR(sale_date), MONTH(sale_date);

-- Total Number of Vehicles Sold Per Month For Each Year 

WITH MonthlySales AS (
    SELECT
        YEAR(sale_date) AS sale_year,
        MONTH(sale_date) AS sale_month,
        consultant_id,
        COUNT(vehicle_id) AS cars_sold
    FROM Sales
    GROUP BY YEAR(sale_date), MONTH(sale_date), consultant_id
),
TopConsultants AS (
    SELECT
        sale_year,
        sale_month,
        consultant_id,
        cars_sold,
        RANK() OVER (PARTITION BY sale_year, sale_month ORDER BY cars_sold DESC) AS rank
    FROM MonthlySales
)
SELECT
    sale_year,
    sale_month,
    consultant_id,
    cars_sold
FROM TopConsultants
WHERE rank = 1
ORDER BY sale_year, sale_month;

-- Total Profit Per Month For Each Year

SELECT 
    YEAR(sale_date) AS sale_year,
    MONTH(sale_date) AS sale_month,
    SUM(profit) AS total_profit
FROM 
    sales
WHERE 
    YEAR(sale_date) IN (2014, 2015, 2016)
GROUP BY 
    YEAR(sale_date), MONTH(sale_date)
ORDER BY 
    sale_year, sale_month;

-- Most Profitable Brand Per Month Each Year

WITH MonthlyBrandProfit AS (
    SELECT 
        CAST(YEAR(sale_date) AS NVARCHAR(4)) + '-' + RIGHT('0' + CAST(MONTH(sale_date) AS NVARCHAR(2)), 2) AS year_month,
        make AS brand,
        SUM(profit) AS total_profit
    FROM 
        sales
    WHERE 
        YEAR(sale_date) IN (2014, 2015, 2016)
    GROUP BY 
        CAST(YEAR(sale_date) AS NVARCHAR(4)) + '-' + RIGHT('0' + CAST(MONTH(sale_date) AS NVARCHAR(2)), 2), make
),
RankedBrands AS (
    SELECT 
        year_month,
        brand,
        total_profit,
        RANK() OVER (PARTITION BY year_month ORDER BY total_profit DESC) AS rank
    FROM 
        MonthlyBrandProfit
)
SELECT 
    year_month,
    brand,
    total_profit
FROM 
    RankedBrands
WHERE 
    rank = 1
ORDER BY 
    year_month;

-- Customer Analysis

-- Customer Demographics Analysis

SELECT 
    c.debt_to_income_ratio,
    AVG(c.credit_score) AS avg_credit_score,
    AVG(c.annual_income) AS avg_annual_income,
    COUNT(*) AS number_of_customers
FROM 
    Customers c
GROUP BY 
    c.debt_to_income_ratio
ORDER BY 
    c.debt_to_income_ratio;

-- Sales by Customer Type
SELECT 
    CASE 
        WHEN c.credit_score >= 800 THEN 'Excellent'
        WHEN c.credit_score >= 700 THEN 'Good'
        WHEN c.credit_score BETWEEN 600 AND 699 THEN 'Fair'
        ELSE 'Poor'
    END AS credit_score_segment,
    COUNT(DISTINCT c.customer_id) AS number_of_customers,
    SUM(s.sale_price) AS total_sales
FROM 
    Customers c
JOIN 
    Sales s ON c.customer_id = s.customer_ID
GROUP BY 
    CASE 
        WHEN c.credit_score >= 800 THEN 'Excellent'
        WHEN c.credit_score >= 700 THEN 'Good'
        WHEN c.credit_score BETWEEN 600 AND 699 THEN 'Fair'
        ELSE 'Poor'
    END
ORDER BY 
    total_sales DESC;

-- Vehicle Performance Analysis

-- Most Profitable Vehicles
SELECT 
    Make, 
    Model, 
    SUM(Profit) AS total_profit
FROM 
    Sales
GROUP BY 
    Make, Model
ORDER BY 
    total_profit DESC;

-- Average Days on Lot
SELECT 
    AVG(days_on_lot) AS average_days_on_lot
FROM 
    Sales;

-- Sales Trends Over Time

-- Monthly Sales Trends
SELECT 
    YEAR(sale_Date) AS sales_year,
    MONTH(sale_Date) AS sales_month,
    COUNT(*) AS sales_count,
    SUM(sale_Price) AS total_sales
FROM 
    Sales
GROUP BY 
    YEAR(sale_Date), MONTH(sale_Date)
ORDER BY 
    sales_year, sales_month;

-- Year-over-Year Growth
SELECT 
    YEAR(sale_Date) AS sales_year,
    COUNT(*) AS sales_count,
    SUM(sale_Price) AS total_sales
FROM 
    Sales
GROUP BY 
    YEAR(sale_Date)
ORDER BY 
    sales_year;

-- Comission Insights
SELECT 
    c.consultant_id,
    c.name,
    c.base_salary,
    SUM(s.profit) * c.commission_rate AS total_commission,
    c.base_salary + (SUM(s.profit) * c.commission_rate) AS projected_earnings
FROM 
    consultant c
LEFT JOIN 
    Sales s ON c.consultant_id = s.consultant_id
GROUP BY 
    c.consultant_id, c.name, c.base_salary, c.commission_rate
ORDER BY 
    projected_earnings DESC;

-- Top Earning Consultant Each Month

WITH MonthlyConsultantEarnings AS (
    SELECT 
        CAST(YEAR(s.sale_date) AS NVARCHAR(4)) + '-' + RIGHT('0' + CAST(MONTH(s.sale_date) AS NVARCHAR(2)), 2) AS year_month,
        c.name AS consultant_name,
        SUM(s.profit) AS total_profit
    FROM 
        sales s
    JOIN 
        consultant c
    ON 
        s.consultant_id = c.consultant_id
    WHERE 
        YEAR(s.sale_date) IN (2014, 2015, 2016)
    GROUP BY 
        CAST(YEAR(s.sale_date) AS NVARCHAR(4)) + '-' + RIGHT('0' + CAST(MONTH(s.sale_date) AS NVARCHAR(2)), 2),
        c.name
),
RankedConsultants AS (
    SELECT 
        year_month,
        consultant_name,
        total_profit,
        RANK() OVER (PARTITION BY year_month ORDER BY total_profit DESC) AS rank
    FROM 
        MonthlyConsultantEarnings
)
SELECT 
    year_month,
    consultant_name,
    total_profit
FROM 
    RankedConsultants
WHERE 
    rank = 1
ORDER BY 
    year_month;

