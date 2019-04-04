/*   Project Number 2 - Thursday Class - Script written by Bryan Streber */
USE master
GO

PRINT 'Dropping Cus_orders database...'
GO

IF EXISTS (
		SELECT *
		FROM sysdatabases
		WHERE name = 'Cus_Orders'
		)
BEGIN
	DROP DATABASE Cus_Orders
END
GO

PRINT 'Creating Cus_orders database...'

CREATE DATABASE Cus_Orders
GO

USE Cus_orders
GO

/*Part A 
Create user types */
PRINT 'Creating user defined values...'
GO

CREATE TYPE csid
FROM CHAR(10) NOT NULL;

CREATE TYPE osid
FROM INT NOT NULL;

CREATE TYPE psid
FROM INT NOT NULL;

CREATE TYPE ssid
FROM INT NOT NULL;
GO

/* Creating tables */
PRINT 'Creating tables...'
GO

CREATE TABLE customers (
	customer_id csid
	,name VARCHAR(50) NOT NULL
	,contact_name VARCHAR(30)
	,title_id CHAR(3) NOT NULL
	,address VARCHAR(50)
	,city VARCHAR(20)
	,region VARCHAR(15)
	,country_code VARCHAR(10)
	,country VARCHAR(15)
	,phone VARCHAR(20)
	,fax VARCHAR(20)
	);

CREATE TABLE orders (
	order_id osid
	,customer_id csid
	,employee_id INT NOT NULL
	,shipping_name VARCHAR(50)
	,shipping_address VARCHAR(50)
	,shipping_city VARCHAR(20)
	,shipping_region VARCHAR(15)
	,shipping_country_code VARCHAR(10)
	,shipping_country VARCHAR(15)
	,shipper_id INT NOT NULL
	,order_date DATETIME
	,required_date DATETIME
	,shipped_date DATETIME
	,freight_charge MONEY
	);

CREATE TABLE order_details (
	order_id osid
	,product_id psid
	,quantity INT NOT NULL
	,discount FLOAT NOT NULL
	);

CREATE TABLE products (
	product_id psid
	,supplier_id ssid
	,name VARCHAR(40)
	,alernate_name VARCHAR(40)
	,quantity_per_unit VARCHAR(25)
	,unit_price MONEY
	,quantity_in_stock INT
	,units_on_order INT
	,reorder_level INT
	);

CREATE TABLE shippers (
	shipper_id INT IDENTITY(1, 1) NOT NULL
	,name VARCHAR(20) NOT NULL
	);

CREATE TABLE suppliers (
	supplier_id ssid
	,name VARCHAR(40) NOT NULL
	,address VARCHAR(30)
	,city VARCHAR(20)
	,province CHAR(2)
	);

CREATE TABLE titles (
	title_id CHAR(3) NOT NULL
	,description VARCHAR(35) NOT NULL
	);
GO

/* Pks, FKs and other constraints using ALTER here */
PRINT 'Adding Primary Keys...'
GO

ALTER TABLE customers ADD PRIMARY KEY (customer_id);

ALTER TABLE titles ADD PRIMARY KEY (title_id);

ALTER TABLE shippers ADD PRIMARY KEY (shipper_id);

ALTER TABLE orders ADD PRIMARY KEY (order_id);

ALTER TABLE order_details ADD PRIMARY KEY (
	order_id
	,product_id
	);

ALTER TABLE suppliers ADD PRIMARY KEY (supplier_id);

ALTER TABLE products ADD PRIMARY KEY (product_id);
GO

PRINT 'Adding Foreign keys...'
GO

ALTER TABLE customers ADD CONSTRAINT FK_title_id FOREIGN KEY (title_id) REFERENCES titles (title_id);
GO

ALTER TABLE orders ADD CONSTRAINT FK_customer_id FOREIGN KEY (customer_id) REFERENCES customers (customer_id);
GO

ALTER TABLE orders ADD CONSTRAINT FK_shipper_id FOREIGN KEY (shipper_id) REFERENCES shippers (shipper_id);
GO

ALTER TABLE order_details ADD CONSTRAINT FK_order_id FOREIGN KEY (order_id) REFERENCES orders (order_id);
GO

ALTER TABLE order_details ADD CONSTRAINT FK_product_id FOREIGN KEY (product_id) REFERENCES products (product_id);
GO

ALTER TABLE products ADD CONSTRAINT FK_supplier_id FOREIGN KEY (supplier_id) REFERENCES suppliers (supplier_id);
GO

PRINT 'Altering tables...'
GO

ALTER TABLE customers ADD CONSTRAINT df_customers_country DEFAULT 'Canada'
FOR country;
GO

ALTER TABLE orders ADD CONSTRAINT df_orders_required_date DEFAULT GETDATE () + (10)
FOR required_date;
GO

ALTER TABLE order_details ADD CONSTRAINT df_order_datails_quantity CHECK (quantity >= 1);
GO

ALTER TABLE products ADD CONSTRAINT df_products_reorder_level CHECK (reorder_level >= 1);
GO

ALTER TABLE products ADD CONSTRAINT df_products_quantity_in_stock CHECK (quantity_in_stock >= 150);
GO

ALTER TABLE suppliers ADD CONSTRAINT df_suppliers_province DEFAULT 'BC'
FOR province;
GO

/* Statements from supplied scripts*/
PRINT 'Importing data....'
GO

BULK INSERT titles
FROM 'C:\TextFiles\titles.txt' WITH (
		CODEPAGE = 1252
		,DATAFILETYPE = 'char'
		,FIELDTERMINATOR = '\t'
		,KEEPNULLS
		,ROWTERMINATOR = '\n'
		)
GO

BULK INSERT suppliers
FROM 'C:\TextFiles\suppliers.txt' WITH (
		CODEPAGE = 1252
		,DATAFILETYPE = 'char'
		,FIELDTERMINATOR = '\t'
		,KEEPNULLS
		,ROWTERMINATOR = '\n'
		)
GO

BULK INSERT shippers
FROM 'C:\TextFiles\shippers.txt' WITH (
		CODEPAGE = 1252
		,DATAFILETYPE = 'char'
		,FIELDTERMINATOR = '\t'
		,KEEPNULLS
		,ROWTERMINATOR = '\n'
		)
GO

BULK INSERT customers
FROM 'C:\TextFiles\customers.txt' WITH (
		CODEPAGE = 1252
		,DATAFILETYPE = 'char'
		,FIELDTERMINATOR = '\t'
		,KEEPNULLS
		,ROWTERMINATOR = '\n'
		)
GO

BULK INSERT products
FROM 'C:\TextFiles\products.txt' WITH (
		CODEPAGE = 1252
		,DATAFILETYPE = 'char'
		,FIELDTERMINATOR = '\t'
		,KEEPNULLS
		,ROWTERMINATOR = '\n'
		)
GO

BULK INSERT order_details
FROM 'C:\TextFiles\order_details.txt' WITH (
		CODEPAGE = 1252
		,DATAFILETYPE = 'char'
		,FIELDTERMINATOR = '\t'
		,KEEPNULLS
		,ROWTERMINATOR = '\n'
		)
GO

BULK INSERT orders
FROM 'C:\TextFiles\orders.txt' WITH (
		CODEPAGE = 1252
		,DATAFILETYPE = 'char'
		,FIELDTERMINATOR = '\t'
		,KEEPNULLS
		,ROWTERMINATOR = '\n'
		)
GO

/* Part B queries 
1. List the customer id, name, city, and country from the customer table. 
          Order the result set by the customer id. */
PRINT 'Part B - Queries'
GO

SELECT [Customer ID] = customers.customer_id
	,[Name] = customers.name
	,[City] = customers.city
	,[Country] = customers.country
FROM customers
ORDER BY customers.customer_id;
GO

/* 2. Add a new column called active to the customers table using the ALTER statement.  The only valid values are 1 or 0.  The default should be 1 */
ALTER TABLE customers ADD active INT DEFAULT(1) CONSTRAINT df_customers_active CHECK (
	active = 1
	OR active = 0
	);
GO

/* 3.	List all the orders where the order date is sometime in January or February 2004.  Display the order id, order date, and a new shipped date calculated by adding 7 days to the shipped date from the orders table, the product name from the product table, the customer name from the customer table, and the cost of the order.  Format the date order date and the shipped date as MON DD YYYY.  Use the formula (quantity * unit_price) to calculate the cost of the order.  The query should produce the result set listed below. */
SELECT [Order ID] = orders.order_id
	,[Product Name] = products.name
	,[Customer Name] = customers.name
	,[Order Date] = CONVERT(VARCHAR(13), orders.order_date, 107)
	,[New Shipped Date] = (convert(VARCHAR(13), dateadd(day, 7, shipped_date), 107))
	,[Order Cost] = order_details.quantity * products.unit_price
FROM customers
INNER JOIN orders ON orders.customer_id = customers.customer_id
INNER JOIN order_details ON orders.order_id = order_details.order_id
INNER JOIN products ON products.product_id = order_details.product_id
WHERE order_date BETWEEN 'Jan 01  2004'
		AND 'Feb 28 2004';
GO

/* 4.	List all the orders that have not been shipped.  Display the customer id, name and phone number from the customers table, and the order id and order date from the orders table.  Order the result set by the order date.  The query should produce the result set listed below. */
SELECT [Customer ID] = orders.customer_id
	,[Customer Name] = customers.name
	,[Customer Phone] = customers.phone
	,[Order Number] = orders.order_id
	,[Order Date] = CONVERT(VARCHAR(13), orders.order_date, 107)
FROM orders
INNER JOIN customers ON orders.customer_id = customers.customer_id
WHERE orders.shipped_date IS NULL;
GO

/* 5.	List all the customers where the region is NULL.  Display the customer id, name, and city from the customers table, and the title description from the titles table.   The query should produce the result set listed below.  */
SELECT [Customer ID] = customers.customer_id
	,[Customer Name] = customers.name
	,[City] = customers.city
	,[Description] = titles.description
FROM customers
INNER JOIN titles ON titles.title_id = customers.title_id
WHERE customers.region IS NULL;
GO

/* 6.	List the products where the reorder level is higher than the quantity in stock.  Display the supplier name from the suppliers table, the product name, reorder level, and quantity in stock from the products table.  Order the result set by the supplier name.  The query should produce the result set listed below.  */
SELECT [Supplier Name] = suppliers.name
	,[Product Name] = products.name
	,[Reorder level] = products.reorder_level
	,[Quanity in Stock] = products.quantity_in_stock
FROM products
INNER JOIN suppliers ON products.supplier_id = suppliers.supplier_id
WHERE products.reorder_level > quantity_in_stock
ORDER BY suppliers.name;
GO

/* 7.	Calculate the length in years from January 1, 2008 and when an order was shipped where the shipped date is not null.  Display the order id, and the shipped date from the orders table, the customer name, and the contact name from the customers table, and the length in years for each order.  Display the shipped date in the format MMM DD YYYY.  Order the result set by order id and the calculated years.  The query should produce the result set listed below. 
*/
SELECT DISTINCT [Order ID] = orders.order_id
	,[Customer Name] = customers.name
	,[Customer Contact] = customers.contact_name
	,[Shipping Date] = CONVERT(VARCHAR(13), orders.shipped_date, 107)
	,[Years Elapsed] = (DATEDIFF(yy, (CONVERT(VARCHAR(13), orders.shipped_date, 107)), 'January 1 2008'))
FROM orders
INNER JOIN customers ON customers.customer_id = orders.customer_id
WHERE orders.shipped_date IS NOT NULL;
GO

/* 8.	List number of customers with names beginning with each letter of the alphabet.  Ignore customers whose name begins with the letter F or G.  Do not display the letter and count unless at least six customerâ€™s names begin with the letter.  The query should produce the result set listed below.*/
SELECT [First letter of customers name] = substring(customers.name, 1, 1)
	,[Total count] = Count(substring(customers.name, 1, 1))
FROM customers
WHERE (substring(customers.name, 1, 1) != 'F')
	AND (substring(customers.name, 1, 1) != 'G')
GROUP BY substring(customers.name, 1, 1)
HAVING (Count(substring(customers.name, 1, 1)) >= 6);
GO

/* 9.	List the order details where the quantity is greater than 100.  Display the order id and quantity from the order_details table, the product id and reorder level from the products table, and the supplier id from the suppliers table.  Order the result set by the order id.  The query should produce the result set listed below.*/
SELECT [Order ID] = orders.order_id
	,[Quantity] = order_details.quantity
	,[Product ID] = order_details.product_id
	,[Reorder Level] = products.reorder_level
	,[Supplier ID] = products.supplier_id
FROM orders
INNER JOIN order_details ON order_details.order_id = orders.order_id
INNER JOIN products ON products.product_id = order_details.product_id
WHERE order_details.quantity > 100;
GO

/* 10.	List the products which contain tofu or chef in their name.  Display the product id, product name, quantity per unit and unit price from the products table.  Order the result set by product name.  The query should produce the result set listed below.*/
SELECT [Product ID] = products.product_id
	,[Product Name] = products.name
	,[Quantity Per unit] = products.quantity_per_unit
	,[Unit Price] = products.unit_price
FROM products
WHERE products.name LIKE '%tofu%'
	OR products.name LIKE '%chef%'
ORDER BY products.name;
GO

/* Part C queries
 1.	Create an employee table with the following columns: */
PRINT 'Part C queries'
GO

CREATE TABLE employee (
	employee_id INT NOT NULL
	,last_name VARCHAR(30) NOT NULL
	,first_name VARCHAR(15) NOT NULL
	,address VARCHAR(30)
	,city VARCHAR(20)
	,province CHAR(2)
	,postal_code VARCHAR(7)
	,phone VARCHAR(10)
	,birth_date DATETIME NOT NULL
	);
GO

/*  2.	The primary key for the employee table should be the employee id.   */
ALTER TABLE employee ADD PRIMARY KEY (employee_id);
GO

/*  3.	Load the data into the employee table using the employee.txt file; 9 rows.  In addition, create the relationship to enforce referential integrity between the employee and orders tables.     */
BULK INSERT employee
FROM 'C:\TextFiles\employee.txt' WITH (
		CODEPAGE = 1252
		,DATAFILETYPE = 'char'
		,FIELDTERMINATOR = '\t'
		,KEEPNULLS
		,ROWTERMINATOR = '\n'
		);

ALTER TABLE orders ADD CONSTRAINT FK_orders FOREIGN KEY (employee_id) REFERENCES employee (employee_id);
GO

/*4.	Using the INSERT statement, add the shipper Quick Express to the shippers table. */
INSERT INTO shippers (name)
VALUES ('Quick Express');
GO

/* 5.	Using the UPDATE statement, increate the unit price in the products table of all rows with a current unit price between $5.00 and $10.00 by 5%; 12 rows affected.*/
UPDATE products
SET unit_price = (unit_price * 1.05)
WHERE unit_price BETWEEN 5.00
		AND 10.00;
GO

/* 6.	Using the UPDATE statement, change the fax value to Unknown for all rows in the customers table where the current fax value is NULL; 22 rows affected.*/
UPDATE customers
SET fax = 'Unknown'
WHERE fax IS NULL;
GO

/* 7.	Create a view called vw_order_cost to list the cost of the orders.  Display the order id and order_date from the orders table, the product id from the products table, the customer name from the customers tble, and the order cost.  To calculate the cost of the orders, use the formula (order_details.quantity * products.unit_price).  Run the view for the order ids between 10000 and 10200.  The view should produce the result set listed below. */
CREATE VIEW vw_order_cost
AS
SELECT [Order ID] = orders.order_id
	,[Order Date] = orders.order_date
	,[Product ID] = products.product_id
	,[Name] = customers.name
	,[Order Cost] = order_details.quantity * products.unit_price
FROM orders
INNER JOIN order_details ON orders.order_id = order_details.order_id
INNER JOIN products ON products.product_id = order_details.product_id
INNER JOIN customers ON orders.customer_id = customers.customer_id;
GO

SELECT *
FROM vw_order_cost
WHERE [Order ID] BETWEEN 10000
		AND 10200;
GO

/* 8.	Create a view called vw_list_employees to list all the employees and all the columns in the employee table.  Run the view for employee ids 5, 7, and 9.  Display the employee id, last name, first name, and birth date.  Format the name as last name followed by a comma and a space followed by the first name.  Format the birth date as YYYY.MM.DD.  The view should produce the result set listed below. */
CREATE VIEW vw_list_employees
AS
SELECT [Employee ID] = employee_id
	,[Name] = (last_name + ', ' + first_name)
	,[Address] = employee.address
	,[City] = employee.city
	,[Province] = employee.province
	,[Postal Code] = employee.postal_code
	,[Phone] = employee.phone
	,[Birth Date] = CONVERT(VARCHAR(10), birth_date, 102)
FROM employee;
GO

SELECT *
FROM vw_list_employees
WHERE [Employee ID] IN (
		5
		,7
		,9
		);
GO

/* 9.	Create a view called vw_all_orders to list the columns shown below.  Display the order id and shipped date from the orders table, and the customer id, name, city, and country from the customers table.  Run the view for orders shipped from August 1, 2002 and September 30, 2002, formatting the shipped date as shown.  Order the result set by customer name and country.    The view should produce the result set listed below.*/
CREATE VIEW vw_all_orders
AS
SELECT [Order ID] = orders.order_id
	,[Customer ID] = customers.customer_id
	,[Customer Name] = customers.name
	,[City] = customers.city
	,[Country] = customers.country
	,[Shipped date] = orders.shipped_date
FROM customers
INNER JOIN orders ON customers.customer_id = orders.customer_id;
GO

SELECT [Order ID]
	,[Customer ID]
	,[Customer Name]
	,[City]
	,[Country]
	,[Shipped date] = CONVERT(VARCHAR(12), [Shipped date], 107)
FROM vw_all_orders
WHERE [Shipped Date] BETWEEN 'August 1, 2002'
		AND 'September 30, 2002'
ORDER BY [Customer Name]
	,[Country]
GO

/* 10.	Create a view listing the suppliers and the items they have shipped.  Display the supplier id and name from the suppliers table, and the product id and name from the products table.  Run the view.  The view should produce the result set listed below, although not necessarily in the same order. */
CREATE VIEW vw_suppliers_shipped
AS
SELECT [Supplier ID] = suppliers.supplier_id
	,[Supplier Name] = suppliers.name
	,[Product ID] = products.product_id
	,[Product Name] = products.name
FROM suppliers
INNER JOIN products ON suppliers.supplier_id = products.supplier_id
GO

SELECT *
FROM vw_suppliers_shipped;
GO

/* Part D 
1. Create a stored procedure called sp_customer_city displaying the customers living in a particular city.  The city will be an input parameter for the stored procedure.  Display the customer id, name, address, city and phone from the customers table.  Run the stored procedure displaying customers living in London.  The stored procedure should produce the result set listed below. */
PRINT 'Part D queries';
GO

CREATE PROCEDURE sp_customer_city @City NVARCHAR(20)
AS
SELECT [Customer ID] = customer_id
	,[Name] = Name
	,[Address] = Address
	,[City] = city
	,[Phone] = phone
FROM customers
WHERE city = @city;
GO

EXEC sp_customer_city 'London'
GO

/* 2.	Create a stored procedure called sp_orders_by_dates displaying the orders shipped between particular dates.  The start and end date will be input parameters for the stored procedure.  Display the order id, customer id, and shipped date from the orders table, the customer name from the customer table, and the shipper name from the shippers table.  Run the stored procedure displaying orders from January 1, 2003 to June 30, 2003.  The stored procedure should produce the result set listed below. */
CREATE PROCEDURE sp_orders_by_dates @startdate DATETIME
	,@enddate DATETIME
AS
SELECT [Order ID] = orders.order_id
	,[Customer ID] = orders.customer_id
	,[Customer Name] = customers.name
	,[Shipper Name] = shippers.name
	,[Shipped Date] = orders.shipped_date
FROM orders
INNER JOIN customers ON customers.customer_id = orders.customer_id
INNER JOIN shippers ON shippers.shipper_id = orders.shipper_id
WHERE orders.shipped_date BETWEEN @startdate
		AND @enddate;
GO

EXEC sp_orders_by_dates 'January 1, 2003'
	,'June 30, 2003';
GO

/* 3.	Create a stored procedure called sp_product_listing listing a specified product ordered during a specified month and year.  The product and the month and year will be input parameters for the stored procedure.  Display the product name, unit price, and quantity in stock from the products table, and the supplier name from the suppliers table.  Run the stored procedure displaying a product name containing Jack and the month of the order date is June and the year is 2001.  The stored procedure should produce the result set listed below. */
CREATE PROCEDURE sp_product_listing @product VARCHAR(40)
	,@month VARCHAR(10)
	,@year INT
AS
SELECT [Product Name] = products.name
	,[Unit Price] = products.unit_price
	,[Qunitiy in stock] = products.quantity_in_stock
	,[Supplier Name] = suppliers.name
FROM products
INNER JOIN suppliers ON suppliers.supplier_id = products.supplier_id
INNER JOIN order_details ON order_details.product_id = products.product_id
INNER JOIN orders ON orders.order_id = order_details.order_id
WHERE (DATENAME(month, orders.order_date)) = @month
	AND (YEAR(orders.order_date)) = @year
	AND products.name LIKE '%' + @product + '%';
GO

EXEC sp_product_listing 'Jack'
	,'June'
	,2001;
GO

/* 4.	Create a DELETE trigger on the order_details table to display the information shown below when you issue the following statement:*/
CREATE TRIGGER delete_on_order_details ON order_details
AFTER DELETE
AS
SELECT [Product ID] = deleted.product_id
	,[Product Name] = products.name
	,[Quantity being deleted from order] = deleted.quantity
	,[In stock after deletion] = deleted.quantity + products.quantity_in_stock
FROM deleted
INNER JOIN products ON products.product_id = deleted.product_id;
GO

/* 5.	Create an INSERT and UPDATE trigger called tr_check_qty on the order_details table to only allow orders of products that have a quantity in stock greater than or equal to the units ordered.  Run the following query to verify your trigger. */
CREATE TRIGGER tr_check_qty ON order_details
AFTER UPDATE
	,INSERT
AS
BEGIN
	SET NOCOUNT ON;

	IF EXISTS (
			SELECT order_details.quantity
			FROM order_details
			INNER JOIN products ON products.product_id = order_details.product_id
			INNER JOIN inserted ON inserted.product_id = products.product_id
			WHERE (inserted.quantity) >= products.quantity_in_Stock
			)
	BEGIN
		ROLLBACK TRANSACTION

		RAISERROR (
				'There are not enough items in inventory'
				,16
				,1
				)
	END
END;
GO

/*6.	Create a stored procedure called sp_del_inactive_cust to delete customers that have no orders.  The stored procedure should delete 1 row. */
CREATE PROCEDURE sp_del_inactive_cust
AS
BEGIN
	DELETE
	FROM customers
	WHERE customer_id NOT IN (
			SELECT orders.customer_id
			FROM orders
			)
END;
GO

/* 7.	Create a stored procedure called sp_employee_information to display the employee information for a particular employee.  The employee id will be an input parameter for the stored procedure.  Run the stored procedure displaying information for employee id of 7.  The stored procedure should produce the result set listed below.*/
CREATE PROCEDURE sp_employee_information @employee_number INT
AS
BEGIN
	SELECT [Last Name] = last_name
		,[First Name] = first_name
		,[Address] = address
		,[City] = city
		,[Provice] = province
		,[Postal Code] = postal_code
		,[Date of Birth] = CONVERT(VARCHAR(12), birth_date, 107)
	FROM employee
	WHERE employee_id = @employee_number
END;
GO

EXEC sp_employee_information 7;
GO

/* 8.	Create a stored procedure called sp_reorder_qty to show when the reorder level subtracted from the quantity in stock is less than a specified value.  The unit value will be an input parameter for the stored procedure.  Display the product id, quantity in stock, and reorder level from the products table, and the supplier name, address, city, and province from the suppliers table.  Run the stored procedure displaying the information for a value of 5.  The stored procedure should produce the result set listed below.  */
CREATE PROCEDURE sp_reorder_qty @new_order_level INT
AS
BEGIN
	SELECT [Product ID] = products.product_id
		,[Name] = products.name
		,[Address] = suppliers.address
		,[City] = suppliers.city
		,[Province] = suppliers.province
		,[Quantity] = products.quantity_in_stock
		,[Reorder Level] = products.reorder_level
	FROM products
	INNER JOIN suppliers ON suppliers.supplier_id = products.supplier_id
	WHERE ((products.quantity_in_stock) - (products.reorder_level) < @new_order_level)
END;
GO

/* 9.	Create a stored procedure called sp_unit_prices for the product table where the unit price is between particular values.  The two unit prices will be input parameters for the stored procedure.  Display the product id, product name, alternate name, and unit price from the products table.  Run the stored procedure to display products where the unit price is between $5.00 and $10.00.  The stored procedure should produce the result set listed below.    */
CREATE PROCEDURE sp_unit_prices @between_1 MONEY
	,@between_2 MONEY
AS
BEGIN
	SELECT [Product ID] = products.product_id
		,[Name] = products.name
		,[Alternate Name] = alernate_name
		,[Unit Price] = unit_price
	FROM products
	WHERE unit_price BETWEEN @between_1
			AND @between_2
END;
	/* End Script 
Have a great day! */
