use hotel_complex;

DROP TRIGGER IF EXISTS check_room_availability;
DELIMITER $$

CREATE TRIGGER check_room_availability BEFORE INSERT ON Booking
FOR EACH ROW
BEGIN
  DECLARE room_id INT;
  DECLARE checkin_date DATE;
  DECLARE checkout_date DATE;
  
  SET room_id = NEW.room_id;
  SET checkin_date = (SELECT ci.check_in_date FROM Check_in ci WHERE ci.check_in_id = NEW.checkin_date);
  SET checkout_date = (SELECT ci.check_out_date FROM Check_in ci WHERE ci.check_in_id = NEW.checkin_date);
  -- SET checkout_date = (SELECT ci.check_out_date FROM Check_in ci WHERE ci.check_out_id = NEW.checkout_date);
  
  IF EXISTS (SELECT 1 FROM Booking b
             INNER JOIN Check_in ci ON b.checkin_date = ci.check_in_id
             INNER JOIN Check_out co ON b.checkout_date = co.check_out_id
             WHERE b.room_id = room_id
             AND (ci.check_in_date BETWEEN checkin_date AND checkout_date
                  OR ci.check_out_date BETWEEN checkin_date AND checkout_date)) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The room is not available for the requested dates.';
  END IF;
END$$

DELIMITER ;

INSERT INTO Check_in(check_in_date, check_out_date, manager_id)
VALUES("2022-02-07","2022-02-13",6);

INSERT INTO Check_out(check_out_date, manager_id)
VALUES("2022-02-13",6);

INSERT INTO Booking(room_id, customer_id, checkin_date, checkout_date,duration)
VALUES(2, 8, 17, 17, 0);

SELECT * FROM check_in;
SELECT * FROM CHECK_oUT;
SELECT * FROM booking;

DROP TRIGGER IF EXISTS check_customer_exists;

DELIMITER $$

CREATE TRIGGER check_customer_exists BEFORE INSERT ON Customer
FOR EACH ROW
BEGIN
  DECLARE passport_series VARCHAR(20);
  DECLARE passport_number INT;
  
  SET passport_series = NEW.passport_series;
  SET passport_number = NEW.passport_number;
  
  IF EXISTS (SELECT 1 FROM Customer WHERE passport_series = passport_series AND passport_number = passport_number) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A customer with the same passport series and passport number already exists.';
  END IF;
END$$

DELIMITER ;

INSERT INTO Customer (first_name, last_name, additional_info, passport_number, passport_series, age, gender)
VALUES ("Anastasiia", "Lysenko", "no info", 302540323, '19gpza5424', 23, 'Female');

SELECT * FROM customer;




DROP TABLE IF EXISTS Customer_Modification_Log;
CREATE TABLE Customer_Modification_Log (
  log_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  customer_id INT NOT NULL,
  modified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  old_first_name VARCHAR(50) NOT NULL,
  old_last_name VARCHAR(50) NOT NULL,
  old_additional_info VARCHAR(50) NOT NULL,
  old_passport_number INT NOT NULL,
  old_passport_series VARCHAR(20) NOT NULL,
  old_age INT NOT NULL,
  old_gender VARCHAR(10) NOT NULL
);

DROP TRIGGER IF EXISTS customer_modification_log;
DELIMITER //
CREATE TRIGGER customer_modification_log
AFTER UPDATE ON Customer
FOR EACH ROW
BEGIN
  INSERT INTO Customer_Modification_Log (customer_id, modified_at, old_first_name, old_last_name, old_additional_info, old_passport_number, old_passport_series, old_age, old_gender)
  VALUES (OLD.customer_id, CURRENT_TIMESTAMP, OLD.first_name, OLD.last_name, OLD.additional_info, OLD.passport_number, OLD.passport_series, OLD.age, OLD.gender);
END //
DELIMITER ;
select * from customer;
update customer set first_name = "Anastasiia" where customer_id = 50;
select * from Customer_Modification_Log;



DROP TRIGGER IF EXISTS check_checkout_date;
DELIMITER $$

CREATE TRIGGER check_checkout_date BEFORE UPDATE ON Check_out
FOR EACH ROW
BEGIN
  DECLARE check_in_id INT;
  DECLARE check_in_date DATE;
  
  SET check_in_id = NEW.check_out_id;
  
  SELECT ci.check_in_date INTO check_in_date
  FROM Check_in ci
  WHERE ci.check_in_id = check_in_id;
  
  IF NEW.check_out_date < check_in_date THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The check-out date must be later than the check-in date.';
  END IF;
END$$

DELIMITER ;

UPDATE Check_out
SET check_out_date = "2022-02-06"
WHERE check_out_id = 16;

SELECT * FROM check_in;

DROP TRIGGER IF EXISTS prevent_hotel_deletion;
DELIMITER $$

CREATE TRIGGER prevent_hotel_deletion
BEFORE DELETE ON Hotel
FOR EACH ROW
BEGIN
  DECLARE hotel_id INT;
  DECLARE room_count INT;
  
  SET hotel_id = OLD.hotel_id;
  
  SELECT COUNT(*) INTO room_count
  FROM Room
  WHERE Room.hotel_id = hotel_id;
  
  IF room_count > 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Deleting a hotel with rooms is not allowed.';
  END IF;
END$$

DELIMITER ;


DELETE FROM Hotel
WHERE hotel_id = 1;

DELETE FROM Check_out
WHERE check_out_id > 16;

