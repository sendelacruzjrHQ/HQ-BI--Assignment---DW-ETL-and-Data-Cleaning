BI Assignment - 1.0 Datawarehouse and ETL

Objectives :
1. Create a new database (HQBIdb)
2. Create a new schema: primary_data
3. Load the 3 tables 1:1 to the primary_data schema (structure same as the CSV files have)
4. Create a new schema: bi_data 
5. Create ETL scripts to extract, transform and load the data from the primary_data schema to the bi_data schema

-------------
Mini Glossary
-------------
offer					deals that hotels give us (offers from hotels)
lst_currency				list of all supported currencies
fx_rate					currency exchange rates from prim_currency_id to scnd_currency_id
prim_currency_id			primary currency ID (exchange from this currency)
scnd_currency_id			secondary currency ID (exchange to this currency)
primary_data				schema which includes the primary tables
bi_data					schema which includes the tables for the BI team
valid_offer_available_flag		indication if a hotel has a valid offer during the specified period (at least 1 minute within the 1 hour)
price_usd				the original_price converted to USD
valid_from_date / valid_to_date		indication of time date&time when the offer became active / inactive. 
				
***Offers cannot overlap for one hotel with the same parameters (checkin, checkout, source, breakfast)
***The valid_offers table should show only valid offers with price converted to USD.
***The hotel_offers table should indicate for each hotel if the hotel had offers for each day and hour. 
***The days & hours when the hotel was not available should have indication valid_offer_available_flag = 0.

Steps:
1. Create [HQ] folder under [c:\temp] drive and place the csv file source or you may modify the script to change the source path
2. Open SQL Server Management Studio 2012. Just in case the application is not available on your PC you may download the express version on the link below:
https://www.microsoft.com/en-us/download/details.aspx?id=29062 
3. Connect to local server using windows authentication
4. Open new query and run the script(datawarehouse-etl.sql), script will run 1-2 minutes depending on the PC specs. 

Other notes :
*** Test machine used - local PC with core i5 processor and 4 gb ram
*** Test script for checking included at the bottom of the sql script,unblock the remarks and change the values of the variables for checking
*** Any issue please send email to sendelacruzjr@gmail.com
