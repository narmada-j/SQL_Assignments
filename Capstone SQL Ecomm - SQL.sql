/*
				CAPSTONE PROJECT
		E-Commerce Customer Churn Analysis
*/
-- Explore Dataset
USE ecomm;
Describe customer_churn;
SELECT * FROM customer_churn;

/*
*************************************************************************************
								Data Cleaning
*************************************************************************************
*/
-- ------------------------------------
-- Handling Missing Values and Outliers:
-- -------------------------------------
SELECT  WarehouseToHome, HourSpendOnApp, OrderAmountHikeFromlastYear, DaySinceLastOrder 
FROM customer_churn;
-- Average value for null columns
SELECT 
    ROUND(AVG(WarehouseToHome)) AS Mean_WarehouseToHome,
    ROUND(AVG(HourSpendOnApp)) AS Mean_HourSpendOnApp,
    ROUND(AVG(OrderAmountHikeFromlastYear)) AS Mean_OrderAmountHike,
    ROUND(AVG(DaySinceLastOrder)) AS Mean_DaySinceLastOrder
FROM customer_churn;
-- update null values
UPDATE customer_churn c
JOIN (
    SELECT 
        ROUND(AVG(WarehouseToHome)) AS Mean_WarehouseToHome,
        ROUND(AVG(HourSpendOnApp)) AS Mean_HourSpendOnApp,
        ROUND(AVG(OrderAmountHikeFromlastYear)) AS Mean_OrderAmountHike,
        ROUND(AVG(DaySinceLastOrder)) AS Mean_DaySinceLastOrder
    FROM customer_churn
) m
ON 1=1
SET c.WarehouseToHome = COALESCE(c.WarehouseToHome, m.Mean_WarehouseToHome),
    c.HourSpendOnApp = COALESCE(c.HourSpendOnApp, m.Mean_HourSpendOnApp),
    c.OrderAmountHikeFromlastYear = COALESCE(c.OrderAmountHikeFromlastYear, m.Mean_OrderAmountHike),
    c.DaySinceLastOrder = COALESCE(c.DaySinceLastOrder, m.Mean_DaySinceLastOrder);
-- Impute mode for the following columns: Tenure, CouponUsed, OrderCount
-- Mode for Tenure
SELECT Tenure FROM customer_churn
GROUP BY Tenure ORDER BY COUNT(*) DESC LIMIT 1;

-- Mode for CouponUsed
SELECT CouponUsed FROM customer_churn 
GROUP BY CouponUsed ORDER BY COUNT(*) DESC LIMIT 1;

-- Mode for OrderCount
SELECT OrderCount FROM customer_churn
GROUP BY OrderCount ORDER BY COUNT(*) DESC LIMIT 1;

WITH mode_values AS (
    SELECT 
        (SELECT Tenure FROM customer_churn GROUP BY Tenure ORDER BY COUNT(*) DESC LIMIT 1) AS Mode_Tenure,
        (SELECT CouponUsed FROM customer_churn GROUP BY CouponUsed ORDER BY COUNT(*) DESC LIMIT 1) AS Mode_CouponUsed,
        (SELECT OrderCount FROM customer_churn GROUP BY OrderCount ORDER BY COUNT(*) DESC LIMIT 1) AS Mode_OrderCount
)
UPDATE customer_churn c
JOIN mode_values m
ON 1=1
SET c.Tenure = CASE WHEN c.Tenure IS NULL THEN m.Mode_Tenure ELSE c.Tenure END,
    c.CouponUsed = CASE WHEN c.CouponUsed IS NULL THEN m.Mode_CouponUsed ELSE c.CouponUsed END,
    c.OrderCount = CASE WHEN c.OrderCount IS NULL THEN m.Mode_OrderCount ELSE c.OrderCount END;
-- View changed values
SELECT Tenure, CouponUsed, OrderCount FROM customer_churn;

-- Handle outliers in the 'WarehouseToHome' column by deleting rows where the values are greater than 100.
SELECT CustomerID,WarehouseToHome FROM customer_churn
WHERE WarehouseToHome > 100;
-- delete 
DELETE FROM customer_churn
WHERE WarehouseToHome > 100;

-- ------------------------------------
-- Dealing with Inconsistencies: 
-- -------------------------------------
-- Replace occurrences of “Phone” in the 'PreferredLoginDevice' column and “Mobile” in the 'PreferedOrderCat' column with “Mobile Phone” 
SELECT PreferredLoginDevice,PreferedOrderCat FROM customer_churn;
SELECT PreferredLoginDevice FROM customer_churn WHERE PreferredLoginDevice = 'Phone';
SELECT PreferedOrderCat FROM customer_churn WHERE PreferedOrderCat = 'Mobile';

UPDATE customer_churn SET PreferredLoginDevice = 'Mobile Phone' WHERE PreferredLoginDevice = 'phone';
UPDATE customer_churn SET PreferedOrderCat = 'Mobile Phone' WHERE PreferedOrderCat = 'Mobile';

-- Standardize payment mode values: Replace "COD" with "Cash on Delivery" and "CC" with "Credit Card" in the PreferredPaymentMode column. 
SELECT PreferredPaymentMode FROM customer_churn;
SELECT PreferredPaymentMode FROM customer_churn WHERE PreferredPaymentMode='Cash on Delivery';
SELECT PreferredPaymentMode FROM customer_churn WHERE PreferredPaymentMode='CC';

UPDATE customer_churn SET PreferredPaymentMode = 'COD' WHERE PreferredPaymentMode = 'Cash on Delivery';
UPDATE customer_churn SET PreferredPaymentMode = 'Credit Card' WHERE PreferredPaymentMode = 'CC';

/*
*************************************************************************************
								Data Transformation
*************************************************************************************
*/
-- ------------------------------------
-- Column Renaming: 
-- -------------------------------------
-- Rename the column "PreferedOrderCat" to "PreferredOrderCat". 
DESCRIBE customer_churn;
ALTER TABLE customer_churn 
RENAME COLUMN  PreferedOrderCat TO PreferredOrderCat;

-- Rename the column "HourSpendOnApp" to "HoursSpentOnApp". 
ALTER TABLE customer_churn 
RENAME COLUMN  HourSpendOnApp TO HoursSpendOnApp;

-- ------------------------------------
-- New Columns: 
-- -------------------------------------
-- Create a new column named ‘ComplaintReceived’ with values "Yes" if the corresponding value in the ‘Complain’ is 1, and "No" otherwise. 
DESCRIBE customer_churn;
-- Step 1: Add the new column
ALTER TABLE customer_churn ADD COLUMN ComplaintReceived VARCHAR(3);
-- Step 2: Update values based on Complain column
UPDATE customer_churn SET ComplaintReceived = CASE WHEN Complain = 1 THEN 'Yes' ELSE 'No' END;
-- view updated values
SELECT Complain,ComplaintReceived FROM customer_churn;

-- Create a new column named 'ChurnStatus'. Set its value to “Churned” if the corresponding value in the 'Churn' column is 1, else assign “Active”. 
DESCRIBE customer_churn;
-- Step 1: Add the new column
ALTER TABLE customer_churn ADD COLUMN ChurnStatus VARCHAR(10);
-- Step 2: Update values based on ChurnStatus column
UPDATE customer_churn
SET ChurnStatus = 
    CASE 
        WHEN Churn = 1 THEN 'Churned'
        ELSE 'Active'
    END;
-- view updated values
SELECT Churn,ChurnStatus FROM customer_churn;

-- ------------------------------------
-- Column Dropping: 
-- -------------------------------------
-- Drop the columns "Churn" and "Complain" from the table.
DESCRIBE customer_churn;
SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'ecomm' AND TABLE_NAME = 'customer_churn' 
AND (COLUMN_NAME = 'Churn' OR COLUMN_NAME = 'Complain');
  
ALTER TABLE customer_churn 
DROP COLUMN Churn;

ALTER TABLE customer_churn 
DROP COLUMN Complain;

/*
*************************************************************************************
							Data Exploration and Analysis
*************************************************************************************
*/
DESCRIBE customer_churn;
SELECT * FROM customer_churn;
-- Retrieve the count of churned and active customers from the dataset. 
SELECT COUNT(ChurnStatus) AS TotalChurn FROM customer_churn WHERE ChurnStatus= 'Churned' ;
SELECT COUNT(ChurnStatus) AS TotalActive FROM customer_churn WHERE ChurnStatus= 'Active' ;

SELECT ChurnStatus, COUNT(*) AS StatusCount FROM customer_churn
GROUP BY ChurnStatus;

-- Display the average tenure and total cashback amount of customers who churned. 
SELECT AVG(Tenure) AS Avg_Churned_Tenure,SUM(CashbackAmount) AS Tot_Churned_CashbackAmount 
FROM customer_churn WHERE ChurnStatus= 'Churned';

-- Determine the percentage of churned customers who complained. 
SELECT 
    ( 
		(SELECT COUNT(CustomerID) FROM customer_churn WHERE ComplaintReceived = 'Yes' AND ChurnStatus = 'Churned') * 100.0
		  / 
		(SELECT COUNT(CustomerID) FROM customer_churn WHERE ChurnStatus = 'Churned' )
    ) AS ComplaintPercentage;

SELECT (COUNT(CASE WHEN ComplaintReceived = 'Yes' THEN 1 END) * 100.0 
		/ COUNT(*)) AS Complaint_Percent_Churned
FROM customer_churn WHERE ChurnStatus = 'Churned';

-- Identify the city tier with the highest number of churned customers whose preferred order category is Laptop & Accessory.
SELECT CityTier, COUNT(*) AS No_Of_Cust FROM  customer_churn 
WHERE ChurnStatus = 'Churned' AND PreferredOrderCat='Laptop & Accessory' 
GROUP BY CityTier ORDER BY No_Of_Cust DESC LIMIT 1;

-- Identify the most preferred payment mode among active customers. 
SELECT PreferredPaymentMode,count(*) AS No_Of_Pay_Mode FROM customer_churn
WHERE ChurnStatus= 'Active' GROUP BY  PreferredPaymentMode ORDER BY No_Of_Pay_Mode DESC
LIMIT 1 ;

-- Calculate the total order amount hike from last year for customers who are single and prefer mobile phones for ordering. 
SELECT MaritalStatus,PreferredLoginDevice,SUM(OrderAmountHikeFromlastYear) AS Tot_Order_Amt_Hike_LastYear FROM customer_churn
WHERE MaritalStatus = 'Single' AND PreferredLoginDevice = 'Mobile Phone' 
GROUP BY MaritalStatus,PreferredLoginDevice; 

-- Find the average number of devices registered among customers who used UPI as their preferred payment mode. 
SELECT AVG(NumberOfDeviceRegistered) AS Avg_No_Of_Devices_Registered FROM customer_churn
WHERE PreferredPaymentMode = 'UPI';

-- Determine the city tier with the highest number of customers. 
SELECT CityTier,COUNT(*) AS No_Of_Customer FROM customer_churn
GROUP BY CityTier ORDER BY No_Of_Customer DESC LIMIT 1;

 -- Identify the gender that utilized the highest number of coupons. 
SELECT Gender,SUM(CouponUsed) AS Tot_CouponUsed from customer_churn
GROUP BY Gender ORDER BY Tot_CouponUsed DESC LIMIT 1 ; 

 -- List the number of customers and the maximum hours spent on the app in each preferred order category. 
SELECT PreferredOrderCat,COUNT(*) AS  No_of_Cust,MAX(HoursSpendOnApp) AS Max_Hours_Spend_On_App from customer_churn
GROUP BY PreferredOrderCat ORDER BY Max_Hours_Spend_On_App DESC ; 

-- Calculate the total order count for customers who prefer using credit cards and have the maximum satisfaction score. 
SELECT SUM(OrderCount) AS Tot_Order_Cust from customer_churn
WHERE PreferredPaymentMode = 'Credit Card' AND 
SatisfactionScore = (
	  SELECT MAX(SatisfactionScore) 
      FROM customer_churn
      WHERE PreferredPaymentMode = 'Credit Card'
);

-- What is the average satisfaction score of customers who have complained? 
SELECT AVG(SatisfactionScore) AS Avg_Satisfication_Score from customer_churn 
WHERE ComplaintReceived= 'Yes'; 

-- List the preferred order category among customers who used more than 5 coupons. 
SELECT PreferredOrderCat,CouponUsed from customer_churn 
WHERE CouponUsed > 5 ORDER BY CouponUsed ; 

SELECT DISTINCT PreferredOrderCat from customer_churn 
WHERE CouponUsed > 5; 

 -- List the top 3 preferred order categories with the highest average cashback amount. 
SELECT PreferredOrderCat,AVG(CashbackAmount) AS Avg_Cashback_Amt  from customer_churn
GROUP BY PreferredOrderCat ORDER BY Avg_Cashback_Amt DESC LIMIT 3;

 -- Find the preferred payment modes of customers whose average tenure is 10 months and have placed more than 500 orders. 
SELECT PreferredPaymentMode,Tenure,OrderCount from customer_churn ; 
SELECT PreferredPaymentMode,AVG(Tenure) AS Avg_Tenure,SUM(OrderCount) AS Tot_Orders from customer_churn 
GROUP BY PreferredPaymentMode HAVING Avg_Tenure > 10 AND Tot_Orders > 500; 

 -- Categorize customers based on their distance from the warehouse to home such as 'Very Close Distance' for distances <=5km, 'Close Distance' for <=10km, 
 -- 'Moderate Distance' for <=15km, and 'Far Distance' for >15km. Then, display the churn status breakdown for each distance category. 
-- Categorize customers by distance and show churn status breakdown
SELECT 
    CASE 
        WHEN WarehouseToHome <= 5 THEN 'Very Close Distance'
        WHEN WarehouseToHome <= 10 THEN 'Close Distance'
        WHEN WarehouseToHome <= 15 THEN 'Moderate Distance'
        ELSE 'Far Distance'
    END AS DistanceCategory,
ChurnStatus, COUNT(*) AS customer_count FROM customer_churn
GROUP BY DistanceCategory, ChurnStatus
ORDER BY DistanceCategory, ChurnStatus;

-- List the customer’s order details who are married, live in City Tier-1, and their order counts are more than the average number of orders placed by all customers. 
SELECT * from customer_churn
WHERE MaritalStatus = 'Married' AND CityTier='1' AND 
OrderCount >  (
	SELECT AVG(OrderCount) FROM customer_churn
); 
-- a)	Create a ‘customer_returns’ table in the ‘ecomm’ database and insert the following data
-- create table
CREATE TABLE customer_returns AS
SELECT * FROM customer_churn WHERE 1=0;   
SHOW TABLES;
-- insert data directly
INSERT INTO customer_returns
SELECT * from customer_churn
WHERE MaritalStatus = 'Married' AND CityTier='1' AND 
OrderCount >  (
	SELECT AVG(OrderCount) FROM customer_churn
); 
SELECT * FROM customer_returns;   

-- b)	Display the return details along with the customer details of those who have churned and have made complaints.
SELECT * FROM customer_returns 
WHERE ChurnStatus = 'Churned' AND ComplaintReceived='Yes';   

