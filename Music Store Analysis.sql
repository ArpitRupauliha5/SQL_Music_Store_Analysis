/* Q1: Who is the senior most employee based on job title? */
Select * From Employee
Order By levels DESC
LIMIT 1;

/* Q2: Which countries have the most Invoices? */
Select Count(*) AS Most_invoice, billing_country
From Invoice
Group BY billing_country
Order by Most_invoice Desc;

/* Q3: What are top 3 values of total invoice? */
Select Total from invoice 
order by total Desc
Limit 3

/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */
Select billing_city, Sum(total) As Invoice_total
from invoice
Group BY billing_city
order by Invoice_total Desc
Limit 1;


/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/
Select Customer.customer_id,first_name, last_name,
Sum(invoice.total) AS Most_money from Customer
Join invoice On Customer.customer_id = invoice.customer_id
Group By Customer.customer_id
Order By Most_money Desc
Limit 1

/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */
Select  Distinct first_name, last_name, email 
From customer
join Invoice ON Customer.customer_id = Invoice.customer_id
join Invoice_Line ON Invoice.invoice_id = Invoice.invoice_id
join Track On Invoice_Line.track_id = Track.track_id
join Genre On Track.genre_id = Genre.genre_id
where genre.name = 'Rock' 
order by email;


/* Q2: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */
Select Artist.name AS ArtistName , Count(*) AS Number_of_Songs
From Track
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
Where genre.name = 'Rock'
Group By Artist.name
Order by Number_of_Songs DESC
Limit 10;

/* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */
Select name,milliseconds
from track
Where milliseconds > (select Avg(milliseconds) As Avg_milli 
from track
)
order by milliseconds Desc;


/* Q1: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */
WITH best_selling_artist AS 
	SELECT artist.artist_id AS artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

/* Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

/* Steps to Solve:  There are two parts in question- first most popular music genre and second need data at country level. */

With popular_genre AS(
Select Count(invoice_line.quantity)As purchase, customer.country, genre.name, genre.genre_id,
ROW_NUMBER()OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS Row_num
From invoice_line
JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)

Select * from popular_genre where Row_num <=1


/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

With Top_Customer As
(
Select customer.country,customer.first_name,customer.last_name,SUM(Total) AS Amount,
Row_Number () Over (Partition By Country Order By SUM(Total)Desc) AS Row_num
From invoice
Join Customer On invoice.customer_id = customer.customer_id
Group By 1,2,3
Order By 4 Desc
)
Select * from Top_Customer where Row_num <= 1;
