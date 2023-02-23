use hotel_complex;

DROP FUNCTION IF EXISTS calculateTotalCost;
DELIMITER $$
CREATE FUNCTION calculateTotalCost(
    roomTypeId INT,
    duration INT,
    discountAmount INT
) RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE totalCost DECIMAL(10,2);
    SELECT price_for_day * duration INTO totalCost FROM Room_type WHERE room_type_id = roomTypeId;
    SET totalCost = totalCost - (totalCost * (discountAmount / 100));
    RETURN totalCost;
END$$

DELIMITER ;

SELECT calculateTotalCost(1, 10, 20);

DROP PROCEDURE IF EXISTS getCustomerBookings;
DELIMITER $$
CREATE PROCEDURE getCustomerBookings(IN customerId INT)
BEGIN
  SELECT * FROM Booking WHERE customer_id = customerId;
END$$

DELIMITER ;

CALL getCustomerBookings(12); 

DROP PROCEDURE IF EXISTS getFreeRooms;
DELIMITER $$
CREATE PROCEDURE getFreeRooms(hotelId INT, startDate DATE, endDate DATE)
BEGIN
    SELECT r.room_id, r.room_number, rt.room_NAME
    FROM Room r
    INNER JOIN Room_type rt ON r.room_type_id = rt.room_type_id
    WHERE r.hotel_id = hotelId AND r.room_id NOT IN (
      SELECT b.room_id FROM Booking b
      INNER JOIN Check_in ci ON b.checkin_date = ci.check_in_id
      INNER JOIN Check_out co ON b.checkout_date = co.check_out_id
      WHERE ci.check_in_date BETWEEN startDate AND endDate AND IF(ISNULL(co.check_out_date) = 0, co.check_out_date, ci.check_out_date) BETWEEN startDate AND endDate
  );
END$$
DELIMITER ;

CALL getFreeRooms(1, '2023-01-07', '2023-01-21');

DROP PROCEDURE IF EXISTS createBooking;
DELIMITER $$
CREATE PROCEDURE createBooking(
    roomId INT,
    customerId INT,
    checkinDate INT,
    checkoutDate INT
)
BEGIN
    INSERT INTO Booking (room_id, customer_id, checkin_date, checkout_date, duration) VALUES (roomId, customerId, checkinDate, checkoutDate, 0);
    
    UPDATE booking b
    INNER JOIN check_in c on b.checkin_date = c.check_in_id
    SET duration = DATEDIFF(c.check_out_date, c.check_in_date) WHERE (b.booking_id > 0);
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS createCheckIn_CheckOut;
DELIMITER $$
CREATE PROCEDURE createCheckIn_CheckOut(
	checkinDate DATE,
    checkoutDate DATE
)
BEGIN
	INSERT INTO Check_in (check_in_date, check_out_date, manager_id) VALUES (checkinDate, checkoutDate, (SELECT t1.employee_id FROM employee AS t1 JOIN (SELECT employee_id FROM employee where type_of_employee_id = 1 ORDER BY RAND() LIMIT 1) as t2 ON t1.employee_id=t2.employee_id));
    SET @checkinId = LAST_INSERT_ID();
    INSERT INTO Check_out (check_out_date, manager_id) VALUES (null, null);
    SET @checkoutId = LAST_INSERT_ID();
END$$
DELIMITER ;

CALL createCheckIn_CheckOut("2023-01-07", "2023-01-21");
SELECT @checkinId, @checkoutId;
CALL createBooking(3, 37, @checkinId, @checkoutId);

select * from check_in;
select * from check_out;
select * from booking;


DROP PROCEDURE IF EXISTS update_room_price;
DELIMITER //
CREATE PROCEDURE update_room_price(IN p_room_type_id INT, IN p_new_price DECIMAL(10,2))
BEGIN
  DECLARE room_type_name VARCHAR(20);
  
  SELECT room_name INTO room_type_name
  FROM Room_type
  WHERE room_type_id = p_room_type_id;
  
  
  UPDATE Room_type
  SET price_for_day = p_new_price
  WHERE room_type_id = p_room_type_id;


END;
//
DELIMITER ;
call update_room_price(3, 3500);
select * from room_type;
