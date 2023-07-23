
--creating table to merge all 13 datasets
create table all_data(
ride_id nvarchar(225),
rideable_type nvarchar(50),
start_station_name nvarchar(225),
started_at datetime2,
ended_at datetime2,
start_lat float,
start_lng float,
end_lat float,
end_lng float,
member_casual nvarchar(50))


--inserting all the info by usinh union all
insert into all_data (ride_id, rideable_type, start_station_name, started_at, ended_at, start_lat, start_lng, end_lat, end_lng, member_casual)
(select ride_id, rideable_type, start_station_name, started_at, ended_at, start_lat, start_lng, end_lat, end_lng, member_casual from [202004])
union all
(select ride_id, rideable_type, start_station_name, started_at, ended_at, start_lat, start_lng, end_lat, end_lng, member_casual from [202005])
union all
(select ride_id, rideable_type, start_station_name, started_at, ended_at, start_lat, start_lng, end_lat, end_lng, member_casual from [202006])
union all
(select ride_id, rideable_type, start_station_name, started_at, ended_at, start_lat, start_lng, end_lat, end_lng, member_casual from [202007])
union all
(select ride_id, rideable_type, start_station_name, started_at, ended_at, start_lat, start_lng, end_lat, end_lng, member_casual from [202009])
union all
(select ride_id, rideable_type, start_station_name, started_at, ended_at, start_lat, start_lng, end_lat, end_lng, member_casual from [202010])
union all
(select ride_id, rideable_type, start_station_name, started_at, ended_at, start_lat, start_lng, end_lat, end_lng, member_casual from [202011])
union all
(select ride_id, rideable_type, start_station_name, started_at, ended_at, start_lat, start_lng, end_lat, end_lng, member_casual from [202012])
union all
(select ride_id, rideable_type, start_station_name, started_at, ended_at, start_lat, start_lng, end_lat, end_lng, member_casual from [202101])
union all
(select ride_id, rideable_type, start_station_name, started_at, ended_at, start_lat, start_lng, end_lat, end_lng, member_casual from [202102])
union all
(select ride_id, rideable_type, start_station_name, started_at, ended_at, start_lat, start_lng, end_lat, end_lng, member_casual from [202103])
union all
(select ride_id, rideable_type, start_station_name, started_at, ended_at, start_lat, start_lng, end_lat, end_lng, member_casual from [202104])


select * from all_data

--Adding a new column to calculate the ride length from datetime2
alter table all_data
add ride_length int

update all_data
set ride_length = datediff(minute, started_at, ended_at)

-- Extracting month and year from datetime2 format and adding them as new columns
alter table all_data
add day_of_week nvarchar(50),
month_m nvarchar(50),
year_y nvarchar(50)

update all_data
set day_of_week = datename(weekday, started_at),
month_m = datename(month, started_at),
year_y = year(started_at)


alter table all_data
add month_int int

update all_data
set month_int = datepart(month, started_at)

alter table all_data
add date_yyyy_mm_dd date

update all_data
set date_yyyy_mm_dd = cast(started_at as date) 

-- deleting rows with null values
delete from all_data
where ride_id is null or
ride_length is null or
ride_length = 0 or
ride_length < 0 or
ride_length > 1440

--checking for duplicates
select count(distinct(ride_id)) as uniq,
count(ride_id) as total
from all_data

select * from all_data

-- Calculating Number of Riders Each Day by User Type and Creating View to store date for Further Visualization 
create view users_per_day as
select
count(case when member_casual = 'member' then 1 else null end) as num_of_member,
count(case when member_casual = 'casual' then 1 else null end) num_of_casual,
count(*) num_of_user,
day_of_week
from all_data
group by day_of_week

--Calculating Average Ride Length for Each User Type and Creating View to store data
create view avg_ride_length as
select member_casual as usser_type, avg(ride_length) as avg_ride_length
from all_data 
group by member_casual



--Creating temporary tables exclusively for Casual Users and Members
create table member_table(
ride_id nvarchar(50),
rideable_type nvarchar(50),
member_casual nvarchar(50),
ride_length int,
day_of_week nvarchar(50),
month_m nvarchar(50),
year_y int)


insert into member_table (ride_id, rideable_type, member_casual, ride_length, day_of_week, month_m, year_y)
(select ride_id, rideable_type, member_casual, ride_length, day_of_week, month_m, year_y
from all_data
where member_casual = 'member')



create table casual_table(
ride_id nvarchar(50),
rideable_type nvarchar(50),
member_casual nvarchar(50),
ride_length int,
day_of_week nvarchar(50),
month_m nvarchar(50),
year_y int)

insert into casual_table (ride_id, rideable_type, member_casual, ride_length, day_of_week, month_m, year_y)
(select ride_id, rideable_type, member_casual, ride_length, day_of_week, month_m, year_y
from all_data
where member_casual = 'casual')

select * from member_table

select * from casual_table


-- Calculating User Traffic Every Month Since Startup
select month_int as month_num,
month_m as month_name,
year_y,
count(case when member_casual = 'member' then 1 else null end) as num_of_member,
count(case when member_casual = 'casual' then 1 else null end) as num_of_casual,
count(member_casual) as total_no_of_users
from all_data
group by year_y, month_int, month_m
order by year_y, month_int, month_m


-- Calculating Daily Traffic Since Startup
select 
count(case when member_casual = 'member' then 1 else null end) as num_of_member,
count(case when member_casual = 'casual' then 1 else null end) as num_of_casual,
count(member_casual) as total_no_of_users,
date_yyyy_mm_dd as date_d
from all_data
group by date_yyyy_mm_dd 
order by date_yyyy_mm_dd  

select * from all_data


-- Calculating User Traffic Hour Wise
alter table all_data
add hour_of_day int

update all_data
set hour_of_day = datepart(hour, started_at)

select hour_of_day,
count(case when member_casual = 'member' then 1 else null end) as num_of_member,
count(case when member_casual = 'casual' then 1 else null end) as num_of_casual,
count(member_casual) as total_no_of_users
from all_data
group by hour_of_day
order by hour_of_day

--Calculating Most Popular Stations for Casual Users, (limiting results to top 20 station)
select top 20 start_station_name as station_name,
count(case when member_casual = 'casual' then 1 else null end) as num_of_casual
from all_data
where start_station_name is not null
group by start_station_name
order by num_of_casual desc

--Calculating Most Popular Stations for member Users, (limiting results to top 20 station)
select top 20 start_station_name as station_name,
count(case when member_casual = 'member' then 1 else null end) as num_of_member
from all_data
where start_station_name is not null
group by start_station_name
order by num_of_member desc