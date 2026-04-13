use master;

if exists (select 1 from sys.databases where name = 'data_warehouse')
begin
	alter database data_warehouse set single_user with rollback immediate;
	drop database data_warehouse;
end;
go

create database data_warehouse;
go
use data_warehouse;
go
create schema bronze;
go
create schema silver;
go
create schema gold;
