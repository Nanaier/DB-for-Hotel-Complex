DROP DATABASE IF EXISTS hotel_complex;
CREATE DATABASE hotel_complex;
USE hotel_complex;

DROP TABLE IF EXISTS Hotel;
DROP TABLE IF EXISTS Room_type;
DROP TABLE IF EXISTS Room;  
DROP TABLE IF EXISTS Customer;
DROP TABLE IF EXISTS Booking;
DROP TABLE IF EXISTS Discount;
DROP TABLE IF EXISTS Booking_discount;
DROP TABLE IF EXISTS Check_in;
DROP TABLE IF EXISTS Check_out;
DROP TABLE IF EXISTS Employee;
DROP TABLE IF EXISTS Type_of_employee;

CREATE TABLE Hotel(
	hotel_id INT AUTO_INCREMENT PRIMARY KEY,
	location VARCHAR(50) NOT NULL,
    hotel_name VARCHAR(20) NOT NULL,
    capacity INT NOT NULL
);

CREATE TABLE Room_type(
	room_type_id INT AUTO_INCREMENT PRIMARY KEY,
    room_name VARCHAR(20) NOT NULL,
    bedroom_amount INT NOT NULL,
    price_for_day INT NOT NULL
);

CREATE TABLE Type_of_employee(
	type_of_employee_id INT AUTO_INCREMENT PRIMARY KEY,
    position_name VARCHAR(20) NOT NULL,
    wage INT NOT NULL
);

CREATE TABLE Employee(
	employee_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    passport_number INT NOT NULL,
    passport_series VARCHAR(20) NOT NULL,
    age INT NOT NULL,
    gender VARCHAR(10) NOT NULL,
    type_of_employee_id INT NOT NULL,
    working_hours_month INT NOT NULL,
    FOREIGN KEY(type_of_employee_id) REFERENCES Type_of_employee(type_of_employee_id) ON DELETE CASCADE
);


CREATE TABLE Room(
	room_id INT AUTO_INCREMENT PRIMARY KEY,
    room_type_id INT NOT NULL,
    room_number INT NOT NULL,
	hotel_id INT NOT NULL,
    housekeeper_id INT NOT NULL,
    FOREIGN KEY(housekeeper_id) REFERENCES Employee(employee_id) ON DELETE CASCADE,
	FOREIGN KEY(hotel_id) REFERENCES Hotel(hotel_id) ON DELETE CASCADE,
    FOREIGN KEY(room_type_id) REFERENCES Room_type(room_type_id) ON DELETE CASCADE
);

CREATE TABLE Customer(
	customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    additional_info VARCHAR(50) NOT NULL,
    passport_number INT NOT NULL,
    passport_series VARCHAR(20) NOT NULL,
    age INT NOT NULL,
    gender VARCHAR(11) NOT NULL
);

CREATE TABLE Check_in(
	check_in_id INT AUTO_INCREMENT PRIMARY KEY,
    check_in_date DATE NOT NULL,
    check_out_date DATE NOT NULL,
    manager_id INT NOT NULL,
	FOREIGN KEY(manager_id) REFERENCES Employee(employee_id) ON DELETE CASCADE
);

CREATE TABLE Check_out(
	check_out_id INT AUTO_INCREMENT PRIMARY KEY,
    check_out_date DATE ,
    manager_id INT ,
    FOREIGN KEY(manager_id) REFERENCES Employee(employee_id) ON DELETE CASCADE
);
CREATE TABLE Booking(
	booking_id INT AUTO_INCREMENT PRIMARY KEY,
    room_id INT NOT NULL,
    customer_id INT NOT NULL,
    checkin_date INT NOT NULL,
    checkout_date INT NOT NULL,
    duration INT,
    FOREIGN KEY(room_id) REFERENCES Room(room_id) ON DELETE CASCADE,
    FOREIGN KEY(customer_id) REFERENCES Customer(customer_id) ON DELETE CASCADE,
    FOREIGN KEY(checkin_date) REFERENCES Check_in(check_in_id) ON DELETE CASCADE,
    FOREIGN KEY(checkout_date) REFERENCES Check_out(check_out_id) ON DELETE CASCADE   
);

CREATE TABLE Discount(
	discount_id INT AUTO_INCREMENT PRIMARY KEY,
    percent_amount INT NOT NULL,
    reason_for VARCHAR(50) NOT NULL
);

CREATE TABLE Booking_discount(
	booking_discount_id INT AUTO_INCREMENT PRIMARY KEY,
    discount_id INT NOT NULL,
    booking_id INT NOT NULL,
    FOREIGN KEY(booking_id) REFERENCES Booking(booking_id) ON DELETE CASCADE,
    FOREIGN KEY(discount_id) REFERENCES Discount(discount_id) ON DELETE CASCADE
);

ALTER TABLE Customer
ADD CONSTRAINT CheckAge CHECK(age >= 18);

ALTER TABLE Employee
ADD CONSTRAINT CheckAgeEmpl CHECK(age >= 18);

-- ALTER TABLE Customer
-- ADD CONSTRAINT CheckGenderCust CHECK(gender IN('Female', 'Male', 'Non-binary'));

ALTER TABLE Employee
ADD CONSTRAINT CheckGenderEmpl CHECK(gender IN('Female', 'Male', 'Non-binary'));

ALTER TABLE Room_type
ADD CONSTRAINT CheckRoom_type CHECK(room_name IN('Normal', 'Half-Luxe', 'Luxe'));

ALTER TABLE Room_type
ADD CONSTRAINT CheckBedroom_amount CHECK(bedroom_amount IN(1, 2, 3, 4));

ALTER TABLE Check_in
ADD CONSTRAINT Date_check CHECK(check_in_date < check_out_date);

ALTER TABLE Type_of_employee
ADD CONSTRAINT Wage_check CHECK(wage >= 10);

ALTER TABLE Type_of_employee
ADD CONSTRAINT Type_of_employee_check CHECK(position_name IN('manager', 'housekeeper', 'porter', 'driver'));

select * from booking;

select * from check_in;

UPDATE booking b
INNER JOIN check_in c on b.checkin_date = c.check_in_id
SET duration = DATEDIFF(c.check_out_date, c.check_in_date) WHERE (b.booking_id > 0);



COMMIT;



