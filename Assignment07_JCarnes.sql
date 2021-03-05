--*************************************************************************--
-- Title: Assignment07
-- Author: Jessica Carnes
-- Desc: This file demonstrates how to use Functions
-- Change Log: When,Who,What
-- 2021-02-26,JCarnes,Created File & Answered Question 1-7 
-- 2021-03-01,JCarnes,Updated Order by statements in question 5,6, 7
-- 2021-03-03,JCarnes,Answered queestion 8, created function to pull back table based on KPI
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment07DB_JCarnes')
	 Begin 
	  Alter Database [Assignment07DB_JCarnes] set Single_user With Rollback Immediate;
	  Drop Database Assignment07DB_JCarnes;
	 End
	Create Database Assignment07DB_JCarnes;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment07DB_JCarnes;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [money] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL
,[ProductID] [int] NOT NULL
,[ReorderLevel] int NOT NULL -- New Column 
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, ReorderLevel, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, ReorderLevel, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, ReorderLevel, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, ReorderLevel, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Order By 1, 2
go

-- Adding Views (Module 06) -- 
Create View vCategories With SchemaBinding
 AS
  Select CategoryID, CategoryName From dbo.Categories;
go
Create View vProducts With SchemaBinding
 AS
  Select ProductID, ProductName, CategoryID, UnitPrice From dbo.Products;
go
Create View vEmployees With SchemaBinding
 AS
  Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID From dbo.Employees;
go
Create View vInventories With SchemaBinding 
 AS
  Select InventoryID, InventoryDate, EmployeeID, ProductID, ReorderLevel, [Count] From dbo.Inventories;
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From vCategories;
go
Select * From vProducts;
go
Select * From vEmployees;
go
Select * From vInventories;
go

/********************************* Questions and Answers *********************************/
--'NOTES------------------------------------------------------------------------------------ 
-- 1) You must use the BASIC views for each table.
-- 2) Remember that Inventory Counts are Randomly Generated. So, your counts may not match mine
-- 3) To make sure the Dates are sorted correctly, you can use Functions in the Order By clause!
------------------------------------------------------------------------------------------'
-- Question 1 (5% of pts): What built-in SQL Server function can you use to show a list 
-- of Product names, and the price of each product, with the price formatted as US dollars?
-- Order the result by the product!

-- <Put Your Code Here> --
/*
SELECT ProductName, UnitPrice
FROM dbo.vProducts
GO
*/
SELECT 
   ProductName
  ,[UnitPrice] = FORMAT(UnitPrice, 'C', 'en-US')
FROM dbo.vProducts
ORDER BY ProductName ASC
GO

-- Question 2 (10% of pts): What built-in SQL Server function can you use to show a list 
-- of Category and Product names, and the price of each product, 
-- with the price formatted as US dollars?
-- Order the result by the Category and Product!

-- <Put Your Code Here> --
/*
SELECT c.CategoryName, p.ProductName, p.UnitPrice --Starting with Code from Assignment05 question 1
FROM dbo.vCategories c INNER JOIN dbo.vProducts p 
  ON c.CategoryID = p.CategoryID
ORDER BY CategoryName ASC, ProductName ASC;
GO
*/
SELECT 
   c.CategoryName
  ,p.ProductName
  ,[UnitPrice] = FORMAT(p.UnitPrice, 'C', 'en-US')
FROM dbo.vCategories c INNER JOIN dbo.vProducts p 
  ON c.CategoryID = p.CategoryID
ORDER BY CategoryName ASC, ProductName ASC;
GO

-- Question 3 (10% of pts): What built-in SQL Server function can you use to show a list 
-- of Product names, each Inventory Date, and the Inventory Count,
-- with the date formatted like "January, 2017?" 
-- Order the results by the Product, Date, and Count!

-- <Put Your Code Here> --
/*
SELECT p.ProductName, i.InventoryDate, i.Count --Starting with question 2 of assignment05
FROM dbo.vInventories i INNER JOIN dbo.vProducts p
  ON i.ProductID = p.ProductID
ORDER BY p.ProductName ASC, i.InventoryDate ASC, i.Count DESC;
GO
*/

SELECT 
   p.ProductName
  ,[InventoryDate] = DATENAME(mm,i.InventoryDate) + ', ' + DATENAME(YEAR, i.InventoryDate)
  ,[InventoryCount] = i.Count
FROM dbo.vInventories i INNER JOIN dbo.vProducts p
  ON i.ProductID = p.ProductID
ORDER BY p.ProductName ASC, i.InventoryDate ASC, i.Count DESC;
GO

-- Question 4 (10% of pts): How can you CREATE A VIEW called vProductInventories 
-- That shows a list of Product names, each Inventory Date, and the Inventory Count, 
-- with the date FORMATTED like January, 2017? Order the results by the Product, Date,
-- and Count!

-- <Put Your Code Here> --
CREATE VIEW vProductInventories
AS
	SELECT TOP 1000000000
	   p.ProductName
	  ,[InventoryDate] = DATENAME(mm,i.InventoryDate) + ', ' + DATENAME(YEAR, i.InventoryDate)
	  ,[InventoryCount] = i.Count
	FROM dbo.vInventories i INNER JOIN dbo.vProducts p
	  ON i.ProductID = p.ProductID
	ORDER BY p.ProductName ASC, i.InventoryDate ASC, i.Count DESC;
GO
-- Check that it works: Select * From vProductInventories;
SELECT *
FROM vProductInventories;
GO

-- Question 5 (10% of pts): How can you CREATE A VIEW called vCategoryInventories 
-- that shows a list of Category names, Inventory Dates, 
-- and a TOTAL Inventory Count BY CATEGORY, with the date FORMATTED like January, 2017?

-- <Put Your Code Here> --
/*
--Starting with solution to Assignment05 question 4
SELECT c.CategoryName, p.ProductName, i.InventoryDate, i.Count
FROM dbo.vCategories c INNER JOIN dbo.vProducts p
  ON c.CategoryID = p.CategoryID
 INNER JOIN dbo.vinventories i
  ON i.ProductID = p.ProductID
ORDER BY c.CategoryName ASC, p.ProductName ASC, i.InventoryDate ASC, i.Count DESC;
GO

SELECT 
   c.CategoryName
  ,i.InventoryDate
  ,[InventoryCountByCategory] = SUM(i.Count)
FROM dbo.vCategories c INNER JOIN dbo.vProducts p
  ON c.CategoryID = p.CategoryID
 INNER JOIN dbo.vinventories i
  ON i.ProductID = p.ProductID
GROUP BY c.CategoryName, i.InventoryDate
ORDER BY c.CategoryName ASC, i.InventoryDate ASC
GO
*/
CREATE VIEW vCategoryInventories
AS
	SELECT TOP 1000000000
	   c.CategoryName
	  ,[InventoryDate] = DATENAME(mm,i.InventoryDate) + ', ' + DATENAME(YEAR, i.InventoryDate)
	  ,[InventoryCountByCategory] = SUM(i.Count)
	FROM dbo.vCategories c INNER JOIN dbo.vProducts p
	  ON c.CategoryID = p.CategoryID
	 INNER JOIN dbo.vinventories i
	  ON i.ProductID = p.ProductID
	GROUP BY c.CategoryName, i.InventoryDate
	ORDER BY c.CategoryName ASC, i.InventoryDate ASC;
GO

-- Check that it works: Select * From vCategoryInventories;
SELECT *
FROM dbo.vCategoryInventories;
GO

-- Question 6 (10% of pts): How can you CREATE ANOTHER VIEW called 
-- vProductInventoriesWithPreviouMonthCounts to show 
-- a list of Product names, Inventory Dates, Inventory Count, AND the Previous Month
-- Count? Use a functions to set any null counts or 1996 counts to zero. Order the
-- results by the Product, Date, and Count. This new view must use your
-- vProductInventories view!

-- <Put Your Code Here> --
/*
SELECT *
FROM dbo.vProductInventories;
GO

SELECT c.ProductName, c.InventoryDate, c.InventoryCount, [PriorMonthDate] = DATEADD(mm, -1, c.InventoryDate)
FROM dbo.vProductInventories c;
GO

SELECT c.ProductName, c.InventoryDate, c.InventoryCount, [PriorMonthDate] = DATEADD(mm, -1, c.InventoryDate), p.*
FROM dbo.vProductInventories c LEFT OUTER JOIN dbo.vProductInventories p
  ON c.ProductName = p.ProductName
     AND DATEADD(mm, -1, c.InventoryDate) = p.InventoryDate
GO

SELECT c.ProductName, c.InventoryDate, c.InventoryCount, [PreviousMonthCount] = p.InventoryCount
FROM dbo.vProductInventories c LEFT OUTER JOIN dbo.vProductInventories p
  ON c.ProductName = p.ProductName
     AND DATEADD(mm, -1, c.InventoryDate) = p.InventoryDate
GO

SELECT c.ProductName, c.InventoryDate, c.InventoryCount, [PreviousMonthCount] = ISNULL(p.InventoryCount,0)
FROM dbo.vProductInventories c LEFT OUTER JOIN dbo.vProductInventories p
  ON c.ProductName = p.ProductName
     AND DATEADD(mm, -1, c.InventoryDate) = p.InventoryDate;
GO
*/
--No need to specify 1996 values as 0 as this is self joining on the previous month using a left join
--Therefore all 1996 values will be NULL and be taken care of in the ISNULL statement
--I wrote this before Professor Root's additional video explaining lag and lead
--I think this is a better way as it doesn't require a specific year to be hard coded,
--rather the left join will leave the first period as a NULL regardless of the year
CREATE VIEW vProductInventoriesWithPreviouMonthCounts
AS
	SELECT TOP 1000000000
	   c.ProductName
	  ,c.InventoryDate
	  ,c.InventoryCount
	  ,[PreviousMonthCount] = ISNULL(p.InventoryCount,0)
	FROM dbo.vProductInventories c LEFT OUTER JOIN dbo.vProductInventories p
	  ON c.ProductName = p.ProductName
		 AND DATEADD(mm, -1, c.InventoryDate) = p.InventoryDate
	ORDER BY c.ProductName ASC, CAST(c.InventoryDate AS DATE) ASC, c.InventoryCount DESC;
GO

-- Check that it works: Select * From vProductInventoriesWithPreviousMonthCounts;
SELECT *
FROM dbo.vProductInventoriesWithPreviouMonthCounts;
GO


-- Question 7 (20% of pts): How can you CREATE one more VIEW 
-- called vProductInventoriesWithPreviousMonthCountsWithKPIs
-- to show a list of Product names, Inventory Dates, Inventory Count, the Previous Month 
-- Count and a KPI that displays an increased count as 1, 
-- the same count as 0, and a decreased count as -1? Order the results by the 
-- Product, Date, and Count!

-- <Put Your Code Here> --
/*SELECT *
FROM dbo.vProductInventoriesWithPreviouMonthCounts;
GO

SELECT 
   ProductName
  ,InventoryDate
  ,InventoryCount
  ,PreviousMonthCount
  ,[Test Diff] = InventoryCount - PreviousMonthCount
  ,[CountvsPreviousCountKPI] = 
     CASE 
	    WHEN InventoryCount > PreviousMonthCount THEN  1
		WHEN InventoryCount < PreviousMonthCount THEN -1
		WHEN InventoryCount = PreviousMonthCount THEN  0	
     END

*/
CREATE VIEW vProductInventoriesWithPreviousMonthCountsWithKPIs
AS
	SELECT TOP 1000000000
	   ProductName
	  ,InventoryDate
	  ,InventoryCount
	  ,PreviousMonthCount
	  ,[CountVsPreviousCountKPI] = 
		 CASE 
			WHEN InventoryCount > PreviousMonthCount THEN  1
			WHEN InventoryCount < PreviousMonthCount THEN -1
			WHEN InventoryCount = PreviousMonthCount THEN  0	
		 END
	FROM dbo.vProductInventoriesWithPreviouMonthCounts
	ORDER BY ProductName ASC, CAST(InventoryDate AS DATE) ASC, InventoryCount DESC;
GO

-- Important: This new view must use your vProductInventoriesWithPreviousMonthCounts view!
-- Check that it works: Select * From vProductInventoriesWithPreviousMonthCountsWithKPIs;
SELECT *
FROM dbo.vProductInventoriesWithPreviousMonthCountsWithKPIs;
GO

-- Question 8 (25% of pts): How can you CREATE a User Defined Function (UDF) 
-- called fProductInventoriesWithPreviousMonthCountsWithKPIs
-- to show a list of Product names, Inventory Dates, Inventory Count, the Previous Month
-- Count and a KPI that displays an increased count as 1, the same count as 0, and a
-- decreased count as -1 AND the result can show only KPIs with a value of either 1, 0,
-- or -1? This new function must use you
-- ProductInventoriesWithPreviousMonthCountsWithKPIs view!
-- Include an Order By clause in the function using this code: 
-- Year(Cast(v1.InventoryDate as Date))
-- and note what effect it has on the results.

-- <Put Your Code Here> --

CREATE FUNCTION fProductInventoriesWithPreviousMonthCountsWithKPIs(@KPI INT)
	RETURNS TABLE
	AS
	RETURN
		SELECT TOP 1000000000
		     ProductName
		    ,InventoryDate
		    ,InventoryCount
		    ,PreviousMonthCount
			,CountVsPreviousCountKPI
		 FROM dbo.vProductInventoriesWithPreviousMonthCountsWithKPIs
		 WHERE CountVsPreviousCountKPI = @KPI 
		 ORDER BY ProductName ASC, YEAR(CAST(InventoryDate AS DATE)) ASC, MONTH(CAST(InventoryDate AS DATE)) ASC, InventoryCount DESC;
		 --YEAR(CAST(InventoryDate AS DATE)) orders by year
		 --I've added added a second order by to order by year then month
GO

/* Check that it works:
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(1);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(0);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(-1);
*/
SELECT * FROM fProductInventoriesWithPreviousMonthCountsWithKPIs(1);
SELECT * FROM fProductInventoriesWithPreviousMonthCountsWithKPIs(0);
SELECT * FROM fProductInventoriesWithPreviousMonthCountsWithKPIs(-1);
GO

/***************************************************************************************/