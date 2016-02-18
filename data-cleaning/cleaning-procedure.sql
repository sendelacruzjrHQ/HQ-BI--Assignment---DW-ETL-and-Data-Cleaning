/*
	BI Assigment	: Data Cleaning
	Created by		: Sen Dela Cruz
	Created date	: 16 Feb 2016
	Problem			: There are ocassionaly problems with the underlying data, there could be a bug in the production system or some of the data are manually adjusted.
	Objectives		: Create a system to identify the outliers.

					***List of possible outliers
					--check-in date is greater than check-out date
					--null valued fields
					--valid offer from date is greater than valid offer to date
					--selling price is less than or equal to zero
					--invalid dates
					--insert datetime is greater than check-in date
					--duplicate ID
					--currency ID does not exists on lst_currency table

					***advisable to run after bulk insert
					***alter the sp for other possible outliers
					***include parameter option to view and delete or view data only
					***test script available at the bottom for testing
*/

use [HQBIdb]

go

create procedure [primary_data].sp_primary_data_clean (@vDeleteRec	bit=0)
as

set nocount on

--temporary table
if object_id('tempdb..#tmpPD') is not null
    drop table tmpPD

--check-in date is greater than check-out date
select	*,remarks='[checkin_date] > [checkout_date]'
into	#tmpPD 
from	primary_data.offer
where	cast(checkin_date as datetime)>cast(checkout_date as datetime)

union

--source system code value is null
select	*,'[source_system_code] is null'
from	primary_data.offer
where	source_system_code is null 

union

--available count value is null
select	*,'[available_cnt] is null'
from	primary_data.offer
where	available_cnt is null 

union

--selling price value is null
select	*,'[sellings_price] is null'
from	primary_data.offer
where	sellings_price is null 

union

--check-in date is null'
select	*,'[checkin_date] is null'
from	primary_data.offer
where	checkin_date is null 

union

--check-out date is null
select	*,'[checkout_date] is null'
from	primary_data.offer
where	checkout_date is null 

union

--valid offer without available room
select	*,'[available_cnt] <=0 and [valid_offer_flag]=1' 
from	primary_data.offer
where	available_cnt<=0 and
		valid_offer_flag=1

union

--valid offer from date is greater than valid offer to date
select	*,'[offer_valid_from]>[offer_valid_to]'
from	primary_data.offer
where	(cast(offer_valid_from as datetime)>cast(offer_valid_to as datetime)) and
		valid_offer_flag=1

union

--selling price is less than or equal to zero
select	*,'[sellings_price]<=0'
from	primary_data.offer
where	cast(sellings_price as float)<=0.0

union

--invalid date value for [offer_valid_from] field
select	*,'Invalid date ==> [offer_valid_from]'
from	primary_data.offer
where	year(cast(offer_valid_from as datetime))=1999 

union

--invalid date value for [offer_valid_to] field
select	*,'Invalid date ==> [offer_valid_to]'
from	primary_data.offer
where	year(cast(offer_valid_to as datetime))=1999 

union

--invalid date value for [checkin_date] field
select	*,'Invalid date ==> [checkin_date]'
from	primary_data.offer
where	year(cast(checkin_date as datetime))=1999 

union

--invalid date value for [checkout_date] field
select	*,'Invalid date ==> [checkout_date]'
from	primary_data.offer
where	year(cast(checkout_date as datetime))=1999 

union

--insert datetime is greater than check-in date
select	*,'[insert_datetime]>[checkin_date]'
from	primary_data.offer
where	cast(checkin_date as datetime)<cast(convert(varchar(10),cast(insert_datetime as datetime),101) as datetime)

union

--duplicate ID
select	*, 'Duplicate ID'
from	primary_data.offer
where	ID in
(
	select	ID
	from	primary_data.offer
	group by	id
	having count(*)>1
)	

union

--'currency ID does not exists on lst_currency table' 
select *,'Currency ID not exists on [lst_currency] table' 
from primary_data.offer
where currency_id not in (select distinct id from primary_data.lst_currency)

--delete data
if @vDeleteRec=1
begin

	delete	from primary_data.offer
	where	cast(checkin_date as datetime)>cast(checkout_date as datetime)

	delete	from	primary_data.offer
	where	source_system_code is null 

	delete	from	primary_data.offer
	where	available_cnt is null 

	delete	from	primary_data.offer
	where	sellings_price is null 
	
	delete	from	primary_data.offer
	where	checkin_date is null 

	delete	from	primary_data.offer
	where	checkout_date is null 

	delete	from	primary_data.offer
	where	available_cnt<=0 and
			valid_offer_flag=1

	delete	from	primary_data.offer
	where	(cast(offer_valid_from as datetime)>cast(offer_valid_to as datetime)) and
			valid_offer_flag=1

	delete	from	primary_data.offer
	where	cast(sellings_price as float)<=0.0

	delete	from	primary_data.offer
	where	year(cast(offer_valid_from as datetime))=1999 

	delete	from	primary_data.offer
	where	year(cast(offer_valid_to as datetime))=1999 

	delete	from	primary_data.offer
	where	year(cast(checkin_date as datetime))=1999 

	delete	from	primary_data.offer
	where	year(cast(checkout_date as datetime))=1999 

	delete	from	primary_data.offer
	where	cast(checkin_date as datetime)<cast(convert(varchar(10),cast(insert_datetime as datetime),101) as datetime)

	delete	from	primary_data.offer
	where	ID in
	(
		select	ID
		from	primary_data.offer
		group by	id
		having count(*)>1
	)	

	delete	from primary_data.offer
	where	currency_id not in (select distinct id from primary_data.lst_currency)

end

--show all outliers data
select	id,
		hotel_id,
		currency_id,
		source_system_code,
		available_cnt,
		sellings_price=cast(sellings_price as float),
		checkin_date=cast(checkin_date as smalldatetime),
		checkout_date=cast(checkout_date as smalldatetime),
		valid_offer_flag,
		offer_valid_from=cast(offer_valid_from as datetime),
		offer_valid_to=cast(offer_valid_to as datetime),
		breakfast_included_flag,
		insert_datetime=cast(insert_datetime as datetime),
		remarks
from	#tmpPD
order by cast(insert_datetime as datetime)


-----------------------------
------SCRIPT FOR CHECKING
-----------------------------
----(1) set parameter to 0 - without deleting the data
----show records for clean-up
--exec [primary_data].sp_primary_data_clean 0

----(2) set parameter to 1 - delete data
--begin tran
--go
----record count before clean-up
--select [record count before]=count(*) from [primary_data].offer
--go
----show records for clean-up and delete
--exec [primary_data].sp_primary_data_clean 1
--go
----record count after clean-up
--select [record count after]=count(*) from [primary_data].offer
--go
--rollback tran
