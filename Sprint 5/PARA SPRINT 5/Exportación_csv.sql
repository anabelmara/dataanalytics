SELECT *
FROM sales.cc_status
INTO OUTFILE 'cc_status.csv';

SELECT *
FROM sales.transaction_products
INTO OUTFILE 'transaction_products.csv';

SELECT *
FROM sales.users
INTO OUTFILE 'users.csv';

SELECT *
FROM sales.companies
INTO OUTFILE 'companies.csv';

SELECT *
FROM sales.credit_cards
INTO OUTFILE 'credit_cards.csv';

SELECT *
FROM sales.products
INTO OUTFILE 'products.csv';

SELECT *
FROM sales.transactions
INTO OUTFILE 'transactions.csv';

