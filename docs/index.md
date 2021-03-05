# User Defined Functions in SQL
**dev:**  *jcarnes*  
**date:**  *20210305*

## Introduction
This paper will discuss user defined functions in SQL. User defined functions are functions created by a programmer which can be called upon to retrieve, format, and process data. These functions can return a single value in the case of scalar functions or a table of values in the case of inline and multi-statement functions.

## SQL User Defined Functions
User defined functions are objects created by a programmer in SQL which help with retrieving, formatting, and processing data. User defined functions can either return a single value, in which they are called scalar functions, or they can return a table of values in which they are called table functions. Functions are helpful with reporting or can also be called within stored procedures. User defined functions can be setup with parameters so that variables may be passed through the function when it is called. Figure 1 shows a User Defined Table function setup which requires an argument of @KPI to be passed when called, this is then used to filter the select statement when results are returned. 


```
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
		 ORDER BY 1, 2
GO
```
**_Figure 1: Example user defined function with a parameter_**

## Scalar, Inline, and Multi-Statement Functions
A scalar function returns a single value. In many cases, but not all, the scaler functions may perform some sort of calculation such as Parameter 1 – Parameter 2 and the scaler function return the difference.  

Inline table valued functions are similar to views in that they are stored select statements. The advantage of an inline table valued function over a view however is that the inline function can have parameters which arguments are then passed to the select statement. 

Multi-statement functions are similar to inline table valued functions except that they can bet setup with more than one select statement. Unlike the Inline table valued function, the multi-statement function requires the table that will be returned in the function to be defined as a table variable and each of the select statements within the function are inserted into this table variable which is then returned.  

## Summary
User defined functions are helpful for retrieving, formatting, and processing data. Parameters can be included in the functions which then allow for variables to be passed when the function is called. User defined functions can be scalar functions which return a single value, or they can return a table of data as is the case for inline and multi-statement functions. Inline functions return a single select statement while multi-statement functions can return data from multiple select statements.
