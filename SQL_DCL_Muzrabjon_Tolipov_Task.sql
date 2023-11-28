CREATE USER rentaluser WITH PASSWORD 'rentalpassword';
REVOKE ALL ON DATABASE dvdrental FROM rentaluser;
GRANT CONNECT ON DATABASE dvdrental TO rentaluser;
---------------------------------
GRANT SELECT ON TABLE customer TO rentaluser;

SET ROLE rentaluser;

SELECT * FROM customer; --work

SELECT * FROM film; --fail

RESET ROLE;
-----------------------------------
CREATE GROUP rental;
GRANT rental TO rentaluser;
-----------------------------------
GRANT INSERT, UPDATE ON TABLE rental TO rental;

SET ROLE rental;

INSERT INTO "rental" ("rental_id", "rental_date", "inventory_id", "customer_id", "return_date", "staff_id")
             VALUES (90000, '2023-09-27 15:00:00', 1, 23, '2023-09-30 15:00:00', 2);
			 
UPDATE "rental"
SET "return_date" = '2023-09-28 14:00:00'
WHERE "rental_id" = 90000;

RESET ROLE;
--------------------------------------
REVOKE INSERT ON rental FROM rental;

SET ROLE rental;

INSERT INTO "rental" ("rental_id", "rental_date", "inventory_id", "customer_id", "return_date", "staff_id") --fail
             VALUES (90005, '2023-09-27 15:00:00', 1, 23, '2023-09-30 15:00:00', 2);
			 
RESET ROLE;
---------------------------------------
SELECT DISTINCT customer.customer_id, customer.first_name, customer.last_name
FROM customer
JOIN rental USING (customer_id)
JOIN payment USING (customer_id)
WHERE rental.rental_id IS NOT NULL AND payment.payment_id IS NOT NULL
limit(1);


CREATE ROLE client_patricia_johnson;
GRANT USAGE ON SCHEMA public TO client_patricia_johnson;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE payment TO client_patricia_johnson;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE rental TO client_patricia_johnson;
ALTER TABLE payment ENABLE ROW LEVEL SECURITY;
ALTER TABLE rental ENABLE ROW LEVEL SECURITY;
CREATE POLICY client_data_policy
  ON payment
  USING (customer_id = 2);
 CREATE POLICY client_data_policy
  ON rental
  USING (customer_id = 2);
ALTER TABLE rental FORCE ROW LEVEL SECURITY;
ALTER TABLE payment FORCE ROW LEVEL SECURITY;


SET ROLE client_patricia_johnson;

SELECT * FROM rental;
SELECT * FROM payment;

RESET ROLE;