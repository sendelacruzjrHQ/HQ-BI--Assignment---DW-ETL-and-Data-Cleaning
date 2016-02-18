BI Assignment - 2.0 Data Cleaning

Problem			: There are ocassionaly problems with the underlying data, there could be a bug in the production system or some of the data are manually adjusted.
Objectives		: Create a system to identify the outliers.

List of possible outliers :
***	Check-in date is greater than check-out date
*** Null valued fields
*** Valid offer from date is greater than valid offer to date
*** Selling price is less than or equal to zero
*** Invalid dates
*** Insert datetime is greater than check-in date
*** Duplicate ID
*** Currency ID does not exists on lst_currency table

Steps:
1. Open [HQBIdb](from assignment #1 - datawarehouse and etl) and open new query
2. Run script(cleaning-procedure.sql), please test without parameter first(view data only) before testing the option with delete.

Other Notes:
*** Advisable to embed the stored procedure after bulk insert
*** Alter the stored procedure for other possible outliers
*** Include parameter option to view and/or delete the data
*** Test script available at the bottom the sql script(cleaning-procedure.sql) for testing
*** To reload data run the script from the first assignment(datawarehouse-etl.sql)
*** Any issue please send email to sendelacruzjr@gmail.com