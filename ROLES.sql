drop user anastasiia@localhost;
drop user customer@localhost;
drop user manager@localhost;
flush privileges;
  
CREATE USER anastasiia@localhost IDENTIFIED BY 'developer';
CREATE USER customer@localhost IDENTIFIED BY 'customer';    
CREATE USER manager@localhost IDENTIFIED BY 'manager';

GRANT ALL 
ON hotel_complex.* 
TO anastasiia@localhost;

GRANT EXECUTE 
ON PROCEDURE hotel_complex.getCustomerBookings 
TO customer@localhost;

GRANT EXECUTE 
ON FUNCTION hotel_complex.calculateTotalCost 
TO customer@localhost;

GRANT EXECUTE 
ON PROCEDURE hotel_complex.createCheckIn_CheckOut 
TO customer@localhost;

GRANT INSERT, UPDATE, DELETE
ON hotel_complex.* 
TO manager@localhost;

GRANT EXECUTE 
ON PROCEDURE hotel_complex.getFreeRooms 
TO manager@localhost;

GRANT EXECUTE 
ON PROCEDURE hotel_complex.createBooking 
TO manager@localhost;

GRANT EXECUTE 
ON PROCEDURE hotel_complex.update_room_price 
TO manager@localhost;

SHOW GRANTS FOR anastasiia@localhost;
SHOW GRANTS FOR customer@localhost;
SHOW GRANTS FOR manager@localhost;