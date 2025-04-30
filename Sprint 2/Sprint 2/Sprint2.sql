#NIVELL 1

#Exercici.2: Utilitzant JOIN realitzaràs les següents consultes:
#Llistat dels països que estan fent compres.

SELECT DISTINCT country AS Países
FROM company
JOIN transaction
ON company.id = transaction.company_id
WHERE declined = 0
ORDER BY Países ASC;

#Des de quants països es realitzen les compres.

SELECT COUNT(DISTINCT country) AS Número_Países
FROM company
JOIN transaction
ON company.id = transaction.company_id
WHERE declined = 0
ORDER BY Número_Países ASC; 

#Identifica la companyia amb la mitjana més gran de vendes.
SELECT c.company_name AS Nombre, ROUND(AVG(t.amount), 2) AS Ventas
FROM transaction t
JOIN company c
ON c.id = t.company_id
WHERE declined = 0
GROUP BY t.company_id
ORDER BY Ventas DESC
LIMIT 1;

#Exercici 3: Utilitzant només subconsultes (sense utilitzar JOIN):
#Mostra totes les transaccions realitzades per empreses d'Alemanya.

SELECT * 
FROM transaction 
WHERE company_id IN(
	SELECT id 
    FROM company 
    WHERE country = 'Germany') AND declined = 0;

#Llista les empreses que han realitzat transaccions per un amount superior a la mitjana de totes les transaccions.

SELECT DISTINCT company_name AS Empresas
FROM company
WHERE id IN(
	SELECT company_id FROM transaction WHERE declined = 0 AND amount > (
		SELECT AVG(amount) FROM transaction WHERE declined = 0));

#Eliminaran del sistema les empreses que no tenen transaccions registrades, entrega el llistat d'aquestes empreses.

SELECT company_name AS Empresas_Sin_Transacciones
FROM company 
WHERE NOT EXISTS (
        SELECT 1 FROM transaction 
        WHERE company.id = transaction.company_id
      );

#NIVELL 2
#Exercici 1: Identifica els cinc dies que es va generar la quantitat més gran d'ingressos a l'empresa per vendes.
#Mostra la data de cada transacció juntament amb el total de les vendes.

SELECT DATE(timestamp) AS Fecha, SUM(amount) AS Ingresos
FROM transaction
WHERE declined = 0
GROUP BY Fecha
ORDER BY Ingresos DESC
LIMIT 5;

#Exercici 2: Quina és la mitjana de vendes per país? Presenta els resultats ordenats de major a menor mitjana.

SELECT c.country AS Países, ROUND(AVG(t.amount), 2) AS Ventas
FROM company c
JOIN transaction t
ON c.id = t.company_id
WHERE declined = 0
GROUP BY Países
ORDER BY Ventas DESC;

#Exercici 3: En la teva empresa, es planteja un nou projecte per a llançar algunes campanyes publicitàries 
#per a fer competència a la companyia "Non Institute". Per a això, et demanen la llista de totes les transaccions 
#realitzades per empreses que estan situades en el mateix país que aquesta companyia.
#Mostra el llistat aplicant JOIN i subconsultes.

SELECT *
FROM company c
JOIN transaction t
ON c.id = t.company_id
WHERE c.country = (
	SELECT country
    FROM company
    WHERE company_name = "Non Institute") AND c.company_name != "Non Institute";

#Mostra el llistat aplicant solament subconsultes.

SELECT * FROM transaction
WHERE company_id IN (
    SELECT id
    FROM company
    WHERE country = (
		SELECT country
		FROM company
		WHERE company_name = "Non Institute")
        AND company_id != (
			SELECT id 
            FROM company 
            WHERE company_name = "Non Institute"));
	
#NIVELL 3
#Exercici 1: Presenta el nom, telèfon, país, data i amount, d'aquelles empreses que van realitzar transaccions 
#amb un valor comprès entre 100 i 200 euros i en alguna d'aquestes dates: 29 d'abril del 2021, 20 de juliol del 2021 i 13 de març del 2022.
#Ordena els resultats de major a menor quantitat.

SELECT c.company_name AS Empresa, c.phone AS Teléfono, c.country AS País, DATE(t.timestamp) AS Fecha, t.amount AS Importe
FROM company c
JOIN transaction t
ON c.id = t.company_id
WHERE t.amount BETWEEN 100 AND 200 AND DATE(timestamp) IN ('2021-04-29', '2021-07-20', '2022-03-13')
ORDER BY t.amount DESC;

#Exercici 2: Necessitem optimitzar l'assignació dels recursos i dependrà de la capacitat operativa que es requereixi, 
#per la qual cosa et demanen la informació sobre la quantitat de transaccions que realitzen les empreses, 
#però el departament de recursos humans és exigent i vol un llistat de les empreses on especifiquis si tenen més de 4 transaccions o menys.

SELECT company_name AS Empresa, COUNT(*) AS Núm_Transacciones,
IF (COUNT(*)>4, "Sí", "No") AS Superior_a_4
FROM transaction
JOIN company
ON transaction.company_id = company.id 
WHERE declined =0
GROUP BY company_id
ORDER BY Núm_Transacciones, Empresa ASC;