# SPRINT 3

# Exercici 1: La teva tasca és dissenyar i crear una taula anomenada "credit_card" que emmagatzemi detalls crucials
# sobre les targetes de crèdit. La nova taula ha de ser capaç d'identificar de manera única cada targeta
# i establir una relació adequada amb les altres dues taules ("transaction" i "company").
# Després de crear la taula serà necessari que ingressis la informació del document denominat "dades_introduir_credit".
# Recorda mostrar el diagrama i realitzar una breu descripció d'aquest.

CREATE TABLE credit_card(
		id VARCHAR(15) PRIMARY KEY,
        iban VARCHAR(40),
        pan VARCHAR(20),
        pin VARCHAR(4),
        cvv INT,
        expiring_date VARCHAR(20)
        );
	
ALTER TABLE transaction ADD FOREIGN KEY (credit_card_id) REFERENCES credit_card(id);
        
# Exercici 2: El departament de Recursos Humans ha identificat un error en el número de compte de l'usuari amb ID CcU-2938.
# La informació que ha de mostrar-se per a aquest registre és: R323456312213576817699999.
# Recorda mostrar que el canvi es va realitzar.

UPDATE transactions.credit_card
SET iban = 'R323456312213576817699999'
WHERE id = 'CcU-2938';

SELECT *
FROM credit_card
WHERE id = 'CcU-2938';

#Exercici 3: En la taula "transaction" ingressa un nou usuari amb la següent informació:

INSERT INTO transactions.credit_card (id)
VALUES ('CcU-9999');

INSERT INTO transactions.company (id)
VALUES ('b-9999');

INSERT INTO transactions.transaction (id, credit_card_id, company_id, user_id, lat, longitude, amount, declined)
VALUES ('108B1D1D-5B23-A76C-55EF-C568E49A99DD', 'CcU-9999', 'b-9999', '9999', '829.999', '-117.999', '111.11', '0');

SELECT *
FROM transaction
WHERE id = '108B1D1D-5B23-A76C-55EF-C568E49A99DD';

# Exercici 4
#Des de recursos humans et sol·liciten eliminar la columna "pan" de la taula credit_card.
#Recorda mostrar el canvi realitzat.

ALTER TABLE credit_card DROP COLUMN pan;

SELECT *
FROM credit_card;

#Nivell 2

#Exercici 1
#Elimina de la taula transaction el registre amb ID 02C6201E-D90A-1859-B4EE-88D2986D3B02 de la base de dades.

DELETE FROM transaction
WHERE id = '02C6201E-D90A-1859-B4EE-88D2986D3B02';

SELECT *
FROM transaction
WHERE id = '02C6201E-D90A-1859-B4EE-88D2986D3B02';

#Exercici 2: La secció de màrqueting desitja tenir accés a informació específica per a realitzar anàlisi i estratègies efectives.
# S'ha sol·licitat crear una vista que proporcioni detalls clau sobre les companyies i les seves transaccions. 
# Serà necessària que creïs una vista anomenada VistaMarketing que contingui la següent informació: Nom de la companyia. 
# Telèfon de contacte. País de residència. Mitjana de compra realitzat per cada companyia. 
# Presenta la vista creada, ordenant les dades de major a menor mitjana de compra.

CREATE VIEW VistaMarketing AS
SELECT c.company_name AS Empresa, c.phone AS Telefono, c.country as Pais, ROUND(AVG(amount), 2) AS Media_Compras
FROM company c
JOIN transaction t
ON c.id = t.company_id
WHERE declined = 0
GROUP BY c.id
ORDER BY AVG(amount) DESC;

# Exercici 3:
# Filtra la vista VistaMarketing per a mostrar només les companyies que tenen el seu país de residència en "Germany".

SELECT * 
FROM transactions.VistaMarketing
WHERE Pais = 'Germany';

# Nivell 3
#Exercici 1: La setmana vinent tindràs una nova reunió amb els gerents de màrqueting.
# Un company del teu equip va realitzar modificacions en la base de dades, però no recorda com les va realitzar.
# Et demana que l'ajudis a deixar els comandos executats per a obtenir el següent diagrama:

ALTER TABLE user
DROP FOREIGN KEY user_ibfk_1;

INSERT INTO transactions.user(id)
VALUES ('9999');

ALTER TABLE transaction
ADD CONSTRAINT FK_usertransaction
FOREIGN KEY (user_id) REFERENCES user(id);

ALTER TABLE credit_card ADD fecha_actual DATE;

ALTER TABLE company DROP COLUMN website;

ALTER TABLE user RENAME data_user;

ALTER TABLE data_user CHANGE email personal_email VARCHAR(100);

ALTER TABLE credit_card MODIFY COLUMN iban VARCHAR(50);
ALTER TABLE credit_card MODIFY COLUMN id VARCHAR(20);

# Exercici 2: L'empresa també et sol·licita crear una vista anomenada "InformeTecnico" que contingui la següent informació:
# ID de la transacció, Nom de l'usuari/ària, Cognom de l'usuari/ària, IBAN de la targeta de crèdit usada,
# Nom de la companyia de la transacció realitzada.
# Assegura't d'incloure informació rellevant de totes dues taules
# i utilitza àlies per a canviar de nom columnes segons sigui necessari.

CREATE VIEW InformeTecnico AS
SELECT t.id AS ID_transaccion, u.name AS nombre, u.surname AS apellido, cc.iban, c.company_name AS empresa
FROM transaction t
JOIN company c
ON t.company_id = c.id
JOIN data_user u
ON u.id = t.user_id
JOIN credit_card cc
ON cc.id = t.credit_card_id;

# Mostra els resultats de la vista, ordena els resultats de manera descendent en funció de la variable ID de transaction.

SELECT * 
FROM informetecnico
ORDER BY ID_transaccion DESC;
