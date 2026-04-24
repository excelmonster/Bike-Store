create database BikeStore
use BikeStore

-- Tables

-- 1
create table Products (
product_id int primary key,
product_name varchar(100),
brand_id int,
category_id int,
model_year varchar(10),
list_price decimal(10,2))

bulk insert Products from 'C:\Users\Sarvar\Desktop\Data analytics\SQL\Projects\2 Bike store\products.csv'
with (format = 'csv', fieldterminator = ',', rowterminator = '\n', firstrow = 2)

select * from Products


-- 2
create table Orders (
order_id int primary key,
customer_id int,
order_status varchar(50),
order_date date,
required_date date,
shipped_date date null,
store_id int,
staff_id int)

bulk insert Orders from 'C:\Users\Sarvar\Desktop\Data analytics\SQL\Projects\2 Bike store\orders.csv'
with (format = 'csv', fieldterminator = ',', rowterminator = '\n', firstrow = 2)

select * from Orders


-- 3
create table Order_items (
order_id int,
item_id int,
product_id int,
quantity int,
list_price decimal(10,2),
discount decimal(10,2))

bulk insert Order_items from 'C:\Users\Sarvar\Desktop\Data analytics\SQL\Projects\2 Bike store\order_items.csv'
with (format = 'csv', fieldterminator = ',', rowterminator = '\n', firstrow = 2)

select * from Order_items


-- 4
create table Stores (
store_id int primary key,
store_name varchar(100),
phone varchar(50),
email varchar(100),
street varchar(100),
city varchar(100),
state varchar(100),
zip_code int)

bulk insert Stores from 'C:\Users\Sarvar\Desktop\Data analytics\SQL\Projects\2 Bike store\stores.csv'
with (format = 'csv', fieldterminator = ',', rowterminator = '\n', firstrow = 2)

select * from Stores


-- 5
create table Stocks (
store_id int,
product_id int,
quantity int)

bulk insert Stocks from 'C:\Users\Sarvar\Desktop\Data analytics\SQL\Projects\2 Bike store\stocks.csv'
with (format = 'csv', fieldterminator = ',', rowterminator = '\n', firstrow = 2)

select * from Stocks


-- 6
create table Staffs (
staff_id int primary key,
first_name varchar(50),
last_name varchar(50),
email varchar(100),
phone varchar(50),
active varchar(50),
store_id int,
manager_id int)

insert into Staffs values (1,'Fabiola','Jackson','fabiola.jackson@bikes.shop','(831) 555-5554',1,1,NULL)

bulk insert Staffs from 'C:\Users\Sarvar\Desktop\Data analytics\SQL\Projects\2 Bike store\staffs.csv'
with (format = 'csv', fieldterminator = ',', rowterminator = '\n', firstrow = 2)

select * from Staffs


-- 7
create table Customers (
customer_id int primary key,
first_name varchar(50),
last_name varchar(50),
phone varchar(50),
email varchar(100),
street varchar(50),
city varchar(50),
state varchar(50),
zip_code int)

bulk insert Customers from 'C:\Users\Sarvar\Desktop\Data analytics\SQL\Projects\2 Bike store\customers.csv'
with (format = 'csv', fieldterminator = ',', rowterminator = '\n', firstrow = 2)

select * from Customers


-- 8
create table Brands (
brand_id int primary key,
brand_name varchar(50))

bulk insert Brands from 'C:\Users\Sarvar\Desktop\Data analytics\SQL\Projects\2 Bike store\brands.csv'
with (format = 'csv', fieldterminator = ',', rowterminator = '\n', firstrow = 2)

select * from Brands

-- 9
create table Categories (
category_id int primary key,
category_name varchar(50))

bulk insert Categories from 'C:\Users\Sarvar\Desktop\Data analytics\SQL\Projects\2 Bike store\categories.csv'
with (format = 'csv', fieldterminator = ',', rowterminator = '\n', firstrow = 2)

select * from Categories


-- Foreign keys

alter table Stocks
add constraint fk_stocks
foreign key (product_id) references Products(product_id)

alter table Products
add constraint fk_products
foreign key (category_id) references Categories(category_id)

alter table Products
add constraint fk_products1
foreign key (brand_id) references Brands(brand_id)

alter table Products
add constraint fk_products1
foreign key (brand_id) references Brands(brand_id)

alter table Order_items
add constraint fk_order_items
foreign key (product_id) references Products(product_id)

alter table Orders
add constraint fk_orders
foreign key (customer_id) references Customers(customer_id)

alter table Orders
add constraint fk_orders1
foreign key (staff_id) references Staffs(staff_id)

alter table Orders
add constraint fk_orders2
foreign key (store_id) references Stores(store_id)

alter table Order_items
add constraint fk_order_items2
foreign key (order_id) references Orders(order_id)

alter table Staffs
add constraint fk_staffs
foreign key (store_id) references Stores(store_id)

alter table Staffs
add constraint fk_staffs1
foreign key (manager_id) references Staffs(staff_id)

alter table Stocks
add constraint fk_stocks1
foreign key (store_id) references Stores(store_id)


-- Views

-- 1
select * from Orders
select * from Order_items
select * from Stores

;create view vw_StoreSalesSummary as
select s.store_name, count(distinct o.order_id) as total_orders,
sum(oi.quantity * oi.list_price * (1 - oi.discount)) as total_revenue,
avg(oi.quantity * oi.list_price * (1 - oi.discount)) as avg_order from Stores s
join Orders o on s.store_id = o.store_id
join Order_items oi on o.order_id = oi.order_id
group by s.store_name

select * from vw_StoreSalesSummary

-- 2
select * from Products
select * from Order_items

;create view vw_TopSellingProducts as
select p.product_name, sum(oi.quantity * oi.list_price * (1 - oi.discount)) as total_revenue,
rank() over (order by sum(oi.quantity * oi.list_price * (1 - oi.discount)) desc) as product_rank from Products p
join Order_items oi on p.product_id = oi.product_id
group by p.product_name

select * from vw_TopSellingProducts

-- 3
select * from Stocks
select * from Products
select * from Brands

create view vw_InventoryStatus as
select p.product_name, b.brand_name, sum(s.quantity) as total_quantity,
case when sum(s.quantity) = 0 then 'Out of Stock'
when sum(s.quantity) < 10 then 'Low Stock'
else 'In Stock'
end as inventory_level from Products p
join Stocks s on p.product_id = s.product_id
join Brands b on p.brand_id = b.brand_id
group by p.product_name, b.brand_name

select * from vw_InventoryStatus


-- 4
select * from Staffs
select * from Order_items
select * from Orders

;create view vw_StaffPerformance as
select st.first_name + ' ' + st.last_name as staff_full_name,
count(distinct o.order_id) as total_orders,
sum(oi.quantity * oi.list_price * (1 - oi.discount)) as total_revenue from Staffs st
left join Orders o on st.staff_id = o.staff_id
left join Order_items oi on o.order_id = oi.order_id
group by st.staff_id, st.first_name, st.last_name

select * from vw_StaffPerformance

-- 5
select * from Customers
select * from Orders
select * from Order_items

;create view vw_RegionalTrends as
select c.city, sum(oi.quantity * oi.list_price * (1 - oi.discount)) as total_revenue from Customers c
join Orders o on c.customer_id = o.customer_id
join Order_items oi on o.order_id = oi.order_id
group by c.city

select * from vw_RegionalTrends


-- 6
select * from Products
select * from Categories
select * from Order_items

;create view vw_SalesByCategory as
select c.category_name, count(distinct oi.order_id) as total_orders,
sum(oi.quantity * oi.list_price * (1 - oi.discount)) as total_revenue from Categories c
join Products p on c.category_id = p.category_id
join Order_items oi on p.product_id = oi.product_id
group by c.category_name

select * from vw_SalesByCategory


-- Stored procedures

-- 1
select * from Stores
select * from Order_items
select * from Orders

create procedure sp_CalculateStoreKPI
@Store_id int
as begin
select s.store_name, sum(oi.quantity * oi.list_price * (1 - oi.discount)) as total_revenue,
count(distinct o.order_id) as total_orders,
sum(oi.quantity * oi.list_price * (1 - oi.discount)) / count(distinct o.order_id) as avg_order_value
from Stores s
join Orders o on s.store_id = o.store_id
join Order_items oi on o.order_id = oi.order_id
where s.store_id = @Store_id
group by s.store_name
end

exec sp_CalculateStoreKPI @Store_id = 2


-- 2
select * from Stores
select * from Products
select * from Stocks

create procedure sp_GenerateRestockList
@StockLevel int
as begin
select st.store_name, p.product_name, s.quantity as current_stock from Stocks s
join Products p on s.product_id = p.product_id
join Stores st on s.store_id = st.store_id
where s.quantity < @StockLevel
order by st.store_name, s.quantity asc
end

exec sp_GenerateRestockList @StockLevel = 5


-- 3
select * from Order_items
select * from Orders

create procedure sp_CompareSalesYearOverYear
@Year1 int,
@Year2 int
as begin
select year(o.order_date) as sale_year,
cast(sum(oi.quantity * oi.list_price * (1 - oi.discount)) as decimal(10,2)) as yearly_revenue
from Orders o
join Order_items oi on o.order_id = oi.order_id
where year(o.order_date) in (@Year1, @Year2)
group by year(o.order_date)
order by sale_year
end

exec sp_CompareSalesYearOverYear @Year1 = 2017, @Year2 = 2018


-- 4
select * from Orders
select * from Order_items
select * from Products

create procedure sp_GetCustomerProfile
@CustomerId int
as begin
select c.first_name + ' ' + c.last_name as customer_name,
count(distinct o.order_id) as total_orders,
cast(sum(oi.quantity * oi.list_price * (1 - oi.discount)) as decimal(10,2)) as total_spent,
(select TOP 1 p.product_name from Order_items oi2
join Products p on oi2.product_id = p.product_id
join Orders o2 on oi2.order_id = o2.order_id
where o2.customer_id = @CustomerId
group by p.product_name
order by sum(oi2.quantity) desc) as MostBoughtItem
from Customers c
join Orders o on c.customer_id = o.customer_id
join Order_items oi on o.order_id = oi.order_id
where c.customer_id = @CustomerId
group by c.first_name, c.last_name
end

exec sp_GetCustomerProfile @CustomerId = 1


-- KPIs

-- 1
select * from Order_items

select cast(sum(quantity * list_price * (1- discount)) as decimal(10,2)) as revenue
from Order_items


-- 2
select * from Order_items

select cast(sum(quantity * list_price * (1- discount)) as decimal(10,2)) / count(distinct order_id) as AOV
from Order_items


-- 3
select * from Order_items
select * from Stocks

select cast((select sum(quantity) from Order_items) * 1.0 /
(select sum(quantity) from Stocks) as decimal(10,2)) as kpi


-- 4
select * from Stores
select * from Orders
select * from Order_items

select s.store_name,
cast(sum(oi.quantity * oi.list_price * (1 - oi.discount)) as decimal(10,2)) as total_revenue,
count(distinct o.order_id) as total_orders from Stores s
join Orders o on s.store_id = o.store_id
join Order_items oi on o.order_id = oi.order_id
group by s.store_name
order by total_revenue desc


-- 5
select * from Categories
select * from Order_items
select * from Products

select c.category_name,
cast(sum(oi.quantity * oi.list_price * (1 - oi.discount)) as decimal(10,2)) as gross_revenue,
count(distinct oi.order_id) as sales_count from Categories c
join Products p on c.category_id = p.category_id
join Order_items oi on p.product_id = oi.product_id
group by c.category_name
order by Gross_Revenue desc

-- 6
select * from Brands
select * from Order_items
select * from Products

select b.brand_name,
cast(sum(oi.quantity * oi.list_price * (1 - oi.discount)) as decimal(10,2)) as revenue,
count(distinct oi.order_id) as sales_count from Brands b
join Products p on b.brand_id = p.brand_id
join Order_items oi on p.product_id = oi.product_id
group by b.brand_name
order by revenue desc


-- 7
select * from Staffs
select * from Orders
select * from Order_items

select s.first_name + ' ' + s.last_name as full_name,
count(distinct o.order_id) as orders,
cast(sum(oi.quantity * oi.list_price * (1 - oi.discount)) as decimal(18,2)) as total_revenue
from Staffs s
join Orders o on s.staff_id = o.staff_id
join Order_items as oi on o.order_id = oi.order_id
group  by s.first_name, s.last_name
order by total_revenue desc