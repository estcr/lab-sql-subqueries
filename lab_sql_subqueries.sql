-- Write SQL queries to perform the following tasks using the Sakila database:
use sakila;
-- 1 Determine the number of copies of the film "Hunchback Impossible" that exist in the inventory system.
SELECT COUNT(si.inventory_id) as numero_de_copias
FROM sakila.inventory as si
WHERE si.film_id = (SELECT sf.film_id FROM sakila.film as sf WHERE sf.title ="Hunchback Impossible");

-- 2 List all films whose length is longer than the average length of all the films in the Sakila database.
SELECT sf.title
FROM sakila.film as sf
WHERE length > (SELECT AVG(length) FROM sakila.film);
-- 3 Use a subquery to display all actors who appear in the film "Alone Trip".
SELECT a.first_name,
		a.last_name
FROM sakila.actor as a
WHERE a.actor_id IN (SELECT sfa.actor_id FROM sakila.film_actor as sfa 
					WHERE sfa.film_id= (SELECT sf.film_id  FROM sakila.film as sf WHERE sf.title = "Alone Trip"));
-- Bonus:
-- 4 Sales have been lagging among young families, and you want to target family movies for a promotion. Identify all movies categorized as family films.


SELECT sf.title
FROM sakila.film as sf
WHERE sf.film_id IN (SELECT sfc.film_id FROM sakila.film_category as sfc 
					 WHERE sfc.category_id = (SELECT sc.category_id FROM sakila.category as sc WHERE name = "Family"));

-- 5 Retrieve the name and email of customers from Canada using both subqueries and joins. To use joins, you will need to identify the relevant tables and their primary and foreign keys.
SELECT scu.first_name, scu.last_name, scu.email
FROM sakila.customer as scu
WHERE address_id IN(SELECT sa.address_id FROM sakila.address as sa 
					JOIN sakila.city as sc
                    ON sa.city_id = sc.city_id
                    JOIN sakila.country as cou
                    ON sc.country_id=cou.country_id
                    WHERE cou.country = "CANADA");
                    
-- 6 Determine which films were starred by the most prolific actor in the Sakila database. A prolific actor is defined as the actor who has acted in the most number of films. First, you will need to find the most prolific actor and then use that actor_id to find the different films that he or she starred in.

SELECT title
FROM sakila.film
WHERE film_id IN (
    SELECT film_id
    FROM sakila.film_actor
    WHERE actor_id = (
        SELECT actor_id
        FROM sakila.film_actor
        GROUP BY actor_id
        ORDER BY COUNT(film_id) DESC
        LIMIT 1));

-- 7 Find the films rented by the most profitable customer in the Sakila database. You can use the customer and payment tables to find the most profitable customer, i.e., the customer who has made the largest sum of payments.
SELECT sf.title
FROM sakila.film as sf
JOIN sakila.inventory as si
ON  sf.film_id=si.film_id
WHERE si.film_id IN (SELECT si.film_id
    FROM sakila.inventory as si
    JOIN sakila.rental as sr
    ON si.inventory_id = sr.inventory_id
    WHERE sr.customer_id = (
        SELECT sp.customer_id
        FROM sakila.payment as sp
        GROUP BY sp.customer_id
        ORDER BY SUM(sp.amount) DESC
        LIMIT 1))
group by sf.title;
-- 8 Retrieve the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client. You can use subqueries to accomplish this.
SELECT sp.customer_id, 
       SUM(sp.amount) AS total_amount_spent
FROM sakila.payment AS sp
GROUP BY sp.customer_id
HAVING SUM(sp.amount) > (
    SELECT AVG(total_amount)
    FROM (
        SELECT SUM(amount) AS total_amount
        FROM sakila.payment
        GROUP BY customer_id
    ) AS subquery
);