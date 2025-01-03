create database project;

use project;

select * from fact_sales;
select * from dimcustomer;
select * from dimdate;
select * from dimproduct;
select * from dimproductcategory;
select * from dimproductsubcategory;
select * from dimsalesterritory;

ALTER TABLE fact_sales
MODIFY COLUMN SalesAmount DECIMAL(10,2),
MODIFY COLUMN TaxAmt DECIMAL(10,3),
MODIFY COLUMN Freight DECIMAL(10,3),
MODIFY COLUMN TotalProductCost DECIMAL(10,2),
MODIFY COLUMN ProductStandardCost DECIMAL(10,2),
MODIFY COLUMN UnitPrice DECIMAL(10,2);

select fs.* ,dp.EnglishProductName from dimproduct dp JOIN fact_sales fs on dp.ProductKey=fs.ProductKey;

select fs.* ,dc.CustomerFullName from fact_sales fs
 JOIN dimcustomer dc on dc.CustomerKey=fs.CustomerKey;


SELECT 
    *,
    STR_TO_DATE(OrderDateKey, '%Y%m%d') AS OrderDate, 
    MONTH(STR_TO_DATE(OrderDateKey, '%Y%m%d')) AS Month,
    MONTHNAME(STR_TO_DATE(OrderDateKey, '%Y%m%d')) AS MonthName, 
    CONCAT('Q', QUARTER(STR_TO_DATE(OrderDateKey, '%Y%m%d'))) AS Quarter,
    DATE_FORMAT(STR_TO_DATE(OrderDateKey, '%Y%m%d'), '%Y-%b') AS YearMonth,
    DAYOFWEEK(STR_TO_DATE(OrderDateKey, '%Y%m%d')) AS WeekdayNo,
    DAYNAME(STR_TO_DATE(OrderDateKey, '%Y%m%d')) AS WeekdayName,
    CASE 
        WHEN MONTH(STR_TO_DATE(OrderDateKey, '%Y%m%d')) >= 4 
        THEN MONTH(STR_TO_DATE(OrderDateKey, '%Y%m%d')) - 3 
        ELSE MONTH(STR_TO_DATE(OrderDateKey, '%Y%m%d')) + 9 
    END AS FinancialMonth,
    CASE 
        WHEN MONTH(STR_TO_DATE(OrderDateKey, '%Y%m%d')) BETWEEN 4 AND 6 THEN 'Q1'
        WHEN MONTH(STR_TO_DATE(OrderDateKey, '%Y%m%d')) BETWEEN 7 AND 9 THEN 'Q2'
        WHEN MONTH(STR_TO_DATE(OrderDateKey, '%Y%m%d')) BETWEEN 10 AND 12 THEN 'Q3'
        ELSE 'Q4' 
    END AS FinancialQuarter
FROM 
    fact_sales;

SELECT *,
    ((UnitPrice * OrderQuantity) * (1 - UnitPriceDiscountPct)) AS SalesAmount 
FROM 
    fact_sales;
    
SELECT *,
    (ProductStandardCost * OrderQuantity) AS ProductionCost
FROM 
    fact_sales;
    
SELECT *, 
    (((UnitPrice * OrderQuantity) * (1 - UnitPriceDiscountPct))-((ProductStandardCost * OrderQuantity)+TaxAmt+Freight)) AS Profit
FROM 
    fact_sales;
    
/*year should be from 2010-2014*/
call Get_monthname_salesamt('2011');
    
Select  YEAR(STR_TO_DATE(OrderDateKey, '%Y%m%d')) as Year,sum(SalesAmount) from fact_sales
group by Year
order by YEAR(STR_TO_DATE(OrderDateKey, '%Y%m%d'));

Select  MONTHNAME(STR_TO_DATE(OrderDateKey, '%Y%m%d')) AS MonthFullName,sum(SalesAmount) from fact_sales
group by MONTH(STR_TO_DATE(OrderDateKey, '%Y%m%d')), MonthFullName
order by MONTH(STR_TO_DATE(OrderDateKey, '%Y%m%d'));

Select concat('Q',Quarter(STR_TO_DATE(OrderDateKey, '%Y%m%d'))) as Quarter,sum(SalesAmount) from fact_sales
group by Quarter
order by Quarter asc;

Select SalesAmount, (ProductStandardCost * OrderQuantity) AS ProductionCost from fact_sales;

Select 
    dp.EnglishProductName as ProductName,
	sum(fs.SalesAmount) as SalesByProduct from fact_sales fs
    join dimproduct dp on fs.ProductKey = dp.ProductKey
group by ProductName
Order by SalesByProduct desc
limit 10;

Select 
    dp.EnglishProductName as ProductName,
	sum(fs.SalesAmount) as SalesByProduct,
    sum( (((fs.UnitPrice * fs.OrderQuantity) * (1 - fs.UnitPriceDiscountPct))-((fs.ProductStandardCost * fs.OrderQuantity)+fs.TaxAmt+fs.Freight)) ) as ProfitByProduct from fact_sales fs
    join dimproduct dp on fs.ProductKey = dp.ProductKey
group by ProductName
Order by SalesByProduct desc
limit 10;

SELECT 
    dp.EnglishProductName as ProductName,
    SUM(fs.SalesAmount) AS SalesByProduct, 
    SUM(SUM(fs.SalesAmount)) OVER (ORDER BY SUM(fs.SalesAmount) DESC) AS CumulativeSales FROM fact_sales fs
    join dimproduct dp on fs.ProductKey = dp.ProductKey
GROUP BY ProductName
ORDER BY SalesByProduct DESC; 

Select 
    dc.CustomerFullName as CustomerName,
	sum(fs.SalesAmount) as SalesByCustomer from fact_sales fs
    join dimcustomer dc on fs.CustomerKey = dc.CustomerKey
group by CustomerName
Order by SalesByCustomer desc
limit 10;

SELECT 
    ds.SalesTerritoryRegion,
    SUM(fs.SalesAmount) AS Sales,
    SUM(
        ((fs.UnitPrice * fs.OrderQuantity) * (1 - fs.UnitPriceDiscountPct)) 
        - ((fs.ProductStandardCost * fs.OrderQuantity) + fs.TaxAmt + fs.Freight)
    ) AS Profit
FROM 
    fact_sales fs
JOIN 
    dimsalesterritory ds 
    ON fs.SalesTerritoryKey = ds.SalesTerritoryKey
GROUP BY 
    ds.SalesTerritoryRegion
ORDER BY 
    Sales DESC;

select sum(SalesAmount) as TotalSales from fact_sales;
select sum( (((UnitPrice * OrderQuantity) * (1 - UnitPriceDiscountPct))-((ProductStandardCost * OrderQuantity)+TaxAmt+Freight))) as TotalProfit from fact_sales;
select sum((ProductStandardCost * OrderQuantity)) as TotalProductionCost from fact_sales;
