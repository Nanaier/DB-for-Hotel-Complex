use hotel_complex;
select * from type_of_employee;
select * from check_in;
select * from check_out;
select * from booking;
select * from HOTEL;
select * from customer;



INSERT INTO Check_in(check_in_date, check_out_date, manager_id) VALUES("2023-01-07", "2023-01-21", 29);
INSERT INTO Check_out(check_out_date, manager_id) VALUES(null, null);
INSERT INTO Booking(room_id, customer_id, checkin_date, checkout_date, duration) VALUES(1, 27, 16, 16, 0);
-- 1
SELECT c.first_name, c.last_name, ci.check_in_date, ci.check_out_date, b.duration, r.room_number, rt.room_name
FROM Customer c
INNER JOIN Booking b ON c.customer_id = b.customer_id
INNER JOIN Check_in ci ON b.checkin_date = ci.check_in_id
INNER JOIN Room r ON b.room_id = r.room_id
INNER JOIN Room_type rt ON r.room_type_id = rt.room_type_id
ORDER BY r.room_number;

-- 2
SELECT c.first_name, c.last_name, c.passport_number, c.passport_series
FROM Customer c
INNER JOIN Booking b ON c.customer_id = b.customer_id
INNER JOIN Room r ON b.room_id = r.room_id
INNER JOIN Room_type rt ON r.room_type_id = rt.room_type_id
WHERE rt.room_name = 'Luxe' AND b.duration >= 7
ORDER BY b.duration ASC;

-- 3
SELECT b.room_id, c.first_name, c.last_name, d.percent_amount, d.reason_for
FROM booking_discount bd
INNER JOIN Discount d ON bd.discount_id = d.discount_id
INNER JOIN booking b ON bd.booking_id = b.booking_id
INNER JOIN customer c ON b.customer_id = c.customer_id
ORDER BY d.percent_amount;

-- 4
SELECT COUNT(c.customer_id) AS amount_discounts, d.percent_amount, d.reason_for
FROM booking_discount bd
INNER JOIN Discount d ON bd.discount_id = d.discount_id
INNER JOIN booking b ON bd.booking_id = b.booking_id
INNER JOIN customer c ON b.customer_id = c.customer_id
GROUP BY d.reason_for;

-- 5
SELECT AVG(b.duration) AS average_duration, rt.room_name
FROM Booking b
INNER JOIN Check_in ci ON b.checkin_date = ci.check_in_id
INNER JOIN Room r ON b.room_id = r.room_id
INNER JOIN Room_type rt ON r.room_type_id = rt.room_type_id
GROUP BY rt.room_name;

-- 6
SELECT MAX(b.duration) AS maximum_duration, rt.room_name
FROM Booking b
INNER JOIN Check_in ci ON b.checkin_date = ci.check_in_id
INNER JOIN Room r ON b.room_id = r.room_id
INNER JOIN Room_type rt ON r.room_type_id = rt.room_type_id
GROUP BY rt.room_name
ORDER BY maximum_duration ASC;

-- 7
SELECT SUM(b.duration) AS complete_duration, MONTH(ci.check_in_date) AS Current_month
FROM Booking b
INNER JOIN Check_in ci ON b.checkin_date = ci.check_in_id
INNER JOIN Room r ON b.room_id = r.room_id
INNER JOIN Room_type rt ON r.room_type_id = rt.room_type_id
GROUP BY Current_month
ORDER BY Current_month asc;

-- 8
SELECT r.room_number, rt.room_name, rt.bedroom_amount
FROM Room r
INNER JOIN Room_type rt ON r.room_type_id = rt.room_type_id
ORDER BY r.room_number ASC;

-- 9
SELECT r.room_number, e.first_name, e.last_name, e.age
FROM Room r
INNER JOIN Employee e ON r.housekeeper_id = e.employee_id
ORDER BY e.first_name ASC;

-- 10
SELECT COUNT(e.employee_id) AS number_of_employees, tof.position_name
FROM Employee e
INNER JOIN Type_of_employee tof ON tof.type_of_employee_id = e.type_of_employee_id
GROUP BY tof.position_name;

-- 11
SELECT SUM(e.working_hours_month * tof.wage) AS total_salary
FROM Employee e
INNER JOIN Type_of_employee tof ON tof.type_of_employee_id = e.type_of_employee_id;

-- 12
SELECT SUM(e.working_hours_month * tof.wage) AS total_salary_for_position, tof.position_name
FROM Employee e
INNER JOIN Type_of_employee tof ON tof.type_of_employee_id = e.type_of_employee_id
GROUP BY tof.position_name;

-- 13 
SELECT SUM(ISNULL(co.check_out_date)) AS amount_of_people_in, rt.room_name
FROM Booking b 
INNER JOIN Check_out co ON b.checkout_date = co.check_out_id
INNER JOIN Room r ON b.room_id = r.room_id
INNER JOIN Room_type rt ON r.room_type_id = rt.room_type_id
GROUP BY rt.room_name;

-- 14
SELECT e.first_name, e.last_name, COUNT(DAYOFWEEK(ci.check_in_date)) AS amount_of_days_checked_in_on_weekends
FROM Check_in ci
INNER JOIN Employee e ON e.employee_id = ci.manager_id
WHERE DAYOFWEEK(ci.check_in_date) in (1, 7)
GROUP BY e.last_name;


select * from employee where type_of_employee_id = 1;

-- 15
SELECT SUM(e.working_hours_month ) AS total_working_hours, tof.position_name
FROM Employee e
INNER JOIN Type_of_employee tof ON tof.type_of_employee_id = e.type_of_employee_id
GROUP BY tof.position_name;

-- 16
SELECT b.booking_id, c.first_name, c.last_name, IF(ci.check_out_date < co.check_out_date, "overstayed", "understayed") AS checked_out_in_the_specified_time
FROM Booking b
INNER JOIN Customer c ON b.customer_id = c.customer_id
INNER JOIN Check_in ci ON b.checkin_date = ci.check_in_id
INNER JOIN Check_out co ON b.checkout_date = co.check_out_id
WHERE ci.check_out_date != co.check_out_date;

-- 17
SELECT COUNT(b.booking_id) AS amount_of_times, IF(ci.check_out_date < co.check_out_date, "overstayed", "understayed") AS checked_out_in_the_specified_time
FROM Booking b
INNER JOIN Customer c ON b.customer_id = c.customer_id
INNER JOIN Check_in ci ON b.checkin_date = ci.check_in_id
INNER JOIN Check_out co ON b.checkout_date = co.check_out_id
WHERE ci.check_out_date != co.check_out_date
GROUP BY IF(ci.check_out_date < co.check_out_date, "overstayed", "understayed");

-- 18
SELECT b.booking_id, c.first_name, c.last_name, c.passport_number, 
IF(ISNULL(co.check_out_date) = 0, (DATEDIFF(co.check_out_date, ci.check_in_date) * rt.price_for_day), (b.duration * rt.price_for_day)) AS predicted_price
FROM booking b
INNER JOIN customer c ON b.customer_id = c.customer_id
INNER JOIN Room r ON b.room_id = r.room_id
INNER JOIN Room_type rt ON r.room_type_id = rt.room_type_id
INNER JOIN Check_in ci ON b.checkin_date = ci.check_in_id
INNER JOIN Check_out co ON b.checkout_date = co.check_out_id
ORDER BY b.booking_id ASC;

-- 19
CREATE OR REPLACE VIEW employee_view AS
	SELECT e.first_name, e.last_name, e.passport_number, e.passport_series, e.age, e.gender, e.working_hours_month, tof.wage, tof.position_name, (tof.wage * e.working_hours_month) AS salary
	FROM Employee e
	INNER JOIN Type_of_employee tof ON tof.type_of_employee_id = e.type_of_employee_id
    ORDER BY salary ASC;

SELECT * FROM employee_view;

-- 20
CREATE OR REPLACE VIEW customer_modification AS
	SELECT CONCAT(cm.old_first_name, "/", c.first_name) AS OLD_NAME__NEW_NAME, CONCAT(cm.old_last_name,"/", c.last_name) AS OLD_SURNAME__NEW_SURNAME,
    CONCAT(cm.old_passport_number, "/", c.passport_number) AS OLD_NUMBER__NEW_NUMBER, CONCAT(cm.old_passport_series, "/", c.passport_series) AS OLD_SERIES__NEW_SERIES,
    CONCAT(cm.old_age, "/", c.age) AS OLD_AGE__NEW_AGE, CONCAT(cm.old_gender, "/", c.gender) AS OLD_GENDER__NEW_GENDER
    FROM Customer_modification_log cm
    INNER JOIN Customer c ON c.customer_id = cm.customer_id;
    
SELECT * FROM customer_modification;

SELECT customer_id, last_name
FROM customer
WHERE first_name = 'Clifford';

DROP INDEX first_name ON Customer;
CREATE INDEX first_name ON customer(first_name);
