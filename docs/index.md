# User Defined Functions in SQL
**dev:**  *jcarnes*  
**date:**  *20210305*

## Introduction
This paper will discuss user defined functions in SQL. User defined functions are functions created by a programmer which can be called upon to retrieve, format, and process data. These functions can return a single value in the case of scalar functions or a table of values in the case of inline and multi-statement functions.

## SQL User Defined Functions
User defined functions are objects created by a programmer in SQL which help with retrieving, formatting, and processing data. User defined functions can either return a single value, in which they are called scalar functions, or they can return a table of values in which they are called table functions. Functions are helpful with reporting or can also be called within stored procedures. User defined functions can be setup with parameters so that variables may be passed through the function when it is called. Figure 1 shows a User Defined Table function setup which requires an argument of @KPI to be passed when called, this is then used to filter the select statement when results are returned. 

## Scalar, Inline, and Multi-Statement Functions
