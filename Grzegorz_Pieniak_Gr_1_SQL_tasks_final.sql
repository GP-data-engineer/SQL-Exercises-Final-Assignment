--Task 1
--Select products sold in boxes, where the stock quantity is between 20 and 35,
--and the product category ID is 2 or 3, ordered from the most expensive.
--Display product names and all details related to the given conditions.
-----
select * from Products --displays everything from Products 
where (QuantityPerUnit like '%box%') and (UnitsInStock between 20 and 35) and (CategoryID in ('2', '3'))
order by UnitPrice desc
-----
select ProductName, CategoryID, UnitsInStock, QuantityPerUnit from Products --displays only 3 columns from Products 
where (QuantityPerUnit like '%box%') and (UnitsInStock between 20 and 35) and (CategoryID in ('2', '3'))
order by UnitPrice desc
-----conclusion: only 3 products meet the above criteria.

--Task 2
--Select orders where the delivery country is France or Germany, the city name starts with B, K, or P,
--the order has been shipped, ordered by order date.
--Display order numbers and all details related to the given conditions.
-----
select orderid, shipcountry, shipcity, orderdate, shippeddate from Orders
where (ShipCountry in ('Germany', 'France')) and (shipcity like 'B%' or shipcity like 'K%' or shipcity like 'P%') 
and (ShippedDate is not null)
order by OrderDate asc
--- conclusion: 34 orders meet the above criteria.

-----
--Task 3
--Provide customers who placed orders within the first 5 days of each month.
-----
select CustomerID --, OrderDate 
from orders where (day(OrderDate) between 1 and 5) 
 group by CustomerID
order by CustomerID
-----conclusion: 63 customers placed orders within the first 5 days of each month.
-- after struggling for a long time, I used ChatGPT. A simple task, but I was stuck with DATEADD which turned out unnecessary.

--Task 4
--What is the average delivery time (in days) from order to shipment for each employee?
--Display two columns: employee ID, average delivery time.
--The average should be shown as a fractional number.
-----
select EmployeeID, avg(cast(ShippeDdate - OrderDate as float)) as 'œrednia_czas_dostawy' from orders 
where ShippedDate is not null group by EmployeeID order by œrednia_czas_dostawy asc
----- conclusion: 9 employees have average delivery times between 7 and 10 days, employee no. 5 is the best.

--Task 5
--What is the number of employees born in each year?
--Display two columns: year of birth, number of employees.
-----
select year(BirthDate) as 'rok urodzenia', count(*) as 'liczba_pracownikow' 
from Employees 
group by year(BirthDate)
----- conclusion: there are 9 employees, 2 of them born in 1963.

--Task 6
--Show employees who processed more than 5 orders in Q3 1996.
--Display employee ID and number of orders.
----
select Employeeid, count(OrderID) as 'Liczba_Zamowien' from Orders --without count() it won’t work
where (year(OrderDate) = 1996) and (month(OrderDate) between 07 and 09) --question: is this correct? could it be shorter using Dateadd()?
group by Employeeid
having count(OrderID) > 5 
order by Employeeid
---- conclusion: employees 5 and 9 must have less than 5 orders in the given period.

--Task 7
--How many orders did each shipper complete and what was the total freight cost in 1997?
--Display three columns: shipper ID (ShipVia), number of orders, freight cost.
----
select ShipVia as 'identyfikator przewoŸnika', count(OrderID) as 'liczba zamówieñ', sum(Freight) as 'koszt_przewozu' from Orders
where year(ShippedDate) = 1997
group by ShipVia
order by ShipVia
---- conclusion: 3 shippers completed orders in the following numbers: 1 - 130, 2 - 143, 3 - 125.

--Task 8
--Provide customers (by name) who in 1997 placed at least 3 orders for products in jars.
--Column order: CUSTOMER_NAME, ORDERS_COUNT
--- solution with join ----------
select o.CustomerID as 'NAZWA_KLIENTA', count(o.OrderID) as 'LICZBA_ZAM' from Orders o 
JOIN [Order Details] od on od.OrderID = o.OrderID 
JOIN Products p on od.ProductId = p.ProductId 
where year(o.OrderDate) = 1997 and p.QuantityPerUnit like '%jar%'
group by o.CustomerID
having count(o.OrderID) >= 3
	--- conclusion: 6 customers in 1997 placed at least 3 jar orders.
	-----------------------------
-----solution without join-------
select O.CustomerID as 'NAZWA_KLIENTA', Count(O.OrderID) as 'LICZBA_ZAM'
from Orders O where year(O.OrderDate) = 1997 and
O.OrderID in
	(select OD.OrderID from [Order Details] OD where OD.ProductId in
		(select P.ProductId from Products P where P.QuantityPerUnit like '%jar%'))
group by o.CustomerID
having count(o.OrderID) >= 3
--- conclusion: 6 customers in 1997 placed at least 3 jar orders.
--- there is a slight difference: the non-join version misses one order, unclear why.

--Task 9
--Find all customers from Germany whose total order value is greater than 5000.
--Sort alphabetically by customer.
--Display columns: CUSTOMER_NAME, ORDER_VALUE
----- 
select cus.CustomerID as 'NAZWA_KLIENTA', sum(od.UnitPrice * od.Quantity) as 'WARTOŒÆ_ZAM' , cus.Country
from [Order Details] od join Orders ord on od.OrderID = ord.OrderID join Customers cus on ord.CustomerID = cus.CustomerID
where cus.Country = 'Germany'
group by cus.CustomerID, cus.Country
having sum(od.UnitPrice * od.Quantity) > 5000 
order by 'WARTOŒÆ_ZAM' desc
---- conclusion: only 7 German customers have orders > 5000.

--Task 10
--List employees and the number of orders delivered on time in 1997-1998.
--Display columns in order: FIRSTNAME, LASTNAME, ORDERS_COUNT.
-----------
select emp.FirstName, emp.LastName, count(ord.OrderID) as 'LICZBA_ZAM', year(ord.ShippedDate) as 'Rok' from Orders ord 
join Employees emp on ord.EmployeeID=emp.EmployeeID
where year(ord.ShippedDate) between 1997 and 1998
group by emp.FirstName, emp.LastName,  year(ord.ShippedDate)
order by count(ord.OrderID) desc
------ conclusion: 18 employees delivered orders in 1997-1998.

--Task 11   
--Find customers who never placed an order by checking IDs in the orders table. 
--Check:
select CustomerID from Customers
select CustomerID from Orders group by CustomerID
--Based on the difference (Customers=91, Orders=89), 2 customers placed no orders.
select  cus.CustomerID as 'Customers.CustomerID', cus.CompanyName as 'Customers.CompanyName', ord.CustomerID as 'Orders.CustomerID'
from Orders ord right join Customers cus on ord.CustomerID = cus.CustomerID 
where ord.OrderID IS NULL
-- conclusion: right join shows the difference with NULLs. 2 customers (Fissa, Paris) have no orders.

---- alternative solution:
SELECT customerid, companyName FROM  customers
WHERE not EXISTS(SELECT orderid FROM  orders WHERE orders.customerid = customers.customerid)
----


--Task 12
--Display information about products where the discount is:
--Condiments = 5%,
--Seafood = 8%,
--Produce = 15%,
--Other categories = 4%

select * from Products

select cat.CategoryID, pro.ProductName, cat.CategoryName, case
when cat.CategoryID = 2 then pro.UnitPrice * 0.05
when cat.CategoryID = 8 then pro.UnitPrice * 0.08
when cat.CategoryID = 7 then pro.UnitPrice * 0.15
else pro.UnitPrice * 0.04
end AS 'Discount_Value'
from Categories cat
join Products pro on cat.CategoryID = pro.CategoryID
join [Order Details] od on pro.ProductID = od.ProductID
GROUP BY  cat.CategoryID, pro.ProductName, cat.CategoryName, pro.UnitPrice
ORDER BY cat.CategoryName
-- conclusion: done 100% independently!!

--Display columns in the order:
--category,
--product name,
--price before discount (UnitPrice),
--discount in percentage (4, 5, 8, or 15%),
--price after discount (calculated).

select  cat.CategoryID, pro.ProductName, pro.UnitPrice, case
when cat.CategoryID = 2 then '5%'
when cat.CategoryID = 8 then '8%'
when cat.CategoryID = 7 then '15%'
else '4%'
end AS 'Discount_%',
case
when cat.CategoryID = 2 then pro.UnitPrice - (pro.UnitPrice * 0.05)
when cat.CategoryID = 8 then pro.UnitPrice - (pro.UnitPrice * 0.08)
when cat.CategoryID = 7 then pro.UnitPrice - (pro.UnitPrice * 0.15)
else pro.UnitPrice - (pro.UnitPrice * 0.04)
end AS 'Price_After_Discount'
from Categories cat 
join Products pro on cat.CategoryID = pro.CategoryID
join [Order Details] od on pro.ProductID = od.ProductID
GROUP BY  cat.CategoryID, pro.ProductName, pro.UnitPrice
ORDER BY pro.ProductName


--Task 13
--Display (by name) non-discontinued products where the maximum sale price is at least $40,
--and discontinued products where the maximum sale price is greater than $25.
--Sort by discontinued info and price in descending order.
--Display 3 columns: product name, discontinued info, maximum price.

select pro.ProductName as 'Product_Name', pro.Discontinued as 'Discontinued_Info', max(ode.UnitPrice) as 'Max_Price'
from Products pro
JOIN [Order Details] ode on pro.ProductID = ode.ProductID
where (pro.Discontinued = 1 and ode.UnitPrice >= 25) or (pro.Discontinued = 0 and ode.UnitPrice >= 40)
group by pro.Discontinued, pro.ProductName
order by 'Discontinued_Info' desc, 'Max_Price' desc
-- conclusion: total 15 products, 5 discontinued and 10 available.


--Task 14
--List products (by name) that were not sold in summer (June–August).
select pro.ProductName from Products pro join [Order Details] ode on ode.ProductID = pro.ProductID join Orders ord on ord.OrderID = ode.OrderID 
where month(ord.ShippedDate) between 06 and 08
group by pro.ProductName
-- conclusion: 72 products were sold from June to August.


--Task 15
--Display employees who were hired after Steven Buchanan.
select FirstName, LastName, HireDate from Employees
where (select HireDate from Employees where LastName = 'Buchanan') < HireDate
-- conclusion1: three employees were hired later than Buchanan.
-- conclusion2: Nested query within the same table took some effort, no direct example existed.


--Task 16
--List customers who placed new orders after receiving a delayed delivery. 

SELECT DISTINCT o1.CustomerID
FROM Orders o1
JOIN Orders o2 
    ON o1.CustomerID = o2.CustomerID
    AND o1.OrderDate > o2.ShippedDate

---======
SELECT DISTINCT ord1.CustomerID
FROM Orders ord1
WHERE EXISTS (SELECT * FROM Orders ord2
				WHERE ord2.CustomerID = ord1.CustomerID
				AND ord2.OrderDate > ord1.OrderDate AND ord2.ShippedDate > ord2.RequiredDate)
AND ord1.ShippedDate > ord1.RequiredDate
--- conclusion: two queries compare the same table in different ways:
--- one finds late deliveries, the other matches order dates against delays.


--Task 17
--How many and what type of orders did each customer place?
--Create a view.
--Order types: small (<500), medium (<1000), large (>=1000).
--Display customer name, order type, number of orders.
--Finally, drop the view.

alter view widok_zamowien  
as
select cus.CompanyName, pro.ProductName ,  
case
when sum(ode.UnitPrice*ode.Quantity) <= 500 then 'small order value'
when sum(ode.UnitPrice*ode.Quantity) <= 1000 then 'medium order value'
else 'large order value'
end as Order_Type,
count(*) as Orders_Count
from Orders ord 
join Customers cus on cus.CustomerID = ord.CustomerID 
join [Order Details] ode on ode.OrderID = ord.OrderID 
join Products pro on pro.ProductID = ode.ProductID 
group by cus.CompanyName , pro.ProductName 

select * from widok_zamowien

drop view widok_zamowien

--Alternative version 
alter view Zamowienia_klientow as
select
    c.CompanyName, pro.ProductName,
    case
        when SUM(od.UnitPrice * od.Quantity) <= 500 then 'small order value'
        when SUM(od.UnitPrice * od.Quantity) > 500 AND SUM(od.UnitPrice * od.Quantity) <= 1000 then 'medium order value'
        else 'large order value'
    end as Order_Type, count(ord.OrderID) as Orders_Count
from 
    Customers c
join Orders ord on c.CustomerID = ord.CustomerID
join [Order Details] od on ord.OrderID = od.OrderID
join Products pro on od.ProductID = pro.ProductID
GROUP BY c.CompanyName, pro.ProductName

select * from Zamowienia_klientow

drop view Zamowienia_klientow
-- conclusion: both versions work identically.
