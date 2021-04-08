--резервное копирование
BACKUP DATABASE [Sportshop] 
TO  DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\Backup\Sportshop.bak' 
WITH  RETAINDAYS = 1, NOFORMAT, NOINIT,  NAME = N'Sportshop-Полная База данных Резервное копирование', 
SKIP, NOREWIND, NOUNLOAD,  STATS = 10
GO

--проверка
declare @backupSetId as int
select @backupSetId = position from msdb..backupset 
where database_name=N'Sportshop' and backup_set_id=(select max(backup_set_id) 
from msdb..backupset 
where database_name=N'Sportshop' )
if @backupSetId is null 
begin 
	raiserror(N'Ошибка верификации. Сведения о резервном копировании для базы данных "Sportshop" не найдены.', 16, 1) 
end
RESTORE VERIFYONLY FROM  DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\Backup\Sportshop.bak' 
WITH  FILE = @backupSetId,  NOUNLOAD,  NOREWIND
GO

--восстановление базы данных
USE [master]
RESTORE DATABASE [Sportshop] 
FROM  DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\Backup\Sportshop.bak' 
WITH  FILE = 2,  
MOVE N'Sportshop' TO N'C:\Ирина\академия шаг\Base data\Sportshop TEMP\Sportshop.mdf',  
MOVE N'Sportshop_log' TO N'C:\Ирина\академия шаг\Base data\Sportshop TEMP\Sportshop_log.ldf',  
NOUNLOAD,  STATS = 5

GO



