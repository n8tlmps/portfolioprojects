<!DOCTYPE html>
<html>
<h1>Airbnb Listings Analysis in San Diego</h1>
<h2>Introduction</h2>
<p>Understanding market trends is essential for Airbnb hosts and property managers to optimize their strategies and boost profitability. Analyzing which listings are most popular can reveal features that attract the most guests, offering valuable insights for enhancing other properties.</p>

<p>This analysis aims to provide insights to the following questions of interest:</p>
<p>
	<ol>
		<li><b>Which neighborhoods have the highest number of listings?</b></li>
  		<li><b>What are the most expensive neighbourhoods to book?</b></li>
  		<li><b>Who are the hosts with the most listings?</b></li>
  		<li><b>Which months are the most popular to book in prominent neighborhoods?</b></li>
	</ol>
</p>

<p>The detailed lisitings data can be found <a href="https://insideairbnb.com/get-the-data/">here.</a>

<h2>Setup and Installation</h2>
<p>The procedure involved using SQLAlchemy in Python to import a CSV file into a MySQL database. The CSV data was first read into a pandas DataFrame. Then, an SQLAlchemy engine was created to establish a connection with the MySQL database. Using pandas <b>'to_sql'</b> method, the DataFrame contents were efficiently transferred into a MySQL table. This method facilitated a streamlined data import process, optimizing data management and enabling straightforward analysis through MySQL's capabilities.</p>

<h2>Insights</h2>
<p>From the analyis carried out, I was able to gain the following insights:</p>
<p>
            1. The neighborhoods with the highest number of bookings are <b>Mission Bay, Pacific Beach, La Jolla, Ocean Beach, and North Hills.</b>
      <br> 2. The most expensive neighbourhoods to book are <b>Torrey Pines, Moreno Mission, La Jolla, Wooded Area, and Del Cerro.</b>
      <br> 3. The hosts with the most listings are <b>Surf Style, Bluewater Vacation Homes, Coast Vacation Homes, Evan, and La Jolla.</b>
      <br> 4. <b>March</b> is the most popular month to book Airbnbs in San Diego. This could be attributed to students going on Spring Break.
</p>

<h3>Analysis</h3>
<p>Queries used to obtain these insights and the results will be shown below each of the business question.</p>
<p><b>Which neighborhoods have the highest number of listings?</b></p>

<!-- which neighborhoods have the highest listings-->
      SELECT neighbourhood_cleansed, count(*) AS num_listings
      FROM listings
      GROUP BY neighbourhood_cleansed
      ORDER BY num_listings DESC;

<img src='img/q1.png'>
<p><b>What are the most expensive neighbourhoods to book?</b></p>

<!-- what are the most expensive neighborhoods-->
      SELECT neighbourhood_cleansed,
             AVG(CAST(REPLACE(REPLACE(price, '$', ''), ',', '') AS DECIMAL(10, 2))) AS avg_price
      FROM listings
      GROUP BY neighbourhood_cleansed
      ORDER BY avg_price DESC;

<img src='img/q2.png'>

<p><b>Who are the hosts with the most listings?</b></p>

<!-- hosts with most listings -->
      SELECT host_id, host_name, host_neighbourhood,
	      count(*) as num_listings
      FROM listings
      GROUP BY host_neighbourhood, host_id, host_name
      ORDER BY num_listings DESC;

<img src='img/q3.png'>

<p><b>Which months are the most popular to book in prominent neighborhoods?</b></p>

<!--which months are the most popular to book in top 5 neighborhoods?-->
	SELECT 
    		MONTH(last_review) AS month,
    		COUNT(name) AS num_reviews
	FROM 
    		listings
	WHERE
    		last_review IS NOT NULL
    		AND neighbourhood_cleansed IN ('La Jolla', 'Mission Bay', 'North Hills', 'Ocean Beach', 'Pacific Beach')
	GROUP BY 
    		MONTH(last_review)
	ORDER BY 
    		num_reviews DESC;

<img src='img/q4.png'>

<section id='visual'>
<h2>Dashboard</h2>
<img src='img/Dashboard.png'/>
<p>Check out my interactive <a href="https://public.tableau.com/views/AirbnbAnalysis_17196132959730/Dashboard1?:language=en-US&:sid=&:display_count=n&:origin=viz_share_link">Tableau Dashboard</a></p>

</html>
