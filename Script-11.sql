/* 
CAPSTONE: RETAIL ANALYTICS: PREDICTING CUSTOMER PURCHASE BEHAVIOR 

DATA ANALYST: INIGO ARBOLEDA
DATE: MAY 2026
-----------------------------
Business Introduction:
Welcome to RetailVC's Retail Analytics Solutions, a leading provider of data-driven solutions for retail businesses. RetailVC specializes in using advanced analytics techniques to help retailers optimize their operations, enhance customer experiences, and drive business growth. Its mission is to empower retail organizations with actionable insights that enable them to make informed decisions, improve performance, and remain competitive in today's dynamic marketplace.

Problem Statement:
The goal of this capstone project is to develop a comprehensive understanding of customer behavior and preferences based on retail transaction data. The aim is to analyze customers' demographic information, purchasing patterns, and interactions with marketing campaigns to identify key insights. These insights will inform strategic decision-making and drive business growth. Specifically, the focus will be on predicting customers' responses to marketing campaigns and optimizing promotional strategies to maximize their effectiveness and return on investment (ROI).

Note: For this project, you will use the datasets: cc_data.csv and location_data.csv. The link to the dataset is provided at the end of the document.

Excel Tasks:
1.Data Exploration:
- Create a statistical summary for numerical features
- Create a line chart for the number of enrolments by year
- Give a cross-tabulated count for response values against education
- Make a boxplot on income and write your observations
- Calculate the age of customers and make a histogram of that
- Visualize the response against Marital_Status

SQL Tasks:
2. Data Loading:
- Create a schema named "retail_data"
- Set "retail_data" as the default schema
- Create tables to store the retail transaction data
- Set ct_customer as the datetime field while loading the data and apply the appropriate date format
3. Data Preprocessing:
- Calculate the total number of customer encounters in the marketing campaign dataset
- Identify the top 10 most purchased products in the dataset, such as Wines, Meat Products, etc.
- Find the count of response values
- Determine the distribution of customers based on their education level and marital status
- Identify the average income of customers who participated in the marketing campaign
- Calculate the total number of promotions accepted by customers in each campaign
- Identify the distribution of customers' responses to the last campaign
- Calculate the average number of children and teenagers in customers' households
- Create an Age column by subtracting year_birth from the current year 
- Create Age_group columns based on the below condition:
WHEN Age BETWEEN 18 AND 25 THEN '18-25'
WHEN Age BETWEEN 26 AND 35 THEN '26-35'
WHEN Age BETWEEN 36 AND 45 THEN '36-45'
WHEN Age BETWEEN 46 AND 55 THEN '46-55'
ELSE '56+'
Determine the average number of visits per month for customers in each age group

Python Tasks:
4.Exploratory Data Analysis
- General Data Overview:
- Check the first few rows of the dataset to understand its structure
- Check the data types of each column
- Check for any missing values in the dataset
Descriptive Statistics:
- Compute summary statistics for numerical columns (mean, median, min, max, and standard deviation)
- Explore the distribution of numerical variables using histograms or box plots
Univariate Analysis:
- Explore the distribution of each numerical variable using histograms or kernel density plots
- Explore the distribution of each categorical variable using bar plots or pie charts
- Identify outliers in numerical variables using box plots or scatter plots
Bivariate Analysis:
- Explore the relationship between numerical variables and the target variable (Response) using scatter plots or correlation matrices
- Explore the relationship between categorical variables and the target variable using bar plots or chi-square tests
- Explore the relationship between numerical and categorical variables using box plots or violin plots

Observations: Write an analysis report on performing exploratory data analysis (EDA) using Python in the context of building a fraud detection system for Retail Analytics

Tableau Tasks:
5.Visualize Customer Income Distribution grouped by Year of Registration
- Examine the breakdown of education levels and marital status using side-by-side circles to represent count
- Explore the relationship between Income and Wine Spending
- Analyze the frequency of purchases across various product categories
- Create a dashboard using all the visualizations
- Input dataset link: DatasetLinks to an external site.

*/
-- ACTION: CREATING TABLES
CREATE TABLE IF NOT EXISTS marketing_campaign (
	ID	Integer primary key not null,
	Year_Birth	Integer,
	Education	Varchar (100),
	Marital_Status	Varchar (100),
	Income	Decimal (12,2),
	Kidhome	Integer,
	Teenhome	 Integer,
	Dt_Customer	Date,
	Recency	Integer,
	Complain	 Integer,
	MntWines	 Integer,
	MntFruits	Integer,
	MntMeatProducts	Integer,
	MntFishProducts	Integer,
	MntSweetProducts	Integer,
	MntGoldProds	 Integer,
	NumDealsPurchases	Integer,
	AcceptedCmp1	 Integer,
	AcceptedCmp2 	Integer,
	AcceptedCmp3 	Integer,
	AcceptedCmp4	 Integer,
	AcceptedCmp5	 Integer,
	Response	 Integer,
	NumWebPurchases	Integer,
	NumCatalogPurchases	Integer,
	NumStorePurchases	Integer,
	NumWebVisitsMonth	Integer
)
;

-- DATA CHECK the newly created table
select *
from marketing_campaign
;
-- data was loaded by 'importing' csv file from excel dataset into the marketing_campaign table.

-- DATA EXPLORATORY/Inspecting:
select *
from marketing_campaign 
limit 5
;

-- Update Alone → Single
UPDATE marketing_campaign
SET Marital_Status = 'Single'
WHERE Marital_Status = 'Alone';

-- Remove junk entries
DELETE FROM marketing_campaign
WHERE Marital_Status IN ('Absurd', 'YOLO');

-- Updates made under marital status column
select marital_status
from marketing_campaign ;

/* reason for updates; alone felt redundant, so I updated alone into single
 * I removed absurd and yolo from the dataset as there were only a total of 4 junk rows. 4 out of 2,240 - 0.18% neglible loss
 */

-- ACTION: DATE FORMATTING: YYYY-MM-DD
select 
	dt_customer
from marketing_campaign
limit 20;

UPDATE marketing_campaign
SET Dt_Customer =
    '20' || substr(Dt_Customer, length(Dt_Customer)-1)
    || '-'
    || printf('%02d', CAST(substr(Dt_Customer, 1, instr(Dt_Customer,'/')-1) AS INTEGER))
    || '-'
    || printf('%02d', CAST(substr(substr(Dt_Customer, instr(Dt_Customer,'/')+1), 1, instr(substr(Dt_Customer, instr(Dt_Customer,'/')+1),'/')-1) AS INTEGER))
WHERE Dt_Customer LIKE '%/%/%';

UPDATE marketing_campaign
SET Dt_Customer = substr(Dt_Customer, 1, 10)
WHERE Dt_Customer LIKE '____-__-__%';

SELECT DISTINCT Dt_Customer
FROM marketing_campaign
LIMIT 30;

-- ACTION:CALCULATING THE TOTAL NUMBER OF CUSTOMER ENCOUNTERS (ROWS) IN THE DATASET
select 
	count (*) as total_customer_encounters
from
marketing_campaign;
-- ANSWER: 2236 CUSTOMERS 

-- ACTION: Identify the top 10 most purchased products in the dataset, such as Wines, Meat Products, etc. by total spend
select
	'Wines' as product,
	sum(MntWines) as total_spend
from marketing_campaign;
-- total spend on wine: 679,461

select 
	'Meat Products' as product,
	sum(mntmeatproducts) as total_spend
from marketing_campaign;
-- total spend on meat products: 373,243

select 
	'Gold Products' as product,
	sum(mntgoldprods) as total_spend
from marketing_campaign;
-- total spend on gold products: 98,117

select 
	'Fish Products' as product,
	sum(mntfishproducts) as total_spend
from marketing_campaign;
-- total spend on fish produts: 83,638

select 
	'Sweet Products' as product,
	sum(mntsweetproducts) as total_spend
from marketing_campaign;
-- total spend on sweet products: 60,554

select 
	'Fruits' as product,
	sum(mntfruits) as total_spend
from marketing_campaign;
-- total spend on fruits products: 58,742

-- UNION ALL QUERY
SELECT 
    'Wines' AS product, 
    SUM(MntWines) AS total_spend FROM marketing_campaign
UNION ALL
SELECT 
    'Meat Products', 
    SUM(MntMeatProducts)               
    FROM marketing_campaign
UNION ALL
SELECT 
    'Gold Products',
	SUM(MntGoldProds)                  
	FROM marketing_campaign
UNION ALL
SELECT 
    'Fish Products',              
    SUM(MntFishProducts)               
    FROM marketing_campaign
UNION ALL
SELECT 
    'Sweet Products',             
    SUM(MntSweetProducts)              
    FROM marketing_campaign
UNION ALL
SELECT 
    'Fruits',                     
    SUM(MntFruits)                     
    FROM marketing_campaign
ORDER BY total_spend DESC;

/*
 Wines	- 679,461
 Meat Products	- 373,243
 Gold Products	- 98,117
 Fish Products	- 83,638
 Sweet Products	- 60,554
 Fruits	- 58,742
 */

-- ACTION: FIND THE COUNT OF RESPONSIVE VALUES
SELECT 
	Response, 
	COUNT(*) AS count
FROM marketing_campaign
GROUP BY 
	Response;
/* Reponse 0 - count 1,904
 * Response 1 - count 332
 	-- This shows me that more customers are not inclined to the marketing campaigns
*/

-- ACTION: Determine the distribution of customers based on their education level and marital status
select
	education,
	marital_status,
	count(*) as customer_count
from marketing_campaign
group by 
	education,
	marital_status
order by 
	education, 
	customer_count desc;
/* 25 rows 
 * data: see CSV 
 */

-- ACTION: Identify the average income of customers who participated in the marketing campaign
SELECT 
ROUND(AVG(" Income " ), 2) AS avg_income
FROM marketing_campaign
WHERE "Income";
-- Results: 52247.25 average income 

-- ACTION: Calculate the total number of promotions accepted by customers in each campaign
SELECT
    SUM(AcceptedCmp1) AS Campaign_1_Accepted,
    SUM(AcceptedCmp2) AS Campaign_2_Accepted,
    SUM(AcceptedCmp3) AS Campaign_3_Accepted,
    SUM(AcceptedCmp4) AS Campaign_4_Accepted,
    SUM(AcceptedCmp5) AS Campaign_5_Accepted
FROM marketing_campaign;
/* Campaign_1_Accepted - 143,
   Campaign_2_Accepted - 30,
   Campaign_3_Accepted - 163,
   Campaign_4_Accepted - 167,
   Campaign_5_Accepted - 162
   */

-- ACTION: Identify the distribution of customers' responses to the last campaign
SELECT
    CASE Response WHEN 1 THEN 'Responded' ELSE 'Did Not Respond' END AS response_label,
    COUNT(*) AS customer_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM marketing_campaign
GROUP BY Response;
/* DID NOT RESPOND: 1904 COUNT 85.14%
 * RESPONDED: 332 COUNT 14.85%
 1 and 0 were the only responses so I used 1 as responded
 */

-- ACTION: Calculate the average number of children and teenagers in customers' households
select
	round(avg(kidhome), 2) as avg_children,
	round(avg(teenhome), 2) as avg_teenagers
from marketing_campaign
;
/* AVG_CHILDREN : 0.44 %
 * AVG_TEENAGERS : 0.51%
 */

-- ACTION: Create an Age column by subtracting year_birth from the current year 
ALTER TABLE marketing_campaign
ADD COLUMN Age INTEGER;

UPDATE marketing_campaign
SET Age = strftime('%Y', 'now') - Year_Birth;
	-- 'now' todays date
	--'%y' extracts the digit year 

SELECT ID, Year_Birth, Age
FROM marketing_campaign
LIMIT 10;

/* ID 0 BORN IN 1985 IS 41 YRS OLD
 * ID 1 BORN IN 1961 IS 65 YRS OLD
 * ID 9 born in 1975 is 51 yrs old
 */


/* ACTION: Create Age_group columns based on the below condition:
WHEN Age BETWEEN 18 AND 25 THEN '18-25'
WHEN Age BETWEEN 26 AND 35 THEN '26-35'
WHEN Age BETWEEN 36 AND 45 THEN '36-45'
WHEN Age BETWEEN 46 AND 55 THEN '46-55'
ELSE '56+'*/
ALTER TABLE marketing_campaign
ADD COLUMN Age_Group TEXT;

UPDATE marketing_campaign
SET Age_Group = 
    CASE
        WHEN Age BETWEEN 18 AND 25 THEN '18-25'
        WHEN Age BETWEEN 26 AND 35 THEN '26-35'
        WHEN Age BETWEEN 36 AND 45 THEN '36-45'
        WHEN Age BETWEEN 46 AND 55 THEN '46-55'
        ELSE '56+'
    END;

-- DATA CHECK:
SELECT 
	ID, 
	Year_Birth, 
	Age, 
	Age_Group
FROM marketing_campaign
LIMIT 10;


-- ACTION: Determine the average number of web visits per month for customers in each age group
SELECT 
    Age_Group,
    ROUND(AVG(NumWebVisitsMonth), 2) AS avg_visits_per_month
FROM marketing_campaign
GROUP BY Age_Group
ORDER BY Age_Group asc;
/*
 * 26-35 : 4.52%
 * 36-45 : 5.56%
 * 46-55 : 5.7%
 * 56+ : 5.04%
 */

-- ACTION: CREATING A NEW COLUMN CALLED 'RESPONSE TOTAL' TO THE DATASET
UPDATE marketing_campaign
SET Response_Total = 
    AcceptedCmp1 + AcceptedCmp2 + AcceptedCmp3 + AcceptedCmp4 + AcceptedCmp5 + Response;
	-- VERIFY THE UPDATE
SELECT 
	ID, 
	AcceptedCmp1, 
	AcceptedCmp2, 
	AcceptedCmp3, 
	AcceptedCmp4, 
	AcceptedCmp5, 
	Response, 
	Response_Total
FROM marketing_campaign
LIMIT 10;
/* THIS COLUMN WILL SHOW HOW MANY TIMES A CUSTOMER (USING THE CUSTOMER ID) HAS RESPONDED TO ANY OF THE CAMPAIGNS (CMP1-CMP5)
 * FOR EX: ID 1 RESPONDED TO CMP 1 AND THE LAST CMP RESPONSE RESULTING IN 2 TOTAL RESPONSE
 */


/* ALTER TABLE IS CREATING THE COLUMN/SPACE
 * UPDATE IS FILLING IN VALUES INTO THAT COLUMN
 * ALWAYS USED TOGETHER
 */

/*deleting col customer count 
alter table marketing_campaign 
drop column customer count */

-- ACTION: CHANGING DATE FORMAT TO FOLLOW MM-DD-YYYY
UPDATE marketing_campaign
SET Dt_Customer = strftime('%m-%d-%Y', Dt_Customer);
-- verify
SELECT 
	dt_customer
FROM marketing_Campaign;
/* dates are now: 04-05-2013*/

--FINAL DATA SET
select *
from marketing_campaign;

