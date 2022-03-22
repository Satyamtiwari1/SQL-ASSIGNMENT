Use sql_assignment;
CREATE TABLE Employee (
id int,
name VARCHAR(200),
department VARCHAR(200),
managerid int,
primary key(id)
);
INSERT into Employee(id,name,department,managerid)
VALUES (101,'John','A',NULL),
       (102,'Dan','A',101),
        (103,'James','A',101),
        (104,'Amy','A',101),
        (105,'Anne','A',101),
        (106,'Ron','B',101);
/*1. Write an SQL query to report the managers with at least five direct reports.
      Return the result table in any order */
Select name from Employee
Where id in (Select managerid as report from Employee 
                 group by managerid
                 having count(managerid)>=5);
/*   2. Write an SQL query to report the nth highest salary from the Employee table. If there is no
        nth highest salary, the query should report null.  */
create table employees(id int,salary int);
insert into employees values(1,100),(2,200),(3,300);         
DELIMITER //
Create procedure getNthHighestSalary(
IN nth int)
Begin
select salary from (SELECT DISTINCT Salary FROM Employees ORDER BY Salary DESC LIMIT 2)a
ORDER BY Salary ASC
limit 1;
End //
delimiter ;
drop procedure getNthHighestSalary;
 call getNthHighestSalary(2)

/*  3. Write an SQL query to find the people who have the most friends and the most friends
        number. */
Create table RequestAccepted 
                (requester_id int ,accepter_id int,accept_data date);
Insert into RequestAccepted (requester_id,accepter_id,accept_data)
								Value (1,2,'2016/06/03'),
								   (1,3,'2016/06/08'),
                                   (2,3,'2016/06/08'),
                                   (3,4,'2016/06/09');
Select requester_id, Count(*) as count from (Select requester_id from RequestAccepted
                                       union all
									Select accepter_id from RequestAccepted) A
                                    group by requester_id
                                    Order by count Desc
                                    Limit 1;
		        
--  4. Write an SQL query to swap the seat id of every two consecutive students. If the number of
-- students is odd, the id of the last student is not swapped.     
          
create table Seat(id int,student varchar(200),primary key(id));
insert into Seat values
(1,'Abbot'),
(2,'Doris'),
(3,'Emerson'),
(4,'Green'),
(5,'Jeames');

SELECT (CASE WHEN MOD(id,2)=1 AND id!=(SELECT COUNT(*) FROM seat) THEN id+1
			 WHEN MOD(id,2)=0 THEN id-1
             ELSE id END)id, student FROM seat
             ORDER BY id ASC;
/* 5. Write an SQL query to report the customer ids from the Customer table that bought all the
       products in the Product table. */
create table Customer 
        (customer_id int,product_key int);
Insert into Customer (customer_id,product_key)
             Values ( 1,5),
					(2,6),
                    (3,5),
                    (3,6),
                    (1,6);
Create table Product(product_key int,primary key(product_key));
insert into Product(product_key)
            Values (5),(6);
select customer_id from (Select customer_id,Count(Customer.product_key) as A from Customer
group by customer_id
having A in (Select count(product_key) from Product)) B;

/* 6. Write an SQL query to find for each user, the join date and the number of orders they made
       as a buyer in 2019.*/
create table Users(user_id int,join_date date,favorite_brand varchar(200),primary key(user_id));
create table Orders(order_id int,order_date date,item_id int,buyer_id int,seller_id int,primary key(order_id));
Insert into Users values (1,'2018-01-01','Lenovo'),
						  (2,'2018-02-09','Samsung'),
                          (3,'2018-01-19','LG'),
                          (4,'2018-05-21','HP');
Insert into Orders values(1,'2019-08-01',4,1,2),
						 (2,'2018-08-02',2,1,3),
                         (3,'2019-08-03',3,2,3),
                         (4,'2018-08-04',1,4,2),
                         (5,'2018-08-04',1,3,4),
                         (6,'2019-08-05',2,2,4);
select user_id,join_date,order_in_2019 from Users
left join (Select buyer_id,count(buyer_id) as order_in_2019 from Orders
where order_date>='2019-01-01'
group by buyer_id) A on A.buyer_id=user_id;
                         
-- 7. Write an SQL query to reports for every date within at most 90 days from today, the
-- number of users that logged in for the first time on that date. Assume today is 2019-06-30.
Create table traffic(user_id int,activity varchar(200),activity_date date); 
insert into traffic values 
(1,'login','2019-05-01'),
(1,'homepage','2019-05-01'),
(1,'logout','2019-05-01'),
(2,'login','2019-06-21'),
(2,'logout','2019-06-21'),
(3,'login','2019-01-01'),
(3,'jobs','2019-01-01'),
(3,'logout','2019-01-01'),
(4,'login','2019-06-21'),
(4,'groups','2019-06-21'),
(4,'logout','2019-06-21'),
(5,'login','2019-03-01'),
(5,'logout','2019-03-01'),
(5,'login','2019-06-21'),
(5,'logout','2019-06-21');

select activity_date,count(*) as user_count from (select * from traffic where activity='login' group by user_id) filtered
where activity_date>=('2019-06-03' - interval 90 day)
group by activity_date;

-- 8. Write an SQL query to find the prices of all products on 2019-08-16. Assume the price of all
-- products before any change is 10.
Create table Products(product_id int,new_price int,change_date date,primary key(product_id,change_date));
insert into products values
(1,20,'2019-08-14'),
(2,50,'2019-08-14'),
(1,30,'2019-08-15'),
(1,35,'2019-08-16'),
(2,65,'2019-08-17'),
(3,20,'2019-08-18');
select p1.product_id, p1.new_price as price
from Products p1
where p1.change_date <= '2019-08-16' and
    (product_id, datediff('2019-08-16', p1.change_date)) in
    (select product_id, min(datediff('2019-08-16', change_date))
    from Products
    where change_date <= '2019-08-16'
    group by product_id)

union

select product_id, 10 as price
from Products
group by product_id
having min(change_date) > '2019-08-16'
order by price desc;

-- 9. Write an SQL query to find for each month and country: the number of approved
-- transactions and their total amount, the number of chargebacks, and their total amount
create table Transactions(id int,country varchar(200),state varchar(200),amount int,trans_date date,primary key(id));
create table Chargebacks(trans_id int,trans_date date);
insert into Transactions values
(101,'US','approved',1000,'2019-05-18'),
(102,'US','declined',2000,'2019-05-19'),
(103,'US','approved',3000,'2019-06-10'),
(104,'US','declined','4000','2019-06-13'),
(105,'US','approved',5000,'2019-06-15');
insert into Chargebacks values
(102,'2019-05-29'),
(101,'2019-06-30'),
(105,'2019-09-18');
Select A1.date as month,A1.country,approved_count,approved_amount,chargeback_count,chargeback_amount from
(SELECT DATE_FORMAT(trans_date,'%Y-%m') AS date,country,count(*) as Approved_count,sum(amount) as approved_amount FROM Transactions
where state='approved'
group by date)A1
left join
(SELECT DATE_FORMAT(Chargebacks.trans_date,'%Y-%m') AS date,country,count(*) as chargeback_count,amount as chargeback_amount from Chargebacks
left join Transactions on Transactions.id=trans_id
group by date) B1 on B1.date=A1.date
union 
Select B1.date as month,B1.country,approved_count,approved_amount,chargeback_count,chargeback_amount from
(SELECT DATE_FORMAT(trans_date,'%Y-%m') AS date,country,count(*) as Approved_count,sum(amount) as approved_amount FROM Transactions
where state='approved'
group by date)A1
right join
(SELECT DATE_FORMAT(Chargebacks.trans_date,'%Y-%m') AS date,country,count(*) as chargeback_count,amount as chargeback_amount from Chargebacks
left join Transactions on Transactions.id=trans_id
group by date) B1 on B1.date=A1.date;


-- 10. Write an SQL query that selects the team_id, team_name and num_points of each team in
-- the tournament after all described matches.

Create table Teams(team_id int,team_name varchar(200),primary key(team_id));
create table Matches(match_id int,host_team int,guest_team int,host_goals int,guest_goals int,primary key(match_id));
insert into Teams values
(10,'Leetcode FC'),
(20,'NewYork FC'),
(30,'Atlanta FC'),
(40,'Chicago FC'),
(50,'Toronto FC');
insert into Matches values
(1,10,20,3,0),
(2,30,10,2,2),
(3,10,50,5,1),
(4,20,30,1,0),
(5,50,30,1,0);
select t.team_id, t.team_name,
    ifnull(sum(case when t.team_id = m.host_team and m.host_goals > m.guest_goals then 3
    when t.team_id = m.host_team and m.host_goals = m.guest_goals then 1
    when t.team_id = m.guest_team and m.host_goals < m.guest_goals then 3
    when t.team_id = m.guest_team and m.host_goals = m.guest_goals then 1
    else 0 end), 0) as num_points
from Matches m
right join Teams t
on m.host_team = t.team_id or m.guest_team = t.team_id
group by team_id, team_name
order by num_points desc, team_id;