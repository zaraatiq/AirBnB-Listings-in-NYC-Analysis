/*Creating Library and Uploading Data*/
%let path=/home/u45075787/termproject;
libname Term "/home/u45075787/termproject";

proc import datafile= "/home/u45075787/termproject/AB_NYC_2019_2_V1.xlsx"
out= term.projectV1
dbms=xlsx;

proc import datafile= "/home/u45075787/termproject/AB_NYC_2019_2_V2.xlsx"
out= term.projectV2
dbms=xlsx;

proc import datafile= "/home/u45075787/termproject/AB_NYC_2019_H1.xlsx"
out= term.projectH1
dbms=xlsx;

proc import datafile= "/home/u45075787/termproject/AB_NYC_2019_H2.xlsx"
out= term.projectH2
dbms=xlsx;

///*Points 1-8*///
/*Joining Tables and Using Set Operators*/
proc sql;
create table term.NYC as 
select*
from term.projectV1 as a inner join term.projectV2 as b on a.host_id=b.host_id;
quit;

proc sql;
create table term.NYC2 as 
select*
from term.projectH1 as a inner join term.projectH2 as b on a.host_id=b.host_id;
quit;

proc sql;
create table term.NYCUNION as
select*
from term.NYC
union corr
select*
from term.NYC2;
quit;

/*Using the Select Statement to Select Columns in the Table*/
proc sql inobs=100;
select name, host_name, neighbourhood_group, neighbourhood, room_type, price, number_of_reviews, calculated_host_listings_count, availability_365
from term.NYCUNION; 
quit;

/*Creating a New Column*/
proc sql;
alter table term.NYCUNION add SerialNumber INTEGER;
quit;

/*Retrieving Rows that Satisfy a Condition*/
proc sql;
   title 'Reviews of AirBnB Hosts in Brooklyn';
   select name, host_name, number_of_reviews, neighbourhood_group
      from term.NYCUNION
      where neighbourhood_group ='Brooklyn';
quit;

/*Sorting the Number of Reviews Received by each Host in Descending Order*/
proc sql;
   title 'AirBnB Hosts in NYC Sorted by Reviews';
   select name, host_name, number_of_reviews, neighbourhood_group
      from term.NYCUNION
      order by number_of_reviews desc;
quit; 

/*Points 9-12 and 42*/
/*Summarizing Data- Prices in Manhattan for Private Rooms*/
options symbolgen;
%macro N_G;
%local neighbourhood_group;
%let neighbourhood_group=Manhattan;
proc sql; 
   title 'Prices of Private Rooms in Manhattan';
   select name, neighbourhood_group, room_type, price
      from term.NYCUNION
      where room_type='Private room' and neighbourhood_group='Manhattan'
      order by price desc;
quit;
%mend N_G;
options nosymbolgen;

/*Grouping Data*/
proc sql;
   title 'Total Number of Hosts in Every NYC Neighbourhood Group';
   select neighbourhood_group, count(host_name) as TotalHosts
      from term.NYCUNION
      where host_name is not missing
      group by neighbourhood_group;
quit;

/*Filtering and Subsetting Grouped Data*/
proc sql;
	title 'Least Number of AirBnB Hosts in NYC';
	select neighbourhood_group, count (*) as TotalHosts
		from term.NYCUNION
		where host_name is not missing 
		group by neighbourhood_group
		having TotalHosts not >1000;
quit;

/*Points 13 & 14*/
/*Subsetting data using correlated queries*/
proc sql;
SELECT neighbourhood_group, room_type, price
 FROM term.NYCUNION as out
 WHERE room_type in (SELECT room_type
                 FROM term.NYCUNION
                 WHERE price=out.price);
quit;

/*In line views with other tables or views*/
proc sql;
create table reviews as
select reviews(timepart(last_review)) as last_review, count(*) as TotalReviews from (select last_review from term.NYCUNION)
group by neighbourhood_group;
quit;

/*Points 15-21*/
/*Insert rows into tables*/
proc sql;
   create table term.NYCUNION2
      like term.NYCUNION;
quit;

proc sql;
   insert into term.NYCUNION2
   select * from term.NYCUNION
      where number_of_reviews > 50;
quit;

/*Updating data values in a table*/
proc sql;
   create table term.NYCUNION2 like term.NYCUNION;
   insert into term.NYCUNION2
   select * from term.NYCUNION
      where number_of_reviews >50;
   
proc sql;
   update term.NYCUNION2
      set reviews_per_month=reviews_per_month*30;
   title "Updated Number of Reviews per Month";
   select reviews_per_month format=comma10.0
      from term.NYCUNION2;
quit;
      
/*Delete rows*/
proc sql;
   delete from term.NYCUNION2
      where number_of_reviews >5;
quit;

/*Altering Columns*/
proc sql;
alter table term.NYCUNION2 add neighbourhood_group2 char(5);
quit;

/*Creating an Index*/
proc sql;
create index neighbourhood_group2 on term.NYCUNION2(neighbourhood_group2);
quit;

/*Deleting a table*/
proc sql;
drop table term.NYCUNION2;
quit;

/*Describing table*/
proc sql;
describe table term.NYCUNION;
quit;

/*Points 22, 23, 36*/
%let foot=%str(footnote "Report Generation Date: &SYSDATE Time: &systime";);
%let clear=%str(title;footnote;);

/* Point 24 & 26*/
/*Using %GLOBAL statement*/
%global dummy_table;
%let dummy_table=term.NYCUNION2;

/*Using INTO clause*/
proc sql noprint;
select count(*), price as total_revenue
into :price
	from term.NYCUNION
	where price=1
	group by price;

select count(*), minimum_nights as total_revenue
into :minimum_nights
	from term.NYCUNION
	where minimum_nights=1
	group by minimum_nights;
quit;

proc sql;
create table total_revenue
(revenue char(20),
total_price num format=7.);
quit;

/*Points 27,43,35*/
%macro dummy(t_name);
%local tb_name;
%let tb_name=%upcase(&t_name);
proc sql inobs=50;
create table &tb_name as
select * from term.NYCUNION;
quit;
%put &=tb_name;
%mend dummy;

/*Point 28, 29, 38*/ 
/*28*/
data total_revenue;
	set total_revenue;
	call symput(price, total_price);
run;


data total_revenue1;
	set total_revenue;
	call symputx(price, total_price);
run;

/*29,38*/
data total_revenue;
set total_revenue;
   price=symget(price);
run;

/* Point 30, 31*/ 
%macro neighbourhood_group (Brooklyn, Queens);

/*Point 32*/
/*This macro selects neighbourhood_group locations Brooklyn and Queens*/

/*Point 33*/
%macro test(var1,var2,var3);                                                                                                            
 %put &=var1;                                                                                                                           
 %put &=var2;                                                                                                                           
 %put &=var3;                                                                                                                           
%mend test; 

/*Point 34*/
%macro price(level);
%if &level=1 %then %do;
proc sql;
update term.NYCUNION2
	set price="Cheap" where price=&level;
quit;
%end;
%else %if &level=50 %then %do;
proc sql;
update term.NYCUNION2
	set price="Expensive" where price=&level;
quit;
%end;
%else %if &level=250 %then %do;
proc sql;
update term.NYCUNION2
	set price="Medium" where price=&level;
quit;
%end;
%else %if &level=100 %then %do;
%end;
%mend price;

/* Point 37*/
%let price=50*2;
%let reviews_per_month=2*30;

%let eval_price=%eval(&price);
%let eval_reviews_per_month=%eval(&reviews_per_month);

%put &price is &eval_price;
%put &reviews_per_month is &eval_reviews_per_month;

/* Points 39,40*/
options mlogic;
%dummy(&dummy_table);
options nomlogic;

proc sql;
alter table term.NYCUNION2 drop number_of_reviews;
alter table term.NYCUNION2 add NUMBER_OF_REVIEWS char(10);
quit;

/*41*/
options mprint;
%poi(&amenity, &bump, &crossing, &give_way, &junction, &no_exit, &railway, &roundabout, &station, &stop, &traffic_calming, &traffic_signal);
options nomprint;

/* Point 44 */
proc sql noprint;
select distinct number_of_reviews
into :number_of_rev separated by "," from term.NYCUNION;
quit;
%put &=number_of_rev;

/* Point 45*/
proc sql noprint;
select * from &&tb&price;
quit;

/*Point 46*/
%macro loop(finish);
%let price=1;
%DO %while (&price<&finish);
%price(&price);
      %let price=%eval(&price+1);
%END;
%mend loop;
%loop(5);
