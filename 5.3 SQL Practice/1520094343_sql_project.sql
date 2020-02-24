/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://******/
Username: ******
Password: *********

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. (written code where facilities do charge members.*/
SELECT * 
FROM Facilities
WHERE membercost !=0
LIMIT 0 , 30

/* Q2: How many facilities do not charge a fee to members? */
SELECT count(*) 
FROM Facilities
WHERE membercost =0
LIMIT 0 , 30

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid, name, membercost, monthlymaintenance
FROM Facilities
WHERE MEMBERCOST !=0
AND MEMBERCOST < ( monthlymaintenance * 0.2 ) 
LIMIT 0 , 30

SELECT facid, name, membercost, monthlymaintenance
FROM Facilities
WHERE MEMBERCOST !=0
AND MEMBERCOST < ( monthlymaintenance * 0.2 ) 
LIMIT 0 , 30

/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */

SELECT * 
FROM Facilities
WHERE facid IN (1, 5)

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */

SELECT name, 
	   monthlymaintenance, 
       CASE WHEN monthlymaintenance < 100 THEN 'cheap'
			WHEN monthlymaintenance > 100 THEN 'expensive' END AS	cost_category
FROM Facilities

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */

SELECT FIRSTNAME, SURNAME FROM Members
where joindate = (select max(joindate) from Members)

/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT DISTINCT CONCAT( joined.firstname,  ' ', joined.surname ) AS full_name, joined.fac_name

FROM (
SELECT b.bookid, f.facid, f.name AS fac_name, m.memid, m.firstname, m.surname
FROM Bookings b
LEFT JOIN Facilities f ON b.facid = f.facid
LEFT JOIN Members m ON m.memid = b.memid
WHERE m.memid !=0
) AS joined
WHERE joined.fac_name LIKE "Tennis%" 
ORDER BY 1

/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT f.name as facility_name, CONCAT(m.firstname, ' ', m.surname) as full_name, 
	   CASE WHEN b.memid = 0 THEN f.guestcost * slots 
			WHEN b.memid != 0 THEN f.membercost * slots END as total_cost
			
FROM Bookings b
LEFT JOIN Facilities f
ON b.facid = f.facid
LEFT JOIN Members m
ON b.memid = m.memid 
WHERE LEFT(b.starttime, 10) = '2012-09-14' AND 
	  CASE WHEN b.memid = 0 THEN f.guestcost * slots 
		   WHEN b.memid != 0 THEN f.membercost * slots END > 30
ORDER BY total_cost DESC

/* Q9: This time, produce the same result as in Q8, but using a subquery. */


SELECT fac_name, full_name, total_cost
	    
FROM (
SELECT f.name AS fac_name,
	   CONCAT(m.firstname, ' ', m.surname) as full_name,
       CASE WHEN b.memid = 0 THEN f.guestcost * b.slots  
            WHEN b.memid != 0 THEN f.membercost * b.slots END as total_cost 
FROM Bookings b
LEFT JOIN Facilities f ON b.facid = f.facid
LEFT JOIN Members m ON m.memid = b.memid
WHERE LEFT(b.starttime, 10) = '2012-09-14'
) AS joined
WHERE total_cost > 30
ORDER BY 3 DESC

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

SELECT fac_name, SUM(total_cost) as revenue
	    
FROM (
SELECT f.name AS fac_name,
       CASE WHEN b.memid = 0 THEN f.guestcost * b.slots  
            WHEN b.memid != 0 THEN f.membercost * b.slots END as total_cost 
FROM Bookings b
LEFT JOIN Facilities f ON b.facid = f.facid
LEFT JOIN Members m ON m.memid = b.memid
) AS joined
GROUP BY fac_name
HAVING revenue < 1000 
ORDER BY revenue DESC
