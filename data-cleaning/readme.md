----------------------------------
BI Assignment - 2.0 Data Cleaning
----------------------------------

Problem			: There are ocassionaly problems with the underlying data, there could be a bug in the production system or some of the data are manually adjusted.<br>
Objectives	: Create a system to identify the outliers.<br>

List of possible outliers :<br>
***	Check-in date is greater than check-out date<br>
*** Null valued fields<br>
*** Valid offer from date is greater than valid offer to date<br>
*** Selling price is less than or equal to zero<br>
*** Invalid dates<br>
*** Insert datetime is greater than check-in date<br>
*** Duplicate ID<br>
*** Currency ID does not exists on lst_currency table<br>

Steps:<br>
1. Open [HQBIdb](from assignment #1 - datawarehouse and etl) and open new query<br>
2. Run script(cleaning-procedure.sql), please test without parameter first(view data only) before testing the option with delete.<br>

Other Notes:<br>
*** Advisable to embed the stored procedure after bulk insert<br>
*** Alter the stored procedure for other possible outliers<br>
*** Include parameter option to view and/or delete the data<br>
*** Test script available at the bottom the sql script(cleaning-procedure.sql) for testing<br>
*** To reload data run the script from the first assignment(datawarehouse-etl.sql)<br>
*** Any issue please send email to sendelacruzjr@gmail.com<br>
