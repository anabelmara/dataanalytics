#Nivell 1: Descàrrega els arxius CSV, estudia'ls i dissenya una base de dades amb un esquema d'estrella que contingui
# almenys 4 taules de les quals puguis realitzar les següents consultes:

CREATE DATABASE IF NOT EXISTS sales;

USE sales;

CREATE TABLE IF NOT EXISTS transactions (
	id VARCHAR(255) PRIMARY KEY,
	card_id VARCHAR(255) REFERENCES credit_cards(id),
	business_id VARCHAR(255) REFERENCES companies(company_id), 
	timestamp VARCHAR(255),
	amount VARCHAR(255),
	declined VARCHAR(255),
    product_ids VARCHAR(255) REFERENCES products(id), 
	user_id VARCHAR(255) REFERENCES users(id),
	lat VARCHAR(255),
	longitude VARCHAR(255)
    );

LOAD DATA
INFILE '/Volumes/NO NAME/2. DATOS/1. SQL/Sprint 4/transactions.csv'
INTO TABLE transactions
FIELDS TERMINATED BY ';'
IGNORE 1 ROWS
(id, card_id, business_id, timestamp, amount, declined, @product_ids, user_id, lat, longitude)
SET 
product_ids = REPLACE(@product_ids, ' ', '')
;

ALTER TABLE transactions MODIFY COLUMN id VARCHAR(50);
ALTER TABLE transactions MODIFY COLUMN card_id VARCHAR(10);
ALTER TABLE transactions MODIFY COLUMN business_id VARCHAR(10);
ALTER TABLE transactions MODIFY COLUMN timestamp TIMESTAMP;
ALTER TABLE transactions MODIFY COLUMN amount DECIMAL(10, 2);
ALTER TABLE transactions MODIFY COLUMN declined BOOLEAN;
ALTER TABLE transactions MODIFY COLUMN product_ids VARCHAR(100);
ALTER TABLE transactions MODIFY COLUMN user_id INT;
ALTER TABLE transactions MODIFY COLUMN lat VARCHAR(50);
ALTER TABLE transactions MODIFY COLUMN longitude VARCHAR(50);


CREATE TABLE IF NOT EXISTS companies (
	company_id VARCHAR(255) PRIMARY KEY,
	company_name VARCHAR(255),
	phone VARCHAR(255), 
	email VARCHAR(255),
	country VARCHAR(255),
	website VARCHAR(255)
    );

LOAD DATA
INFILE '/Volumes/NO NAME/2. DATOS/1. SQL/Sprint 4/companies.csv'
INTO TABLE companies
FIELDS TERMINATED BY ','
IGNORE 1 ROWS
(company_id, company_name, @phone, email, country, website)
SET 
phone = REPLACE(@phone, ' ', '');

ALTER TABLE companies MODIFY COLUMN company_id VARCHAR(10);
ALTER TABLE companies MODIFY COLUMN company_name VARCHAR(50);
ALTER TABLE companies MODIFY COLUMN phone VARCHAR(10);
ALTER TABLE companies MODIFY COLUMN email VARCHAR(50);
ALTER TABLE companies MODIFY COLUMN country VARCHAR(20);
ALTER TABLE companies MODIFY COLUMN website VARCHAR(50);

ALTER TABLE transactions
ADD CONSTRAINT FK_companiestrans
FOREIGN KEY (business_id) REFERENCES companies(company_id);

CREATE TABLE IF NOT EXISTS credit_cards(
		id VARCHAR(255) PRIMARY KEY,
        user_id VARCHAR(255),
        iban VARCHAR(255),
        pan VARCHAR(255),
        pin VARCHAR(255),
        cvv VARCHAR(255),
        track1 VARCHAR(255),
        track2 VARCHAR(255),
        expiring_date VARCHAR(255)
        );
        
LOAD DATA
INFILE '/Volumes/NO NAME/2. DATOS/1. SQL/Sprint 4/credit_cards.csv'
INTO TABLE credit_cards
FIELDS TERMINATED BY ','
IGNORE 1 ROWS
(id, user_id, iban, @pan, pin, cvv, track1, track2, @expiring_date)
SET 
pan = REPLACE(@pan, ' ', ''),
expiring_date = STR_TO_DATE(@expiring_date, '%m/%d/%y');

ALTER TABLE credit_cards MODIFY COLUMN id VARCHAR(15);
ALTER TABLE credit_cards MODIFY COLUMN user_id INT;
ALTER TABLE credit_cards MODIFY COLUMN iban VARCHAR(40);
ALTER TABLE credit_cards MODIFY COLUMN pan VARCHAR(20);
ALTER TABLE credit_cards MODIFY COLUMN pin VARCHAR(4);
ALTER TABLE credit_cards MODIFY COLUMN cvv INT;
ALTER TABLE credit_cards MODIFY COLUMN track1 VARCHAR(50);
ALTER TABLE credit_cards MODIFY COLUMN track2 VARCHAR(50);
ALTER TABLE credit_cards MODIFY COLUMN expiring_date DATE;



ALTER TABLE transactions
ADD CONSTRAINT FK_creditcardstrans
FOREIGN KEY (card_id) REFERENCES credit_cards(id);

CREATE TABLE IF NOT EXISTS users(
		id VARCHAR(255) PRIMARY KEY,
        name VARCHAR(255),
        surname VARCHAR(255),
        phone VARCHAR(255),
        email VARCHAR(255),
        birth_date VARCHAR(255),
        country VARCHAR(255),
        city VARCHAR(255),
        postal_code VARCHAR(255),
        address VARCHAR(255)
        );

LOAD DATA
INFILE '/Volumes/NO NAME/2. DATOS/1. SQL/Sprint 4/users_usa.csv'
INTO TABLE users
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n' #esta es la forma de saltar línea de windows (CRLF)
IGNORE 1 ROWS
(id,name,surname,@phone,email,@birth_date,country,city,@postal_code,address)
SET 
phone = REPLACE(REPLACE(REPLACE(REPLACE(@phone, '(', ''), ')', ''), '-', ''), ' ', ''),
birth_date = STR_TO_DATE(@birth_date, '%b %d, %Y'),
postal_code = REPLACE(@postal_code, ' ', '');

LOAD DATA
INFILE '/Volumes/NO NAME/2. DATOS/1. SQL/Sprint 4/users_uk.csv'
INTO TABLE users
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n' 
IGNORE 1 ROWS
(id,name,surname,@phone,email,@birth_date,country,city,@postal_code,address)
SET 
phone = REPLACE(REPLACE(REPLACE(REPLACE(@phone, '(', ''), ')', ''), '-', ''), ' ', ''),
birth_date = STR_TO_DATE(@birth_date, '%b %d, %Y'),
postal_code = REPLACE(@postal_code, ' ', '');

LOAD DATA
INFILE '/Volumes/NO NAME/2. DATOS/1. SQL/Sprint 4/users_ca.csv'
INTO TABLE users
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n' 
IGNORE 1 ROWS
(id,name,surname,@phone,email,@birth_date,country,city,@postal_code,address)
SET 
phone = REPLACE(REPLACE(REPLACE(REPLACE(@phone, '(', ''), ')', ''), '-', ''), ' ', ''),
birth_date = STR_TO_DATE(@birth_date, '%b %d, %Y'),
postal_code = REPLACE(@postal_code, ' ', '');

ALTER TABLE users MODIFY COLUMN id INT;
ALTER TABLE users MODIFY COLUMN name VARCHAR(30);
ALTER TABLE users MODIFY COLUMN surname VARCHAR(50);
ALTER TABLE users MODIFY COLUMN phone VARCHAR(20);
ALTER TABLE users MODIFY COLUMN email VARCHAR(40);
ALTER TABLE users MODIFY COLUMN birth_date DATE;
ALTER TABLE users MODIFY COLUMN country VARCHAR(30);
ALTER TABLE users MODIFY COLUMN city VARCHAR(30);
ALTER TABLE users MODIFY COLUMN postal_code VARCHAR(20);
ALTER TABLE users MODIFY COLUMN address VARCHAR(100);

ALTER TABLE transactions
ADD CONSTRAINT FK_userstrans
FOREIGN KEY (user_id) REFERENCES users(id);


# Exercici 1: Realitza una subconsulta que mostri tots els usuaris amb més de 30 transaccions utilitzant almenys 2 taules.

SELECT *
FROM users
WHERE id IN(SELECT COUNT(DISTINCT id) AS conteo
FROM transactions
GROUP BY user_id
HAVING conteo > 30);

# Exercici 2: Mostra la mitjana d'amount per IBAN de les targetes de crèdit a la companyia Donec Ltd,
#utilitza almenys 2 taules.

SELECT c.company_name, cc.iban, ROUND(AVG(t.amount), 2) AS average
FROM companies c
INNER JOIN transactions t
ON c.company_id = t.business_id
INNER JOIN credit_cards cc
ON t.card_id = cc.id
WHERE c.company_name = 'Donec Ltd' AND declined = 0
GROUP BY cc.iban;

# Nivell 2
# Crea una nova taula que reflecteixi l'estat de les targetes de crèdit basat en si les últimes tres transaccions
# van ser declinades i genera la següent consulta:

CREATE TABLE IF NOT EXISTS cc_status(
card_id VARCHAR(15) PRIMARY KEY,
expiring_date DATE,
status VARCHAR(15)
);

INSERT INTO cc_status (card_id, expiring_date, status)
SELECT c.id AS card_id, c.expiring_date,
CASE WHEN SUM(CASE WHEN t.declined THEN 1 ELSE 0 END) = 3 THEN 'Declined' ELSE 'Active' END AS status
FROM (SELECT t1.* 
	FROM transactions t1 
    WHERE (
		SELECT COUNT(*) 
        FROM transactions t2 
        WHERE t2.card_id = t1.card_id AND t2.timestamp > t1.timestamp) < 3
) t
JOIN credit_cards c ON t.card_id = c.id
GROUP BY c.id, c.expiring_date;


ALTER TABLE transactions
ADD CONSTRAINT FK_transcardstatus
FOREIGN KEY (card_id) REFERENCES cc_status(card_id);

#Exercici 1: Quantes targetes estan actives?

SELECT COUNT(card_id) as active_cards
FROM cc_status
WHERE status = 'active';

#Nivell 3: Crea una taula amb la qual puguem unir les dades del nou arxiu products.csv amb la base de dades creada,
#tenint en compte que des de transaction tens product_ids. Genera la següent consulta:


CREATE TABLE IF NOT EXISTS products(
	id VARCHAR(255) PRIMARY KEY,
	product_name VARCHAR(255),
	price VARCHAR(255), 
	colour VARCHAR(255),
	weight VARCHAR(255),
	warehouse_id VARCHAR(255)
    );

LOAD DATA
INFILE '/Volumes/NO NAME/2. DATOS/1. SQL/Sprint 4/products.csv'
INTO TABLE products
FIELDS TERMINATED BY ','
IGNORE 1 ROWS
(id, product_name, @price, colour, weight, @warehouse_id)
SET
price = REPLACE(@price, '$', ''),
warehouse_id = REPLACE(@warehouse_id, '--', '-');


ALTER TABLE products MODIFY COLUMN id INT;
ALTER TABLE products MODIFY COLUMN product_name VARCHAR(100);
ALTER TABLE products MODIFY COLUMN price FLOAT;
ALTER TABLE products MODIFY COLUMN colour VARCHAR(20);
ALTER TABLE products MODIFY COLUMN weight FLOAT;
ALTER TABLE products MODIFY COLUMN warehouse_id VARCHAR(10);



CREATE TABLE IF NOT EXISTS transaction_products (
    transaction_id VARCHAR(50),
    product_id INT,
    PRIMARY KEY (transaction_id, product_id)
);


INSERT INTO transaction_products (transaction_id, product_id)
SELECT t.id as transaction_id, p.id as product_id
FROM transactions as t
JOIN products p 
ON FIND_IN_SET(p.id, t.product_ids) > 0;


ALTER TABLE transaction_products ADD FOREIGN KEY (transaction_id) REFERENCES transactions(id);
ALTER TABLE transaction_products ADD FOREIGN KEY (product_id) REFERENCES products(id);
#Exercici 1:
#Necessitem conèixer el nombre de vegades que s'ha venut cada producte.

SELECT tp.product_id, p.product_name, COUNT(DISTINCT tp.transaction_id) AS items_sold
FROM transaction_products tp
JOIN products p
ON tp.product_id = p.id
JOIN transactions t
ON t.id = tp.transaction_id
WHERE t.declined = 0
GROUP BY tp.product_id;
