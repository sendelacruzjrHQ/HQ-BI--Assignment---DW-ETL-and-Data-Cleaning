-------------------------------------------
BI Assignment - 1.0 Datawarehouse and ETL
-------------------------------------------

Objectives :<br>
1. Create a new database (HQBIdb)<br>
2. Create a new schema: primary_data<br>
3. Load the 3 tables 1:1 to the primary_data schema (structure same as the CSV files have)<br>
4. Create a new schema: bi_data <br>
5. Create ETL scripts to extract, transform and load the data from the primary_data schema to the bi_data schema<br>


Mini Glossary:<br>
offer ==> deals that hotels give us (offers from hotels)<br>
lst_currency ==> list of all supported currencies<br>
fx_rate	==> currency exchange rates from prim_currency_id to scnd_currency_id<br>
prim_currency_id ==>primary currency ID (exchange from this currency)<br>
scnd_currency_id ==> secondary currency ID (exchange to this currency)<br>
primary_data ==> schema which includes the primary tables<br>
bi_data	==> schema which includes the tables for the BI team<br>
valid_offer_available_flag ==> indication if a hotel has a valid offer during the specified period (at least 1 minute within the 1 hour)<br>
price_usd ==> the original_price converted to USD<br>
valid_from_date / valid_to_date ==> indication of time date&time when the offer became active / inactive.<br>

***Offers cannot overlap for one hotel with the same parameters (checkin, checkout, source, breakfast)<br>
***The valid_offers table should show only valid offers with price converted to USD.<br>
***The hotel_offers table should indicate for each hotel if the hotel had offers for each day and hour. <br>
***The days & hours when the hotel was not available should have indication valid_offer_available_flag = 0.<br>

Steps:<br>
1. Create [HQ] folder under [c:\temp] drive and place the csv file source or you may modify the script to change the source path<br>
2. Open SQL Server Management Studio 2012. Just in case the application is not available on your PC you may download the express version on the link below:<br>
https://www.microsoft.com/en-us/download/details.aspx?id=29062 <br>
3. Connect to local server using windows authentication<br>
4. Open new query and run the script(datawarehouse-etl.sql), script will run 1-2 minutes depending on the PC specs. <br>

Other notes :<br>
*** Test machine used - local PC with core i5 processor and 4 gb ram<br>
*** Test script for checking included at the bottom of the sql script,unblock the remarks and change the values of the variables for checking<br>
*** Any issue please send email to sendelacruzjr@gmail.com<br>
