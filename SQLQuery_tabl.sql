use Sportshop
go

--создание таблиц
create table Table_Products
(
	Id_Product int identity(1,1) primary key not null,
	Name_Product nvarchar(30) not null CHECK(Name_Product!=' '),
	Type_Product nvarchar(10) not null CHECK (Type_Product in('одежда', 'обувь', 'инвентарь', 'прочее')),
	Quantity int not null CHECK(Quantity>=0),
	Fabricator nvarchar(30) not null CHECK(Fabricator!=' '),
	Cost_price money not null CHECK(Cost_price>0),
	Retail_price money not null CHECK(Retail_price>0)
)
go

-- это не помогло, пришлось совсем удалить ограничение, чтобы шифровать столбец
ALTER TABLE Table_Products 
drop CONSTRAINT check(Cost_price> 0)
GO


create table Table_Archive
(
	Product_id int not null UNIQUE,
	Name_Product nvarchar(30),
	Type_Product nvarchar(10),
	Quantity int,
	Fabricator nvarchar(30),
	Cost_price money,
	Retail_price money
)
go

create table Table_Last_unit
(
	Product_id int not null UNIQUE,
	[Last] bit default(1)not null,
)
go

create table Table_Selling
(
	Id_Selling int identity(1,1) primary key not null,
	Product_id int not null, 
	Quantity int not null CHECK(Quantity>0),
	Price money, -- not null CHECK(Price >0),
	Date_Sale datetime not null CHECK (Date_Sale>='20000101'),
	Seller_id int,
	Customer_id int
)
go

alter table Table_Selling 
add constraint Product_id default ((0)) for Product_id
go

create table Table_History
(
	Selling_id int not null UNIQUE,
	Product_id int, 
	Quantity int,
	Price money,
	Date_Sale datetime,
	Seller_id int,
	Customer_id int
)
go

alter table Table_History
add Id_History int identity(1,1) primary key not null
go

create table Table_Employees
(
	Id_Employee int identity(1,1) primary key not null,
	Surname nvarchar(max) not null CHECK(Surname!=' '),
	[Name] nvarchar(max) not null CHECK([Name]!=' '),
	Patronymic nvarchar(max) not null CHECK(Patronymic!=' '),
	Gender nvarchar(10) not null CHECK(Gender in('м','ж')),
	EmploymentDate date not null CHECK (EmploymentDate>='19900101'),
	Position nvarchar(30) not null CHECK(Position in('продавец', 'кладовщик', 'товаровед', 'администратор')),
	Salary money not null CHECK(Salary>0),
	Premium money default(0) not null CHECK(Premium>=0)
)
go

create table Table_Clients
(
	Id_Client int identity(1,1) primary key not null,
	Surname nvarchar(max) not null CHECK(Surname!=' '),
	[Name] nvarchar(max) not null CHECK([Name]!=' '),
	Patronymic nvarchar(max) not null CHECK(Patronymic!=' '),
	Gender nvarchar(10) not null CHECK(Gender in('м','ж')),
	Email varchar(30) not null CHECK(Email!=' '),
	Telephone char(10),
	Subscription bit default(1)not null,
	Discount int default(0) not null CHECK(Discount>=0),
	History int default(0)
)
go

alter table Table_Clients
add BirthDate date CHECK(BirthDate>='19200101'),
 RegistrDate date CHECK(RegistrDate>='19900101')
go

--удаление таблиц
/*
drop table Table_Products 
drop table Table_Selling
drop table Table_Employees
drop table Table_Clients
go*/



-- ввод данных
insert into Table_Products(Name_Product,Type_Product,Quantity,Fabricator,Cost_price,Retail_price)
values
('мяч','инвентарь','3','РТИ','150','450'),
('лыжи','инвентарь','20','Salomon','1500','4000'),
('ботинки','обувь','20','Salomon','1700','4500'),
('ботинки','обувь','20','Salewa','2000','6400'),
('куртка','одежда','25','Adidas','4500','12600'),
('термобелье','одежда','25','Tramp','1800','5200')
go

insert into Table_Employees (Surname,[Name],Patronymic,Gender,EmploymentDate,Position,Salary)
values
('Иванов','Антон','Петрович','м','20140226','товаровед','20000'),
('Шевцов','Семен','Алексеевич','м','20200126','продавец','10000'),
('Петрова','Алена','Викторовна','ж','20190615','продавец','10000')
go

insert into Table_Clients (Surname,[Name],Patronymic,Gender,Email,Telephone,Subscription,Discount)
values
('Иванов','Антон','Петрович','м','iap@mail.ru','','',''),
('Семенова','Диана','Михайловна','ж','sdmp@mail.ru','','',''),
('Панова','Ольга','Ивановна','ж','poi@mail.ru','','','')
go
	
-- показ всей информации в таблицах
select * from Table_Products
go
select * from Table_Employees
go
select * from Table_Clients
go
select * from Table_Selling
go
select * from Table_History
go



	
--хранимые процедуры
--информация о всех товарах (дз2 задание 1.1)
create procedure all_products
as
select * from Table_Products
go
execute all_products;

--информация о товарах конкретного вида в наличии (дз2 задание 1.2)
create proc all_type_products
@Type_Product nvarchar(10)
as
select * from Table_Products
where Type_Product=@Type_Product and Quantity>0
go
execute all_type_products @Type_Product='инвентарь';

--проверка наличия товара определенного производителя (дз2 задание 1.5)
create proc exis_products_fabricator
@Fabricator_Product nvarchar(30),
@res bit output
as
declare @Quantity int
select @Quantity=Quantity from Table_Products where Fabricator=@Fabricator_Product 
if ( @Quantity>0) set @res=1
return @res
go
declare @exis bit
execute @exis=exis_products_fabricator @Fabricator_Product='ABC', @res=@exis
select @exis

--топ-3 старых клиентов по дате регистрации (дз2 задание 1.3)
create proc TOP3_old_client
as
select top 3 Surname,[Name],Patronymic,RegistrDate
from Table_Clients
order by RegistrDate
go
execute TOP3_old_client;

--удаление всех клиентов, зарегистрированных после указанной даты (дз2 задание 1.7)
create proc delete_client_registrdate
@registrdate date,
@res int output
as
SET NOCOUNT off ;
delete Table_Clients
where RegistrDate>@registrdate
select @res = @@ROWCOUNT
return @res
go
declare @exis int
execute @exis=delete_client_registrdate @registrdate='20210801',@res=@exis
select @exis

--информация о самом успешном продавце по общей сумме продаж за всё время (дз2 задание 1.4)
create proc best_seller_employee
as
select top 1 s.Seller_id as 'Seller_id',
	e.Surname+' '+e.[Name]+ ' '+e.Patronymic as 'Seller',
	SUM(s.Price*s.Quantity) as 'Sales_amount'
from Table_Employees e,Table_Selling s
group by s.Seller_id, e.Surname+' '+e.[Name]+ ' '+e.Patronymic
order by Sales_amount desc
go
execute best_seller_employee
select * from Table_Selling
go

--информация о самом популярном (по общей сумме продаж) производителе среди покупателей (дз2 задание 1.6)
create proc best_seller_fabricator
as
select top 1 p.fabricator as 'fabricator',
	SUM(s.Price*s.Quantity) as 'Sales_amount'
from Table_Products p,Table_Selling s
where p.Id_Product=s.Product_id
group by p.fabricator
order by Sales_amount desc
go
execute best_seller_fabricator
select * from Table_Selling
select * from Table_Products
go



--drop proc best_seller_fabricator
--go


