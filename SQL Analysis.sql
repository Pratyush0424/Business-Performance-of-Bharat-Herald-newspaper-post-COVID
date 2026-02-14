# year on year net newspaper circulation change with average fall
select
	*,
    round(avg(yoy_netcirculation_change) over(),2) as avg_fall_percent
from (
	select 
		year, avg_copies_sold, avg_copies_returned, avg_net_circulation,
		round(((avg_net_circulation - lag(avg_net_circulation, 1) over(order by year asc)) /
		lag(avg_net_circulation, 1) over(order by year asc)) * 100, 2) as yoy_netcirculation_change
	from (
		select
			year,
			round(avg(copies_sold), 0) as avg_copies_sold,
			round(avg(copies_returned),0) as avg_copies_returned,
			round(avg(net_circulation),0) as avg_net_circulation
		from n.printsales_
		group by year ) as table1 ) as final_table;




# copies return rate every year
select
	year, round(avg_copies_returned * 100 / avg_copies_sold, 2) as return_rate_percent
from (
	select
		year,
		avg(copies_sold) as avg_copies_sold,
		avg(copies_returned) as avg_copies_returned
	from n.printsales_
	group by year) as table1
    order by year;




# Impact on newspaper circulation after first covid wave lockdown
select
	*,
    round(avg(qoq_netcirculation_change) over(),2) as avg_decline_after_first_wave
from (
	select
		year, quarter, avg_net_circulation,
		round(((avg_net_circulation - lag(avg_net_circulation, 1) over(order by year asc, quarter asc))/
		lag(avg_net_circulation, 1) over(order by year asc, quarter asc) * 100), 2) as qoq_netcirculation_change
	from (
		select
			year, quarter, round(avg(net_circulation), 0) as avg_net_circulation
		from n.printsales_
		group by year, quarter
		having year = 2019 and quarter = 4 or year = 2020) as table2) as final_table1;




# Impact on newspaper circulation after second covid wave lockdown
select
	*,
    round(avg(qoq_netcirculation_change) over(),2) as avg_decline_after_second_wave
from (
	select 
		year, quarter, avg_net_circulation,
		round(((avg_net_circulation - lag(avg_net_circulation, 1) over(order by year asc, quarter asc))/
		lag(avg_net_circulation, 1) over(order by year asc, quarter asc) * 100), 2) as qoq_netcirculation_change
	from (
		select
			year, quarter, round(avg(net_circulation), 0) as avg_net_circulation
		from n.printsales_
		group by year, quarter
		having year = 2020 and quarter = 4 or year = 2021) as table3) as final_table2;
 
 
 
 
# Which language newspaper declined the most in first covid wave
select
	year, language, avg_circulation,
    round(((avg_circulation - lag(avg_circulation, 1) over(partition by language order by year))/
    lag(avg_circulation, 1) over(partition by language order by year) * 100), 2) as net_change
from (
select
	year, language, avg(net_circulation) as avg_circulation
from n.printsales_
group by year, language
having year in (2019, 2020)) as table1;




# Which language newspaper declined the most in second covid wave
select
	year, language, avg_circulation,
    round(((avg_circulation - lag(avg_circulation, 1) over(partition by language order by year))/
    lag(avg_circulation, 1) over(partition by language order by year) * 100), 2) as net_change
from (
select
	year, language, avg(net_circulation) as avg_circulation
from n.printsales_
group by year, language
having year in (2020, 2021)) as table1;




# which city reported highest decline in newspaper circulation
with city_and_newspaper as (
	select
		s.*, c.city, c.state, c.tier,
		case when year = 2019 then 'Pre-Covid'
		else 'Post-Covid' end as covid_period
	from n.printsales_ as s
	join n.city_ as c
		on s.city_id = c.city_id),
city_covidperiod_crosstab as (
	select 
		city,
		round(avg(case when covid_period = 'Pre-Covid' then net_circulation end),0) as net_circulation_before_covid,
		round(avg(case when covid_period = 'Post-Covid' then net_circulation end),0) as net_circulation_after_covid
	from city_and_newspaper
	group by city)
select
	*,
    round(((net_circulation_after_covid - net_circulation_before_covid) * 100
    /net_circulation_before_covid), 2) as net_change
from city_covidperiod_crosstab
order by 4 asc;




# Is smartphone penetration and internet comsumption primary reason of strong decline in newspaper circulation in Varanasi, Jaipur and Bhopal
with cityreadiness_with_names as (
	select
		 cr.*,
		 c.city, c.state, c.tier,
		 case when year = '2019' then 'Pre-Covid'
		 else 'Post-Covid' end as covid_period
	from n.cityreadiness_ as cr
	join n.city_ as c
		on c.city_id = cr.city_id),
city_covidperiod_crosstab as (
	select
		city,
		avg(case when covid_period = 'Pre-Covid' then literacy_rate end) as pre_covid_literacy_rate,
		avg(case when covid_period = 'Post-Covid' then literacy_rate end) as post_covid_literacy_rate,
		avg(case when covid_period = 'Pre-Covid' then smartphone_penetration end) as pre_covid_smartphone_penetration,
		avg(case when covid_period = 'Post-Covid' then smartphone_penetration end) as post_covid_smartphone_penetration,
		avg(case when covid_period = 'Pre-Covid' then internet_penetration end) as pre_covid_internet_penetration,
		avg(case when covid_period = 'Post-Covid' then internet_penetration end) as post_covid_internet_penetration
	from cityreadiness_with_names
	group by city)
select 
	city,
    round((post_covid_literacy_rate - pre_covid_literacy_rate) * 100/ pre_covid_literacy_rate,2) as net_change_literacy,
    round((post_covid_smartphone_penetration - pre_covid_smartphone_penetration) * 100/ pre_covid_smartphone_penetration,2) as net_change_smartphone_penetration,
    round((post_covid_internet_penetration - pre_covid_internet_penetration) * 100/ pre_covid_internet_penetration,2) as net_change_internet_penetration
from city_covidperiod_crosstab
order by 3 desc;




# which cities has the highest newspaper demand before covid
select
	c.city, round(avg(net_circulation),0) as avg_newspaper_circulated
from n.printsales_ as s
join n.city_ as c
	on s.city_id = c.city_id
where year = 2019
group by c.city
order by 2 desc;




# year on year change in ad_revenue
create view n.cate_added_revenue as
	select
		r.*,
		adc.standard_ad_category, adc.category_group
	from n.adrevenue as r
	join n.ad_category as adc
		on r.ad_category = adc.ad_category_id;
select
	*,
    round(avg(yoy_change) over(),2) as average_yoy_change
from (
	select
		year,
		total_revenue,
		round(((total_revenue - lag(total_revenue, 1) over(order by year)) / 
		lag(total_revenue, 1) over(order by year)) * 100, 2) as yoy_change
	from (
		select
			year, sum(revenue) as total_revenue
		from n.cate_added_revenue
		group by year) as table1) as final_table;




# Revenue generated in first covid wave and second covid wave
with first_covid_rev as (
	select
		2020 as  year,
		quarter,
		sum(revenue) as total_revenue_2020
	from n.adrevenue
	where year = 2020
	group by quarter),
second_covid_rev as (
	select
		2021 as year,
		quarter,
		sum(revenue) as total_revenue_2021
	from n.adrevenue
	where year = 2021
	group by quarter)
select
	frev.quarter, frev.year, total_revenue_2020,
    round(((total_revenue_2020 - lag(total_revenue_2020, 1) over(order by frev.quarter))/
    lag(total_revenue_2020, 1) over(order by frev.quarter)) * 100, 2) as net_change_in2020,
    srev.year, total_revenue_2021,
    round(((total_revenue_2021 - lag(total_revenue_2021, 1) over(order by frev.quarter))/
    lag(total_revenue_2021, 1) over(order by frev.quarter)) * 100, 2) as net_change_in2021
from first_covid_rev as frev
join second_covid_rev as srev
	on frev.quarter = srev.quarter
order by 1 asc;




# ad_revnue per copies ciculated
with total_revenue_by_year as (
	select
		year,
		sum(revenue) as total_revenue
	from n.adrevenue
	group by year),
total_copies_by_year as (
	select
		year,
		sum(copies_sold) as total_copies
	from n.printsales_
	group by year)
select
	rev.year, 
    total_revenue,
    total_copies,
    round(total_revenue/total_copies, 2) as ad_revenue_per_copyprinted
from total_revenue_by_year as rev
join total_copies_by_year as prints
	on rev.year = prints.year
group by rev.year
order by year;




# Which ad category lost interest in newspaper marketing
with category_rev_by_year as (
	select
		standard_ad_category,
		sum(case when year = 2019 then revenue end) as revenue_2019,
		sum(case when year = 2020 then revenue end) as revenue_2020,
		sum(case when year = 2021 then revenue end) as revenue_2021,
		sum(case when year = 2022 then revenue end) as revenue_2022,
		sum(case when year = 2023 then revenue end) as revenue_2023,
		sum(case when year = 2024 then revenue end) as revenue_2024
	from n.cate_added_revenue
	group by standard_ad_category),
category_revenue_pre_and_post_covid as (
	select
		standard_ad_category,
		revenue_2019 as revenue_pre_covid,
		round((revenue_2020 + revenue_2021 + revenue_2022 + revenue_2023 + revenue_2024)/5,0) as avg_revenue_post_covid
	from category_rev_by_year)
select
	*,
    round(((avg_revenue_post_covid - revenue_pre_covid)/revenue_pre_covid) * 100, 2) as net_change_in_revenue
from category_revenue_pre_and_post_covid;




# cost of digital pilot platforms
select
	platform,
    sum(dev_cost) as development_cost,
    sum(marketing_cost) as marketing_cost,
    sum(dev_cost + marketing_cost) as  total_cost,
    sum(users_reached) as total_reach_by_campaign,
    sum(downloads_or_accesses) as users_downloaded,
    round(sum(downloads_or_accesses) / sum(users_reached), 2) * 100 as engagement_effi_percent,
    round(avg(avg_bounce_rate),2) as avg_bounce_percent
from n.digitalpilot_
group by platform
order by 1;




# Digital pilot response by city 
with city_and_digitalpilot as (
	select
		platform, dev_cost, marketing_cost, users_reached, downloads_or_accesses, avg_bounce_rate,
		city, state, tier
	from n.digitalpilot_ as dp
	join n.city_ as c
		on c.city_id = dp.city_id),
cte1 as (
	select
		city,
		platform,
		sum(marketing_cost) as marketing_cost,
		sum(users_reached) as users_reach,
		sum(downloads_or_accesses) as total_downloads,
        round(sum(downloads_or_accesses) / sum(users_reached), 2) * 100 as engagement_effi_percent,
		avg(avg_bounce_rate) as avg_bounce_percent
	from city_and_digitalpilot
	group by city, platform)
select
	*,
    dense_rank() over(partition by city order by avg_bounce_percent desc) as bounce_ranking,
    dense_rank() over(partition by city order by engagement_effi_percent desc) as engagement_effi_ranking
from cte1
order by avg_bounce_percent desc, bounce_ranking asc;
