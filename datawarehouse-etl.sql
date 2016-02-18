/*
	BI Assigment	: Datawarehouse and ETL 
	Created by		: Sen Dela Cruz
	Created date	: 16 Feb 2016
	Objectives		(1)	Create a new database (HQBIdb)
					(2)	Create a new schema: primary_data
					(3)	Load the 3 tables 1:1 to the primary_data schema (structure same as the CSV files have)
					(4)	Create a new schema: bi_data 
					(5)	Create ETL scripts to extract, transform and load the data from the primary_data schema to the bi_data schema
	-------------
	Mini Glossary
	-------------
	offer								deals that hotels give us (offers from hotels)
	lst_currency						list of all supported currencies
	fx_rate								foreign exchange rates (currency exchange rates from prim_currency_id to scnd_currency_id)
	prim_currency_id					primary currency ID (exchange from this currency)
	scnd_currency_id					secondary currency ID (exchange to this currency)
	primary_data						schema which includes the primary tables
	bi_data								schema which includes the tables for the BI team
	valid_offer_available_flag			indication if a hotel has a valid offer during the specified period (at least 1 minute within the 1 hour)
	price_usd							the original_price converted to USD
	valid_from_date / valid_to_date		indication of time date&time when the offer became active / inactive. 
										Please note the offers cannot overlap for one hotel with the same parameters (checkin, checkout, source, breakfast)

	*** The valid_offers table should show only valid offers with price converted to USD.
	*** The hotel_offers table should indicate for each hotel if the hotel had offers for each day and hour. 
	***	The days & hours when the hotel was not available should have indication valid_offer_available_flag = 0.

	Other notes :
	*** The script will run from 1-2 minutes depending on the PC specs.
	*** Test machine used - local PC with core i5 processor and 4 gb ram
	*** Please create subfolder [hq] folder under [c:\temp] folder and place the csv file source or you may modify the script to change the source path
	*** I have included a script for checking at the bottom of the script, you may remove the remarks and change the values of the variables for checking
*/
use [master]

go
--create new database, include if checking if database exist for rerun purposes
if  exists (select name from master.dbo.sysdatabases where name = N'HQBIdb')
	drop database [HQBIdb]
go
		
create database [HQBIdb]

go

use [HQBIdb]

go

--create primary data schema
create schema primary_data

go

--create staging tables and set all data type fields to varchar in able to use bulk insert function for faster data loading

--create offer table
create table primary_data.offer
(
	id							varchar(255),
	hotel_id					varchar(255),
	currency_id					varchar(255),
	source_system_code			varchar(255),--inventory source system
	available_cnt				varchar(255),--number of rooms available
	sellings_price				varchar(255),
	checkin_date				varchar(255),
	checkout_date				varchar(255),
	valid_offer_flag			varchar(255),--indication if the offer is valid or not
	offer_valid_from			varchar(255),--datetime
	offer_valid_to				varchar(255),--datetime
	breakfast_included_flag		varchar(255),--indication if the breakfast is included in the price
	insert_datetime				varchar(255) --datetime when the row was inserted to the database
)

go

--load offer data (12 secs)
bulk insert primary_data.offer
	from 'c:\temp\hq\offer.csv' --source file path
	with 
		(
			firstrow = 1,
			fieldterminator =',',
			rowterminator = '\n'
		)

go

--function to convert date to "MM-DD-YYYY" format, for query purposes
create function [primary_data].[fConvDate101](@vDate103 varchar(255))
returns varchar(255)
as
begin
	set		@vDate103=ltrim(rtrim(@vDate103))
	return	substring(@vDate103,4,2)+'/'+ substring(@vDate103,1,2)+'/'+substring(@vDate103,7,2)+substring(@vDate103,9,6)
end

go

----Part 2 Cleaning Data (please do not remove remarks, this is just to state where to place the clean-up procedure) 
--exec [primary_data].sp_primary_data_clean 1

--go

--change all date format fields to "MM-DD-YYYY", for query purposes 
update	primary_data.offer
set		checkin_date=[primary_data].[fConvDate101](checkin_date),
		checkout_date=[primary_data].[fConvDate101](checkout_date),
		offer_valid_from=[primary_data].[fConvDate101](offer_valid_from),
		offer_valid_to=[primary_data].[fConvDate101](offer_valid_to),
		insert_datetime=[primary_data].[fConvDate101](insert_datetime)
go

--create list of currency table
create table primary_data.lst_currency
(
	id		varchar(255),
	code	varchar(255),
	name	varchar(255)
)

go

--load list of currency data(less than a sec)
bulk insert primary_data.lst_currency
	from 'c:\temp\hq\lst_currency.csv'--source file path
	with 
		(
			firstrow = 2,
			fieldterminator =',',
			rowterminator = '\n'
		);

go 

--create fx rate table
create table primary_data.fx_rate
(
	id					varchar(255),
	prim_currency_id	varchar(255),
	scnd_currency_id	varchar(255),
	[date]				varchar(255),
	currency_rate		varchar(255)
)

go

--load foreign exchange rate data(less than a sec)
bulk insert primary_data.fx_rate
	from 'c:\temp\hq\_fx_rate.csv'--source file path
	with 
		(
			firstrow = 2,
			fieldterminator =',',
			rowterminator = '\n'
		);

go

--change field format to "MM-DD-YYYY" 
update	primary_data.fx_rate
set		[date]=[primary_data].[fConvDate101]([date])

go

--create bi_date schema	  
create schema bi_data

go

--create valid offer table
create table bi_data.valid_offers
(
	offer_id				int	not null,
	hotel_id				int	not null,
	price_usd				float,
	original_price			float,
	original_currency_code	varchar(35),
	breakfast_included_flag int	not null,
	valid_from_date			datetime not null,
	valid_to_date			datetime not null
	constraint [pk_valid_offers] primary key clustered 
(
	[offer_id] asc,
	[hotel_id] asc,
	[breakfast_included_flag] asc,
	[valid_from_date] asc,
	[valid_to_date] asc
)
) on [primary]

go

--generate valid offers data (2 secs)
insert into bi_data.valid_offers
select		o.id,
			o.hotel_id,			
			price_usd=(cast(o.sellings_price as float) * cast(f.currency_rate as float)),
			o.sellings_price,
			o.currency_id,
			o.breakfast_included_flag,
			o.offer_valid_from,
			o.offer_valid_to
from		primary_data.offer o
			inner join	primary_data.lst_currency c
			on	o.currency_id=c.id
			inner join	primary_data.fx_rate f
			on	o.currency_id=f.prim_currency_id and
				f.scnd_currency_id=1 and --USD
				o.checkin_date=f.[date] --conversion based on check-in date
where		o.valid_offer_flag=1 and -- active offers
			o.currency_id<>1 --show only valid offers with price converted to USD

go

--create hotel offer table
create table bi_data.hotel_offers
(
	hotel_id					int not null,
	[date]						datetime not null,
	[hour]						int not null,
	breakfast_included_flag		int not null,
	valid_offer_available_flag	int
)

go 

--temporary hour table
if object_id('tempdb..#tmpHour') is not null
    drop table #tmpHour

go

create table #tmpHour
(
	[hour]	int
)

declare @ctr int

set @ctr=0

while @ctr<24
begin
	insert into #tmpHour values (@ctr)
	set @ctr=@ctr+1
end

--temporary hotel offer table
if object_id('tempdb..#tmpHotelOffers') is not null
    drop table #tmpHotelOffers

create table #tmpHotelOffers
(
	hotel_id					int,
	[date]						datetime,
	[hour]						int,
	breakfast_included_flag		int,
	valid_offer_available_flag	int
)

set @ctr=0

--load hotel offers data (4 secs)
while @ctr<=(select max(datediff(day,valid_from_date,valid_to_date)) from bi_data.valid_offers)--record with the most number of booked days
begin
	insert into #tmpHotelOffers
	select	distinct
			hotel_id,
			[date]=dateadd(day,@ctr,cast(convert(varchar(10),valid_from_date,101) as datetime)),
			h.[hour],
			breakfast_included_flag,
			--The days & hours when the hotel was not available should have indication valid_offer_available_flag = 0.
			valid_offer_available_flag=(case when	dateadd(hour,h.[hour],dateadd(day,@ctr,cast(convert(varchar(10),valid_from_date,101) as datetime))) 
														>= dateadd(hour, datediff(hour, 0, o.valid_from_date), 0) and
													dateadd(hour,h.[hour],dateadd(day,@ctr,cast(convert(varchar(10),valid_from_date,101) as datetime)))
														< o.valid_to_date then 1 else 0 end)
	from	bi_data.valid_offers o
			cross apply
			(select [hour] from #tmpHour) h
	where  datediff(day,valid_from_date,valid_to_date) >=@ctr
	set @ctr=@ctr+1
end

go

--select all unique records and move data to physical table
insert into bi_data.hotel_offers
select	distinct
		hotel_id,
		[date],
		[hour],
		breakfast_included_flag,
		valid_offer_available_flag
from	#tmpHotelOffers

--remove all data having more than one valid offer available flag 
delete a from bi_data.hotel_offers a
inner join
(
		select hotel_id, date, hour
		from	bi_data.hotel_offers
		group by hotel_id, date, hour
		having count(*) > 1 
) b
	on a.hotel_id=b.hotel_id and
	a.date=b.date and
	a.hour=b.hour		
where  a.valid_offer_available_flag=0 

go

--set primary key on hotel offers table after data loading, DW data ready for BI
alter table bi_data.hotel_offers
add constraint pk_hotel_offerid primary key nonclustered (hotel_id, [date],[hour],breakfast_included_flag)

go

--stored procedure to get hotel best deal, will be used on part 3(API endpoint)
create procedure bi_data.spqGetBestDeal
(
	@vHotelID		int,
	@vCheckInDate	datetime,
	@vCheckOutDate	datetime
)

as 

set nocount on

if @vCheckInDate > @vCheckOutDate 
	select null,null,null,null,null,null
else
	select	top 1
			o.offer_id,
			o.hotel_id,
			check_in_date=convert(varchar(10),@vCheckInDate,101),
			check_out_date=convert(varchar(10),@vCheckOutDate,101),
			selling_price=o.original_price,
			currency_code=isnull(c.code,'unknown')
	from	bi_data.valid_offers o
			left join	primary_data.lst_currency c
			on	o.original_currency_code=c.id
	where	o.hotel_id= @vHotelID and
			(cast(convert(varchar(10),o.valid_from_date,101) as datetime) <= @vCheckInDate) and
			(cast(convert(varchar(10),o.valid_to_date,101) as datetime) >= @vCheckOutDate)  
	order by o.original_price 

go

---------------------------
----SCRIPT FOR CHECKING
---------------------------

--declare	@vHotelID int

--set		@vHotelID=4351--8639 --34	

----valid offer data
--select * from bi_data.valid_offers
--where hotel_id=@vHotelID
--order by valid_from_date,valid_to_date

----hotel offer data
--select * from bi_data.hotel_offers
--where hotel_id=@vHotelID
--order by hotel_id, [date],[hour]

--select	hotel_id,
--		[date]=cast(convert(varchar(10),valid_from_date,101) as datetime),
--		h.[hour],
--		breakfast_included_flag,
--		valid_offer_available_flag=(case when	dateadd(hour,h.[hour],cast(convert(varchar(10),valid_from_date,101) as datetime)) 
--												>= dateadd(hour, datediff(hour, 0, o.valid_from_date), 0) and
--												dateadd(hour,h.[hour],cast(convert(varchar(10),valid_from_date,101) as datetime))
--												< o.valid_to_date then 1 else 0 end),
--		d_diff=datediff(day,valid_from_date,valid_to_date),
--		h_diff=datediff(hour,valid_from_date,valid_to_date),
--		h=dateadd(hour,h.[hour],cast(convert(varchar(10),valid_from_date,101) as datetime)),
--		o.valid_from_date,
--		o.valid_to_date
--from	bi_data.valid_offers o
--		cross apply
--		(select [hour] from #tmpHour) h
--where	o.hotel_id=@vHotelID
--order by	hotel_id,cast(convert(varchar(10),valid_from_date,101) as datetime), h.[hour]






