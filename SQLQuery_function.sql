use Sportshop
go

-- ѕќЋ№«ќ¬ј“≈Ћ№— »≈ ‘”Ќ ÷»»

--функци€ возвращает количество уникальных покупателей (дз2 задание 3.1)
create function [dbo].number_unique_customer()
returns int
as
begin
return (select  count (distinct Customer_id)
from Table_Selling) 
end

select [dbo].number_unique_customer() as 'count_unique_Customer'

--функци€ возвращает среднюю цену товара конкретного вида(передаваемый параметр) (дз2 задание 3.2) 
create function [dbo].avg_price_type_product 
				(@type_product nvarchar(10))
returns int
as
begin
return (select  AVG (Retail_price) 
		from Table_Products
		where Type_Product=@type_product) 
 end

 select [dbo].avg_price_type_product('одежда') as 'avg_price'
 select * from Table_Products
go

--функци€ возвращает среднюю цену продажи по каждой дате, когда осуществл€лись продажи (дз2 задание 3.3) 
create function [dbo].avg_price_selling_date()
returns table
as
return (select Date_Sale as 'Date_Sale', AVG (Price) as 'avg_price'
		from Table_Selling
		group by Date_Sale) 
 go

 select * from [dbo].avg_price_selling_date()
 select * from Table_Selling
go

--функци€ возвращает информацию о последнем проданном товаре по дате продажи (дз2 задание 3.4) 
create function [dbo].last_sold_product()
returns table
as
return (select* from Table_Products p
		where p.Id_Product in (select s.Product_id from Table_Selling s
		where s.Date_Sale = (select MAX(Date_Sale) from Table_Selling)))
go

 select * from [dbo].last_sold_product()
 select * from Table_Selling
go

--функци€ возвращает информацию о первом проданном товаре по дате продажи (дз2 задание 3.5) 
create function [dbo].first_sold_product()
returns table
as
return (select* from Table_Products p
		where p.Id_Product in (select s.Product_id from Table_Selling s
		where s.Date_Sale = (select MIN(Date_Sale) from Table_Selling)))
go

 select * from [dbo].first_sold_product()
 select * from Table_Selling
go

--информаци€ о виде товаров конкретного производител€, которые передаютс€ в качестве параметров (дз2 задание 3.6) 
create function [dbo].product_type_fabricator
				(@type_product nvarchar(10), @fabricator nvarchar(30))
returns table
as
return (select* from Table_Products
		where Type_Product=@type_product and Fabricator=@fabricator)
go

select * from [dbo].product_type_fabricator('инвентарь', 'ABC')
 select * from Table_Products
go

--информацию о покупател€х, которым в этом году исполнитс€ 45 лет (дз2 задание 3.7) 
create function [dbo].clients_age_45(@age int)
returns table
as
return (select* from Table_Clients
		where DATEDIFF(YEAR, BirthDate, GETDATE())= @age )
go

select * from [dbo].clients_age_45('45')
 select * from Table_Clients
go

--функци€ возвращает информацию суммах покупок клиентов 
create function [dbo].sum_buy_client()
returns table
as
return (select TOP 3 c.Surname+' '+c.[Name]+ ' '+c.Patronymic as '‘»ќ клиента',
				SUM(s.Quantity * s.Price) as '—умма покупок'
		from Table_Selling s, Table_Clients c
		where s.Customer_id= c.Id_Client
		group by c.Surname+' '+c.[Name]+ ' '+c.Patronymic
		order by '—умма покупок' desc)
go

 select * from [dbo].sum_buy_client()
 select * from Table_Selling
go

--функци€ возвращает информацию суммах покупок конкретного клиента дл€ определени€ скидки
--лучше сделать, чтобы данные брались из истории, но € уже поизмен€ла данные и  истори€ меньше продаж
create function [dbo].sum_buy_id_client
			(@idclient int)
returns money
as
begin
return (select SUM(s.Quantity * s.Price)
		from Table_Selling s
		where s.Customer_id= @idclient)
--return (select SUM(h.Quantity * h.Price)
		--from Table_History h
		--where h.Customer_id= @idclient)
end

select [dbo].sum_buy_id_client(8) as '—умма покупок'
select * from Table_History