/* 
1- write a query to print top 5 cities with highest spends and their percentage contribution of total credit card spends 
2- write a query to print highest spend month and amount spent in that month for each card type
3- write a query to print the transaction details(all columns from the table) for each card type when
		it reaches a cumulative of 1000000 total spends(We should have 4 rows in the o/p one for each card type)
4- write a query to find city which had lowest percentage spend for gold card type
5- write a query to print 3 columns:  city, highest_expense_type , lowest_expense_type (example format : Delhi , bills, Fuel)
6- write a query to find percentage contribution of spends by females for each expense type
7- which card and expense type combination saw highest month over month growth in Jan-2014
9- during weekends which city has highest total spend to total no of transcations ratio    */

-- CREATING AND USE THE DATABASE FOR LOADING AND STORE THE DATASET
CREATE DATABASE TRANSACTION_DB;
USE TRANSACTION_DB;
GO

SELECT * FROM [dbo].[Credit card transactions];


-- TOTAL  ROWS IN DATA
	SELECT COUNT(*) AS TOTAL_ROWS FROM [dbo].[Credit card transactions];

-- TRY TO FIND OUT THE NULL VALUES IN COLUMNS
	SELECT * FROM [dbo].[Credit card transactions]
	WHERE 'INDEX' IS NULL;

	SELECT * FROM [dbo].[Credit card transactions]
	WHERE 'INDEX' IS NULL OR CITY IS NULL OR DATE IS NULL OR CARD_TYPE IS NULL OR EXP_TYPE IS NULL 
			OR GENDER IS NULL OR AMOUNT IS NULL;


-- CHECKING DUPLICATES IN DATA
	SELECT [INDEX], 
		   COUNT([INDEX]) AS DUPLICATE
	FROM [dbo].[Credit card transactions]
	GROUP BY [INDEX]
	HAVING COUNT(1) >1 ;


-- PROBLEMS AND SOLUTIONS
-- 1 write a query to print top 5 cities with highest spends and their percentage contribution 
-- of total credit card spends 
	WITH MY_CTE AS(
	SELECT 
		CITY,
		SUM(AMOUNT) AS TOTAL_CITY_SPEND
	FROM [dbo].[Credit card transactions]
	GROUP BY CITY )
	-- ORDER BY TOTAL_CITY_SPEND DESC)

	SELECT TOP 3 CITY, TOTAL_CITY_SPEND,
		(SUM(TOTAL_CITY_SPEND) / (SELECT SUM(AMOUNT) FROM [dbo].[Credit card transactions]) * 100) AS CONTRIBUTION_PERCENT
	FROM MY_CTE
	GROUP BY CITY, TOTAL_CITY_SPEND
	ORDER BY CONTRIBUTION_PERCENT DESC;
	GO;


-- 2 write a query to print highest spend month and amount spent in that month for each card type

WITH MY_CTE AS(
    SELECT 
		CITY, AMOUNT, CARD_TYPE
	FROM [dbo].[Credit card transactions]
), MY_CTE_2 AS(	
	SELECT 
		DATENAME(MONTH,DATE) AS MONTHS_NAME,
		CARD_TYPE,
		SUM(AMOUNT) AS TOTAL_SPENDING,
		DENSE_RANK() OVER(PARTITION BY CARD_TYPE ORDER BY SUM(AMOUNT) DESC) AS RN
	FROM [dbo].[Credit card transactions]
	GROUP BY DATENAME(MONTH,DATE), CARD_TYPE
	)
	SELECT 
		MONTHS_NAME, 
		CARD_TYPE, 
		TOTAL_SPENDING 
	FROM MY_CTE_2
	WHERE RN = 1
	ORDER BY TOTAL_SPENDING DESC


-- 4 write a query to find city which had lowest percentage spend for gold card type

WITH MY_CTE AS(
	SELECT 
	CITY,
	AMOUNT, 
	CARD_TYPE
	FROM [dbo].[Credit card transactions] )
	SELECT 
		CITY,
		CARD_TYPE,
		(SUM(AMOUNT)/ (SELECT SUM(AMOUNT) FROM [dbo].[Credit card transactions]))*100 AS SPEND_PERCENTAGE
	FROM MY_CTE
	WHERE CARD_TYPE IN ('GOLD')
	GROUP BY CITY, CARD_TYPE
	ORDER BY SPEND_PERCENTAGE ASC


-- 5 write a query to print 3 columns:  city, highest_expense_type , lowest_expense_type 
-- (example format : Delhi , bills, Fuel)
	SELECT * FROM [dbo].[Credit card transactions];

WITH EXPENSE_SUMMARY AS (
    SELECT 
        CITY,
        EXP_TYPE,
        SUM(AMOUNT) AS TOTAL_SPEND
    FROM [dbo].[Credit card transactions]
    GROUP BY CITY, EXP_TYPE
),
RANKED AS (
    SELECT 
        CITY,
        EXP_TYPE,
        TOTAL_SPEND,
        RANK() OVER(PARTITION BY CITY ORDER BY TOTAL_SPEND DESC) AS RNK_DESC,
        RANK() OVER(PARTITION BY CITY ORDER BY TOTAL_SPEND ASC)  AS RNK_ASC
    FROM EXPENSE_SUMMARY
)
SELECT 
    CITY,
    MAX(CASE WHEN RNK_DESC = 1 THEN EXP_TYPE END) AS HIGHEST_EXPENSE_TYPE,
    MAX(CASE WHEN RNK_ASC  = 1 THEN EXP_TYPE END) AS LOWEST_EXPENSE_TYPE
FROM RANKED
GROUP BY CITY;


-- 6 write a query to find percentage contribution of spends by females for each expense type
	SELECT 
		DISTINCT EXP_TYPE,
		GENDER,
		SUM(AMOUNT) AS TOTAL_SPENDING,
		(SUM(AMOUNT)/(SELECT SUM(AMOUNT) FROM [dbo].[Credit card transactions]) * 100) AS PERCENTAGE_CONTRIBUTION
	FROM [dbo].[Credit card transactions]
	WHERE GENDER = 'F'
	GROUP BY GENDER , EXP_TYPE
	ORDER BY TOTAL_SPENDING DESC ;


-- 7 which card and expense type combination saw highest month over month growth in Jan-2014

	WITH MY_CTE AS (
		SELECT CARD_TYPE, EXP_TYPE, [DATE], AMOUNT 
		FROM [dbo].[Credit card transactions] ),
	MY_CTE_1 AS(
	SELECT 
		CARD_TYPE,
		EXP_TYPE,
		FORMAT([DATE],'MMMM-yyy') AS DATEE,
		SUM(AMOUNT) AS TOTAL_SPEND
	FROM MY_CTE
	WHERE MONTH([DATE]) = 1 AND YEAR([DATE]) = 2014
	GROUP BY CARD_TYPE, EXP_TYPE, FORMAT([DATE],'MMMM-yyy')),

	MY_CTE_2 AS(
	SELECT 
		CARD_TYPE, EXP_TYPE,
		DATEE,
		TOTAL_SPEND,
		LAG(TOTAL_SPEND) OVER(ORDER BY TOTAL_SPEND DESC) AS PREV_MONTH
	FROM MY_CTE_1)
		SELECT * FROM MY_CTE_2;
		GO;


--9 during weekends which city has highest total spend to total no of transcations ratio 	
	SELECT 
    CITY,
    SUM(AMOUNT) AS TOTAL_SAPEND,
    COUNT(1) AS TOTAL_TRANSACTION,
    CAST(SUM(AMOUNT) AS FLOAT) / COUNT(1) AS SPEND_PER_TRANSACTION_RATIO
FROM [dbo].[Credit card transactions]
WHERE DATEPART(WEEKDAY, [DATE]) IN (1, 7)
GROUP BY CITY
ORDER BY TOTAL_TRANSACTION DESC;


SELECT * FROM [dbo].[Credit card transactions]