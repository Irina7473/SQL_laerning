use Sportshop
go

--ТРИГГЕРЫ
--Запрет добавлять товар конкретной фирмы (задание 2.7)
create trigger [dbo].add_fabricator
on Table_Products
for insert, update
as
	select inserted.Fabricator from inserted
    if exists (select * from inserted where inserted.Fabricator = 'sport')
	begin
		raiserror('Вы не можете добавлять товар этого производителя',0,1)        
		rollback transaction    
	end
go
-- проверка
insert into Table_Products(Name_Product,Type_Product,Quantity,Fabricator,Cost_price,Retail_price)
values
('ракетка','инвентарь','30','sport','200','600')
go

--запрет удаления клиента (задание2.4)
use Sportshop
go
create trigger [dbo].delete_client 
on Table_Clients 
instead of delete 
as 
	raiserror( 'Вы не можете удалить существующего клиента',0,1)        
	rollback transaction    
go
-- проверка
select * from Table_Clients
go
delete from Table_Clients
where Surname='Серов'
go

--запрет регистрировать уже существующего клиента, при вставке проверять наличие клиента по ФИО и email (задание 2.3)
use Sportshop
go
create trigger [dbo].check_client_insert 
on Table_Clients
instead of insert
as 
begin
   	if exists (select * from inserted i, Table_Clients c
		where (i.Surname=c.Surname and i.[Name]=c.[Name] 
		and i.Patronymic=c.Patronymic and i.Email=c.Email))
	begin       
		raiserror('Вы не можете зарегистрировать уже существующего клиента',16,1)        
	end
	else 
	begin
		insert into Table_Clients (Surname,[Name],Patronymic,Gender,Email,Telephone,Subscription,Discount,BirthDate,RegistrDate)
		select Surname,[Name],Patronymic,Gender,Email,Telephone,Subscription,Discount,BirthDate,RegistrDate from inserted
	end
end
-- проверка
select * from Table_Clients
go

insert into Table_Clients (Surname,[Name],Patronymic,Gender,Email,Telephone,Subscription,Discount,BirthDate,RegistrDate)
values
('Серов','Антон','Петрович','м','sap@mail.ru','','','','1985-07-01','2020-12-25')
go

--запрет удаления сотрудников, принятых на работу до 2015 года (задание 2.5) ДОДЕЛАТЬ!!!
use Sportshop
go
create trigger [dbo].delete_employee 
on Table_Employees 
for delete 
as 
	select deleted.EmploymentDate from deleted
    if exists (select * from deleted where deleted.EmploymentDate < '20150101')
	begin
		raiserror( 'Вы не можете удалить сотрудника, принятого до 2015 года',0,1)        
		rollback transaction    
	end
	else 
		print ('Данные о сотруднике удалены успешно')
go
-- проверка (работает на 1 совпадении, хочется, чтобы не отменялось все на множестве совпадений)
select * from Table_Employees
go
delete from Table_Employees
where Position='товаровед'
go

--при продаже уменьшение количества товаров на складе
use Sportshop
go
create trigger [dbo].change_quantity_products
on Table_Selling
for insert
as
	declare @insQuantity int, @prodQuantity int, @insId_Selling int, @insProduct_id int
	select @insQuantity=i.Quantity	
	from inserted i join Table_Products a 
	on a.Id_Product=i.Product_id
	select @prodQuantity=a.Quantity 
	from inserted i join Table_Products a 
	on a.Id_Product=i.Product_id
	if (@insQuantity > @prodQuantity)
	begin
		raiserror('Остаток товара на складе меньше требуемого',0,1)        
		rollback transaction
	end
	else
	begin
		update Table_Products
		set Quantity = a.Quantity-i.Quantity
		from Table_Products	a join inserted i
		on a.Id_Product=i.Product_id
		--запись в историю (задание 2.1)  
		select @insId_Selling=i.Id_Selling from inserted i
		insert into Table_History 
		select * from Table_Selling s
		where s.Id_Selling= @insId_Selling
	end
	if (@prodQuantity-@insQuantity =1)
	begin
		--запись товара в таблицу последняя единица (задание 2.8)  
		select @insProduct_id=i.Product_id from inserted i
		insert into Table_Last_unit
		values (@insProduct_id, '1')
	end
	if (@prodQuantity-@insQuantity =0)
	begin
		--перенос товара в таблицу архив (задание 2.2) 
		select @insProduct_id=i.Product_id from inserted i
		insert into Table_Archive
		select * from Table_Products p
		where p.Id_Product= @insProduct_id
		--удаление из таблицы последняя единица
		delete Table_Last_unit
		where Product_id= @insProduct_id
		--удаление товара из таблицы товаров (информация о товаре пропадает везде, кроме таблицы архив, 
		--если в ключе поставить удаление каскадно, во всех остальных случаях возникает конфликт) 46стр
		/*update Table_Selling
		set Product_id='0'
		from Table_Selling
		where Product_id in (select Product_id from Table_Selling where Product_id= @insProduct_id)
		delete Table_Products
		where Id_Product= @insProduct_id*/
	end
go

--при продаже подстановка розничной цены, она уже не нужна, тк сделала с учетом скидки
Use Sportshop
go
create trigger [dbo].insert_price
on Table_Selling
for insert,update
as
	update Table_Selling
	set Price =a.Retail_price
	from Table_Products	a join Table_Selling s
	on a.Id_Product=s.Product_id
go


--при продаже подстановка розничной цены с учетом скидки 
use Sportshop
go
create trigger [dbo].insert_price_diskount
on Table_Selling
for insert
as
	--считаю сумму покупок по клиенту 
	declare @customer_id int
	select @customer_id=i.Customer_id
	from inserted i
	--устанавливаю клиенту скидку при необходимости
	declare @summa money
	execute  @summa=[dbo].sum_buy_id_client @customer_id
	if (@summa>50000)
	begin
		update Table_Clients
		set Discount=15
		from Table_Clients c, inserted i
		where c.Id_Client=i.Customer_id
	end
	--устанавливаю цену со скидкой клиента
	declare @price money
	select @price=a.Retail_price*(100- c.Discount)/100
	from Table_Products	a, inserted i, Table_Clients c
	where a.Id_Product=i.Product_id and i.Customer_id=c.Id_Client
	update Table_Selling
	set Price = @price
	from inserted i, Table_Selling s
	where s.Product_id=i.Product_id and s.Date_Sale=i.Date_Sale and s.Customer_id=i.Customer_id
go



--проверка
delete Table_Archive
go

select * from Table_Selling
select * from Table_History
select * from Table_Last_unit
select * from Table_Archive
select * from Table_Products
--select * from Table_Clients
go

insert into Table_Selling
values ('2','1',null,'20210407','17','8')
go

delete Table_Selling
where Date_Sale='20210405'
go

insert into Table_Selling
values ('5','1',null,'20210405','11','15')
go

select [dbo].sum_buy_id_client(15) as 'Сумма покупок'
 select * from Table_Selling
 go	
	
