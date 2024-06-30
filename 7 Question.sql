CREATE TABLE users (
    USER_ID INT PRIMARY KEY,
    USER_NAME VARCHAR(20) NOT NULL,
    USER_STATUS VARCHAR(20) NOT NULL
);

CREATE TABLE logins (
    USER_ID INT,
    LOGIN_TIMESTAMP DATETIME NOT NULL,
    SESSION_ID INT PRIMARY KEY,
    SESSION_SCORE INT,
    FOREIGN KEY (USER_ID) REFERENCES USERS(USER_ID)
);

-- Users Table
INSERT INTO USERS VALUES (1, 'Alice', 'Active');
INSERT INTO USERS VALUES (2, 'Bob', 'Inactive');
INSERT INTO USERS VALUES (3, 'Charlie', 'Active');
INSERT INTO USERS  VALUES (4, 'David', 'Active');
INSERT INTO USERS  VALUES (5, 'Eve', 'Inactive');
INSERT INTO USERS  VALUES (6, 'Frank', 'Active');
INSERT INTO USERS  VALUES (7, 'Grace', 'Inactive');
INSERT INTO USERS  VALUES (8, 'Heidi', 'Active');
INSERT INTO USERS VALUES (9, 'Ivan', 'Inactive');
INSERT INTO USERS VALUES (10, 'Judy', 'Active');

-- Logins Table 

INSERT INTO LOGINS  VALUES (1, '2023-07-15 09:30:00', 1001, 85);
INSERT INTO LOGINS VALUES (2, '2023-07-22 10:00:00', 1002, 90);
INSERT INTO LOGINS VALUES (3, '2023-08-10 11:15:00', 1003, 75);
INSERT INTO LOGINS VALUES (4, '2023-08-20 14:00:00', 1004, 88);
INSERT INTO LOGINS  VALUES (5, '2023-09-05 16:45:00', 1005, 82);

INSERT INTO LOGINS  VALUES (6, '2023-10-12 08:30:00', 1006, 77);
INSERT INTO LOGINS  VALUES (7, '2023-11-18 09:00:00', 1007, 81);
INSERT INTO LOGINS VALUES (8, '2023-12-01 10:30:00', 1008, 84);
INSERT INTO LOGINS  VALUES (9, '2023-12-15 13:15:00', 1009, 79);


-- 2024 Q1
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (1, '2024-01-10 07:45:00', 1011, 86);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (2, '2024-01-25 09:30:00', 1012, 89);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (3, '2024-02-05 11:00:00', 1013, 78);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (4, '2024-03-01 14:30:00', 1014, 91);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (5, '2024-03-15 16:00:00', 1015, 83);

INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (6, '2024-04-12 08:00:00', 1016, 80);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (7, '2024-05-18 09:15:00', 1017, 82);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (8, '2024-05-28 10:45:00', 1018, 87);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (9, '2024-06-15 13:30:00', 1019, 76);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (10, '2024-06-25 15:00:00', 1010, 92);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (10, '2024-06-26 15:45:00', 1020, 93);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (10, '2024-06-27 15:00:00', 1021, 92);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (10, '2024-06-28 15:45:00', 1022, 93);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (1, '2024-01-10 07:45:00', 1101, 86);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (3, '2024-01-25 09:30:00', 1102, 89);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (5, '2024-01-15 11:00:00', 1103, 78);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (2, '2023-11-10 07:45:00', 1201, 82);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (4, '2023-11-25 09:30:00', 1202, 84);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (6, '2023-11-15 11:00:00', 1203, 80);

select * from logins
select * from users

--1 management wants to see all the users that did not login in the past 5 months

with cte as(
select u.[user_name],MAX(l.login_timestamp) AS max_login_timestamp
from Logins l
join users u
on l.user_id = u.user_id
group by u.[user_name]
)
select distinct user_name from cte where max_login_timestamp < dateadd(MONTH,-5,getdate())
--select dateadd(MONTH,-5,getdate())

--2nd solution

select USER_ID from logins
group by USER_ID
having MAX(login_timestamp) < DATEADD(MONTH,-5,GETDATE())

--3rd solution

select user_id from logins where user_id
not in(select user_id from logins where
login_timestamp > DATEADD(MONTH,-5,GETDATE())
)
group by user_id

--2 For the business units quarterly analysis, 
--calculate how many users and how many sessions were at each quarter
-- order by quarter from newest to oldest.
select * from logins
select * from users;

select count (distinct user_id) as user_CNT, count (*) as session
,DATEPART(quarter,login_timestamp) as qrtr
from logins
group by DATEPART(quarter,login_timestamp)
order by DATEPART(quarter,login_timestamp) desc


select count (distinct user_id) as user_CNT, count (*) as session
,DATETRUNC(quarter,MIN(LOGIN_TIMESTAMP)) as first_qrter_date
from logins
group by DATEPART(quarter,login_timestamp)
order by DATEPART(quarter,login_timestamp) desc

--3 Display user id's that log-in january'24 and did not log in Nov'23.
select distinct USER_ID
from logins
where format(LOGIN_TIMESTAMP,'MM-yyyy') =  '01-2024'
and user_id not in 
(select distinct USER_ID
from logins where
 format(LOGIN_TIMESTAMP,'MM-yyyy') =  '11-2023')

select format(GETDATE(),'MM-yyyy') = '06-2024'
SELECT 
    IIF(format(GETDATE(),'MM-yyyy') = '06-2024', 'True', 'False') as IsCurrentMonth

--4 Add to the query from Que. 2 the percentage change in sessions from last quarter.

WITH CTE as
(
select count (distinct user_id) as user_CNT, count (*) as session
,DATETRUNC(quarter,MIN(LOGIN_TIMESTAMP)) as first_qrter_date
from logins
group by DATEPART(quarter,login_timestamp)
--order by DATEPART(quarter,login_timestamp) desc
)
,cte2 as (select user_CNT, session,first_qrter_date,
LAG(SESSION,1,SESSION) over(order by first_qrter_date) as previous_session
from CTE)

select user_CNT, session,first_qrter_date,
cast((session - previous_session) *100.0/previous_session as decimal(10,2))  as session_perc_change 
from cte2

--5 Display the user that had the highest session score for each day.
with cte as(
select USER_ID,cast(LOGIN_TIMESTAMP as date) day,sum(session_score) score
from logins
group by USER_ID,cast(LOGIN_TIMESTAMP as date)
--order by day,score
)
select user_id,day, score as highest_score from
(
select *, 
ROW_NUMBER() over(partition by day order by score desc) as rn
from cte
)a where rn=1

--6 To identify our best users ,
-- Return the users that had a session on every single day since their first login

with cte as(
select User_id, cast(min(LOGIN_TIMESTAMP) as date)as first_login_day,
lag(cast(LOGIN_TIMESTAMP as date),1) over(order by user_id) as prev_login_day
from logins
group by USER_ID ,cast(LOGIN_TIMESTAMP as date)
)
select distinct user_id
from cte where DATEDIFF(day,first_login_day,prev_login_day) = -1


--2nd solution
-- NOTE --> For this solution , you should have enough data in your table to validate the result
select USER_ID, MIN(cast(LOGIN_TIMESTAMP as date)) as first_login
, DATEDIFF(day, MIN(cast(LOGIN_TIMESTAMP as date)), GETDATE())+1 as no_of_login_days_required
, COUNT(distinct cast(LOGIN_TIMESTAMP as date)) as no_of_login_days
from logins
group by user_id
having DATEDIFF(day, MIN(cast(LOGIN_TIMESTAMP as date)), GETDATE())+1=COUNT(distinct cast(LOGIN_TIMESTAMP as date))
order by user_id

--7 On what dates, there were no log-in at all.
-- Declare the date range
DECLARE @StartDate DATE = (SELECT MIN(CAST(LOGIN_TIMESTAMP AS DATE)) FROM logins);
DECLARE @EndDate DATE = (SELECT MAX(CAST(LOGIN_TIMESTAMP AS DATE)) FROM logins);

-- Generate a series of dates using a recursive CTE
WITH DateSeries AS 
(
    SELECT @StartDate AS DateValue
    UNION ALL
    SELECT DATEADD(day, 1, DateValue)
    FROM DateSeries
    WHERE DATEADD(day, 1, DateValue) <= @EndDate
),
LoginDates AS 
(
    SELECT DISTINCT CAST(LOGIN_TIMESTAMP AS DATE) AS LoginDate
    FROM logins
)

-- Find the dates with no logins
SELECT DateValue AS NoLoginDate
FROM DateSeries
LEFT JOIN LoginDates ON DateSeries.DateValue = LoginDates.LoginDate
WHERE LoginDates.LoginDate IS NULL
OPTION (MAXRECURSION 0);


--2nd solution
-- Generate a series of dates using a recursive CTE
WITH CTE AS 
(
    SELECT CAST(MIN(LOGIN_TIMESTAMP) AS DATE) AS first_date,CAST(MAX(LOGIN_TIMESTAMP) AS DATE)as last_date
	from logins
    UNION ALL
    SELECT DATEADD(day, 1, first_date) as first_date, last_date
	from CTE where first_date<last_date
)
SELECT first_date as No_Login_date from cte
WHERE first_date not in
(select distinct CAST(login_timestamp as date) from logins)
OPTION (MAXRECURSION 0);