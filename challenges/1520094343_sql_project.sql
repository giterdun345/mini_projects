/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

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
Please list the names of the facilities that do. */

/*--Tennis Court 1
  --Tennis Court 2
  --Massage Room 1
  --Massage Room 2
  --Squash Court*/

SELECT `name`, `membercost` 
    FROM `Facilities` 
WHERE membercost > 0.00


/* Q2: How many facilities do not charge a fee to members? */

/* 4 facilities do not charge fees to members */

SELECT COUNT(`membercost`) AS `facilities_no_cost`
    FROM `Facilities` 
WHERE membercost = 0.00

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT  `facid`, 
	`name`, 
	`membercost`,
	`monthlymaintenance`
    FROM `Facilities` 
WHERE membercost > 0.00 AND `monthlymaintenance` * 0.2 >`membercost`

/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */

SELECT *
    FROM `Facilities` 
WHERE `name` LIKE '%2'

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */

SELECT `name`, 
       `monthlymaintenance`, 
       CASE 
         WHEN `monthlymaintenance` > 100 THEN 'expensive' 
         ELSE 'cheap' 
    	 END AS `labeled` 
FROM   `facilities`  

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */

SELECT `firstname`, 
       `surname`, 
       MAX(`joindate`) AS `latest`
FROM `Members`
    GROUP BY `firstname`, 
	     `surname`
    ORDER BY `latest` DESC

/* another example of Q6:*/

SELECT `firstname`, 
	`surname`
	`joindate`
FROM `Members`
WHERE 	`joindate` = (SELECT MAX(`joindate`) FROM `Members`)

/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT DISTINCT CONCAT(Members.firstname, "", Members.surname) 
		AS names, 
                Facilities.name 
FROM   Members 
       INNER JOIN Bookings 
               ON Members.memid = Bookings.memid 
       JOIN Facilities 
         ON Bookings.facid = Facilities.facid 
WHERE  Bookings.facid = 0 
        OR Bookings.facid = 1 
ORDER  BY names 
LIMIT 0, 46

/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT DISTINCT CONCAT(mem.firstname, " ", mem.surname) AS names, 
    fac.name,

    CASE WHEN bk.starttime > '2012-09-14 07:00:00' 
		AND bk.starttime < '2012-09-14 24:00:00' 
		AND  mem.memid = 0 THEN bk.slots * fac.guestcost  
         WHEN bk.starttime > '2012-09-14 07:00:00' 
		AND bk.starttime < '2012-09-14 24:00:00' 
		AND  mem.memid <> 0 THEN bk.slots * fac.membercost
      	 END AS Cost
      								
FROM Bookings AS bk
JOIN Facilities AS fac
  ON bk.facid = fac.facid
JOIN Members AS mem
  ON mem.memid = bk.memid

ORDER BY Cost DESC
LIMIT 0, 257
        
/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT * 
FROM   (
	SELECT DISTINCT CONCAT(mem.firstname, "", mem.surname) AS names, 
               fac.name, 
               CASE 
                   WHEN mem.memid = 0 THEN bk.slots * fac.guestcost 
                   WHEN mem.memid <> 0 THEN bk.slots * fac.membercost 
                   END AS Cost 
        FROM   Bookings AS bk 
               JOIN Facilities AS fac 
                 ON bk.facid = fac.facid 
               JOIN Members AS mem 
                 ON mem.memid = bk.memid 
        WHERE  bk.starttime LIKE '2012-09-14%' 
        ORDER  BY cost 
        LIMIT  0, 46
	) AS new 
WHERE  new.cost > 30 

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

SELECT  fac.name, 
	SUM(CASE 
        WHEN mem.memid = 0 THEN bk.slots * fac.guestcost 
        WHEN mem.memid <> 0 THEN bk.slots * fac.membercost 
        END) AS Cost

FROM Members AS mem

JOIN Bookings AS bk
	ON bk.memid = mem.memid
JOIN Facilities AS fac
	ON fac.facid = bk.facid
GROUP BY fac.name
LIMIT 0, 4042
