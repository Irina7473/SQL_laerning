--настройка безопасности доступа
use Sportshop
go

-- создание логина и пользователя директор
create login Boss 
with password = '123';  
use Sportshop; 
create user Boss 
for login Boss; 
-- пользователю Boss разрешено все
GRANT ALL     
TO Boss 
-- добавляем в роль на чтение всей базы данных директора
exec sp_addrolemember 'db_datareader', 'Boss'; 

-- создание логина и пользователя бухгалтер
create login Accountant1 
with password = '789';  
use Sportshop; 
create user Accountant1 
for login Accountant1; 
-- создаю роль бухгалтер и добавляю в нее пользователя бухгалтер
create role accountant;   
exec sp_addrolemember 'accountant', 'Accountant1'; 
-- даю право роли бухгалтер на все, кроме удаления в таблице продавцов
DENY ALL on Table_Employees to public;
grant select, update, insert 
on OBJECT:: [dbo].Table_Employees
to accountant; 

-- создание логина и пользователя продавец
create login Employee1
 with password = '302';  
use Sportshop; 
create user Employee1
 for login Employee1;
 -- создаю роль продавец и добавляю в нее пользователя продавец1
create role employee
exec sp_addrolemember 'employee', 'Employee1';
-- даю право роли продавец на все, кроме удаления в таблице товары
DENY ALL on Table_Products to public;
grant select, update, insert 
on OBJECT:: [dbo].Table_Products
to employee; 

-- разрешаю всем (роль public) смотреть таблицу продажи, а роли продавец менять в ней количество
grant select on Table_Selling  to public; 
grant update 
on OBJECT:: [dbo].Table_Selling  (Quantity) 
to employee;


