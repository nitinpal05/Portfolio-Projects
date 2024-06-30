
--1. Total no. of olympics games held so far
select count(distinct Games) as total_olympic_games from athlete_events



--2. List of olympic Games held so far
select left(games,4) as year,Season,city from athlete_events
group by games,Season,City
order by Games



--3. total no. of nations who participated in olympics games
select * from  athlete_events;



with all_countries as
(
	select a.Games,n.region as region
	from athlete_events a
	join noc_regions n
	on a.noc=n.NOC
	group by games,n.region
)

	select Games,count(region) as total_countries from all_countries
	group by games
	order by Games




	--4.
with all_countries as
(
	select a.Games,n.region as region
	from athlete_events a
	join noc_regions n
	on a.noc=n.NOC
	group by games,n.region
),

cts as
(
	select Games,count(region) as total_countries,
	FIRST_VALUE(games) over(order by games) as first,
	LAST_VALUE(games) over (order by games desc) as last
	from all_countries
	group by games
	)
select concat(first,' - ',total_countries) from cts
order by Games




	--5. Countries participated in all olympics games
with t1 as
(
	select count(distinct games) as total_games
	from athlete_events
),
t2 as
(
	select Games,n.region as country
	from athlete_events a
	join noc_regions n
	on a.NOC=n.NOC
	group by games,n.region
),
t3 as
(
	select country,count(1) as total_participated_countries
	from t2
	group by country
)
	select country,total_participated_countries
	from t1 join t3
	on t1.total_games=t3.total_participated_countries


--6. Sport played in all oplympics games
with t1 as
(
	select count(distinct(games)) as total_summer_games
	from athlete_events
	where Season ='summer'
),

t2 as 
(
	select distinct(sport),Games
	from athlete_events
	where Season='summer' 
),

t3 as
(
	select sport,count(games) as no_of_games
	from t2
	group by sport
)

	select * from t3
	join t1
	on t1.total_summer_games=t3.no_of_games;





--7. Games played only once in olympics
with t1 as
(	  select distinct games ,sport
	  from athlete_events
  ),
t2 as
(
	select sport,count(1) as no_of_games from t1
	group by sport
)
select t2.*,t1.Games
from t2
join t1 
on t2.sport=t1.sport
where t2.no_of_games=1
order by t1.sport





--8. total no. of sports played in each olympics
with cte as(
	select distinct games,sport
	from athlete_events
	),

cte1 as(
	select games,count(1) as games_played
	from cte
	group by games
	)
select * from cte1
order by games_played desc





-- 9.Oldest athlete to win gold medal
with t1 as
(
	select max(age) as Age from athlete_events
	where medal='gold' 
),

t2 as(
	select name,sex,team,max(age) as Age,games,city,sport,Event,Medal
	from athlete_events
	where medal='gold'
	group by name,event,sex,team,games,city,sport,event,Medal
)

select t2.*
from t1 join t2 
on t1.Age=t2.Age





--10.select * from athlete_events
with cte as
(
	select name,team,count(medal) as total_medal,Sport
	from athlete_events
	where Medal='gold'
	group by name,Team,Medal,Sport
)
select name,team,total_medal,sport from cte order by total_medal desc;



--11. Top 5 name who won the most Gold medals
with cte as
(
	select name,team,count(medal) as total_medal,Sport
	from athlete_events
	where Medal='gold'
	group by name,Team,Medal,Sport
	),
 
t2 as
( 
	select *,dense_rank() over(order by total_medal desc) as rnk
	from cte
)

select * from t2
where rnk<=5;


-- 12. Total no. of medals in each sport by country
	select Team as country,count(Medal) as Medals,Sport 
	from athlete_events
	where medal <> 'NA'
	group by team,medal,Sport
	order by count(medal)desc ,country desc





  --13. top 5 countries with highest medals in all olympics
with cte as
    ( SELECT n.region AS country,COUNT(Medal) AS total_medals
    FROM athlete_events a
    JOIN noc_regions n ON a.NOC = n.NOC
    WHERE Medal <> 'NA'
    GROUP BY n.region),
cte1 as 
	(select *,
	rank() over(order by total_medals desc) as rank 
	from cte)

	select * from cte1
	where rank<=5



	--14. List of total gold, silver and bronze medals won by each country.
-- using pivot table to find out the country won the max gold,silver & bronze medal
SELECT *
FROM (
    SELECT n.region AS Country, Medal, COUNT(1) AS total_medals
    FROM athlete_events a
    JOIN noc_regions n ON a.NOC = n.NOC
    WHERE Medal <> 'NA'
    GROUP BY Medal, n.region
) AS SourceTable
PIVOT (
    SUM(total_medals)
    FOR Medal IN ([Gold], [Silver], [Bronze])
) AS PivotResults
ORDER BY PivotResults.Gold DESC, PivotResults.Silver DESC, PivotResults.Bronze DESC;  
 





--15. Showing the most gold,most silver & most bronze by a country in single Olympics
--using cte,pivot,concat,joins & window function
with vte as
(SELECT *
FROM (
    SELECT Games, n.region AS country, Medal, COUNT(1) AS total_medals
    FROM athlete_events a
    JOIN noc_regions n ON a.NOC = n.NOC
    WHERE Medal <> 'NA'
    GROUP BY Games,Medal, n.region
) AS SourceTable
PIVOT (
    SUM(total_medals)
    FOR Medal IN ([Gold], [Silver], [Bronze])
) AS PivotResults),   
cte as
(
	select distinct (games) as Games,
	FIRST_VALUE(gold) over(partition by games order by gold desc ) as Gold,
	FIRST_VALUE(country) over(partition by games order by gold desc ) as max1,
	FIRST_VALUE(Silver) over(partition by games order by Silver desc ) as Silver,
	FIRST_VALUE(country) over(partition by games order by silver desc ) as max2,
	FIRST_VALUE(Bronze) over(partition by games order by Bronze desc ) as Bronze,
	FIRST_VALUE(country) over(partition by games order by bronze desc ) as max3
from vte
group by Games,Gold,Silver,Bronze,country
)

	select Games,concat(max1,' - ',Gold) as Max_Gold ,
	concat(max2,' - ',Silver) as Max_Silver,
	concat(max3,' - ',Bronze) as Max_Bronze
	from cte




	-- 16. List of total gold, silver and bronze medals won by each country corresponding to each olympic games.
SELECT Games, Country, ISNULL([Gold], 0) AS Gold, ISNULL([Silver], 0) AS Silver, ISNULL([Bronze], 0) AS Bronze
FROM (
    SELECT Games,n.region AS Country, Medal, COUNT(1) AS total_medals
    FROM athlete_events a
    JOIN noc_regions n ON a.NOC = n.NOC
    WHERE Medal <> 'NA'
    GROUP BY Games,Medal, n.region

) AS SourceTable
PIVOT ( 
    SUM(total_medals)
    FOR Medal IN ([Gold], [Silver], [Bronze])
) AS PivotResults
ORDER BY games;  



---17. most medals won by india in one sport
with t1 as
(
	select n.region ,sport,count(medal) as medals
	from athlete_events a
	join noc_regions n
	on a.noc=n.noc
	where n.region='india' and medal <> 'NA'
	group by sport,n.region,sport
	),

t2 as
( select *, 
  rank() over (order by medals desc) as rnk
from t1 )

select sport,medals as total_medals
from t2
where rnk=1


-- 18. Breaking the medal by olympics for india
with cte as(
	select team,sport,games,count(medal) as medals
	from athlete_events
	where team='india' and medal <>'NA'
	group by team,sport,games,Medal
	)

select * from cte
order by medals desc

	
