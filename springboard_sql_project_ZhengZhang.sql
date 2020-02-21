/*Zheng Zhang
Springboard SQL mini project
February 20, 2020*/

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
SELECT name AS Facility_Charge_Fee_To_Member
  FROM country_club.Facilities
 WHERE membercost>0

/* Q2: How many facilities do not charge a fee to members? */
SELECT COUNT(name) AS Number_Of_Facility_No_Fee_To_Member
  FROM country_club.Facilities
 WHERE membercost=0

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */
SELECT facid AS Facility_ID, 
       name AS Facility_Name, 
       membercost AS Member_Cost, 
       monthlymaintenance AS Monthly_Maintenance
  FROM country_club.Facilities
 WHERE membercost< 0.2*monthlymaintenance

/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */
SELECT *
  FROM country_club.Facilities
 WHERE facid IN (1,5)

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */
SELECT name AS Facility_Name, 
       monthlymaintenance AS Monthly_Maintenance,
       CASE WHEN monthlymaintenance > 100 THEN 'expensive'
            ELSE 'cheap' END AS Cost_Category
  FROM country_club.Facilities
 ORDER BY 2,3,1

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */
SELECT firstname AS Last_Member_First_Name, 
       surname AS Last_Member_Last_Name 
  FROM country_club.Members
 WHERE joindate=(SELECT max(joindate)
                   FROM country_club.Members
                )

/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */
SELECT DISTINCT f.name AS Tennis_Court_Name,
                CONCAT(m.surname, ',',m.firstname) AS Member_Name        
  FROM country_club.Members m
  JOIN country_club.Bookings b 
    ON m.memid=b.memid AND b.facid IN (0,1)
  JOIN country_club.Facilities f
    ON b.facid=f.facid
 ORDER BY 1, 2
 
/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */
SELECT b.bookid AS Booking_ID, 
       f.name AS Facility_Name, 
       CONCAT(m.surname, ',',m.firstname) AS Member_Name, 
       CASE WHEN m.memid!=0 THEN b.slots*f.membercost
            ELSE b.slots*f.guestcost END AS Cost
  FROM country_club.Members m
  JOIN country_club.Bookings b 
    ON m.memid=b.memid AND b.starttime LIKE '2012-09-04%'
  JOIN country_club.Facilities f
    ON b.facid=f.facid
HAVING Cost>30
 ORDER BY 4 DESC, 1
 
/* Q9: This time, produce the same result as in Q8, but using a subquery. */
SELECT sub.bookid AS Booking_ID, 
       sub.name AS Facility_Name, 
       CONCAT(m.surname, ',',m.firstname) AS Member_Name, 
       CASE WHEN m.memid!=0 THEN sub.slots*sub.membercost
            ELSE sub.slots*sub.guestcost END AS Cost
 FROM country_club.Members m
 JOIN (
       SELECT b.memid, 
              b.bookid,
              f.name, 
              b.slots, 
              f.membercost, 
              f.guestcost
         FROM country_club.Bookings b 
         JOIN country_club.Facilities f
           ON b.facid=f.facid AND b.starttime LIKE '2012-09-04%'
      ) sub
   ON m.memid=sub.memid
HAVING Cost>30
 ORDER BY 4 DESC, 1
 
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */
SELECT f.name AS Facility_Name, 
       SUM(CASE WHEN m.memid=0 THEN b.slots*f.guestcost
                ELSE b.slots*f.membercost END) AS Total_Revenue
  FROM country_club.Members m
  JOIN country_club.Bookings b 
    ON m.memid=b.memid 
  JOIN country_club.Facilities f
    ON b.facid=f.facid
 GROUP BY 1
HAVING Total_Revenue<1000
 ORDER BY 2
            
