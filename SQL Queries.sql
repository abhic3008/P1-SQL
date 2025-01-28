/*   Set 1- Easy    */

/*  Q1- Who is the senior most employee in the job title? */

select * from employee
order by levels desc
limit 1



/* Q2- Which countries have the most invoices? */

select count(*) as c , billing_country from invoice
group by billing_country 
order by c desc



/* Q3- What are the top 3 values of insights? */

select * from invoice
order by total desc
limit 3



/* Q4-  Which city has the best customers? We would like to throw a promotional music festival in the city we made the most money. Write a code that returns one city that has the highest sum of invoice totals. Return both the city name and the sum of all invoice totals? */

select sum(total) as sumtotal, billing_city  from invoice
group by billing_city
order by sumtotal desc
limit 1


/*   Set 2-  Medium    */


/* Q1-  Who is the best customer? The customer who spends the most money is the best customer. Write a code for that. */

select customer.customer_id, customer.first_name, customer.last_name, sum(invoice.total) as total_amt 
from customer
inner join invoice
on customer.customer_id = invoice.customer_id
group by customer.customer_id
order by total_amt desc
limit 1



/* Q2-  Write query to return the email, first name, last name, & Genre of all Rock Music listeners. Return your list ordered alphabetically by email starting with A. */

select distinct email, first_name, last_name
from customer
join invoice on customer.customer_id= invoice.customer_id
join invoice_line on invoice.invoice_id= invoice_line.invoice_id 
where track_id in
(
Select track_id from track
join genre on track.genre_id= genre.genre_id
where genre.name= 'Rock'
 )
order by email

/* possible through 4 joins too */



/* Q3-  Let's invite the artists who have written the most rock music in our dataset. Write a query that returns the Artist name and total track count of the top 10 rock bands. */

select artist.artist_Id, artist.name, count(track.album_Id) as no_of_songs
from track
join album on track.album_Id= album.album_Id
join artist on album.artist_Id= artist.artist_Id
join genre on track.genre_id= genre.genre_id
where genre.name = 'Rock'
group by 1
order by 3 desc
limit 10



/* Q4-  Return all the track names that have a song length longer than the average song length. */ 

select name, milliseconds from track
where milliseconds >
( 
  Select avg(milliseconds)  from track  
      )
order by milliseconds desc


/*   Set 3- Tough   */


/* Q1- Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */

with bsa as
(
select artist.artist_id as artist_id, artist.name as artist_name, sum(invoice_line.unit_price*invoice_line.quantity)
from invoice_line
join track on invoice_line.track_id = track.track_id
join album on track.album_id = album.album_id
join artist on album.artist_id = artist.artist_id
group by 1
order by 3 desc
limit 1
)
select c.customer_id, c.first_name, c.last_name, bsa.artist_name, sum(invoice_line.unit_price*invoice_line.quantity)
as amt_spent from invoice
join customer c on invoice.customer_id = c.customer_id
join invoice_line on invoice.invoice_id= invoice_line.invoice_id
join track on invoice_line.track_id= track.track_id
join album on track.album_id= album.album_id
join bsa on album.artist_id= bsa.artist_id
group by 1,2,3,4
order by 5 desc



/* Q2--  Write a query that determines the customer that has spent the most on music for each country. Write a query that returns the country along with the top customer and how much they spent. For countries where the top amount spent is shared, provide all customers who spent this amount. */

with customer_country as
(
select customer.customer_id, first_name, last_name, billing_country, sum(total) as total_spending,
ROW_NUMBER() OVER(partition by billing_country
                     order by sum(total) desc) 
					  as rowno
from invoice
join customer on customer.customer_id= invoice.invoice_id
group by 1,2,3,4
order by 4 asc,5 desc
) 
select * from customer_country where rowno <=1
