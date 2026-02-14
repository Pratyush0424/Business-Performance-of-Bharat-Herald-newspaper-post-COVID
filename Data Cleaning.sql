-- Data Cleaning

# Ad Revenue
create table n.adrevenue as
with half_clean_revenue as (
select
	edition_id, ad_category,
    case
		when quarter regexp '^2' then replace(substring_index(quarter, '-', -1), 'Q', '')
        when quarter regexp '^Q' then substring(quarter, 2, 1)
        else substring(quarter, 1, 1) end as quarter,
	case
		when quarter regexp '^2' then substring(quarter, 1, 4)
		when quarter regexp '^Q' then substring_index(quarter, '-', -1)
		else substring_index(quarter, 'Qtr ', -1) end as year,
	ad_revenue, currency
from
	n.ad_revenue) 
select
	edition_id, ad_category, quarter, year, 
    round(case
		when currency regexp '^U' then
									case
										when year = 2019 then ad_revenue * 70.52
                                        when year = 2020 then ad_revenue * 74.26
                                        when year = 2021 then ad_revenue * 75.57
                                        when year = 2022 then ad_revenue * 80.62
                                        when year = 2023 then ad_revenue * 82.59
                                        when year = 2024 then ad_revenue * 83.68 end
        when currency regexp '^E' then
									case
										when year = 2019 then ad_revenue * 78.84
                                        when year = 2020 then ad_revenue * 84.64
                                        when year = 2021 then ad_revenue * 87.44
                                        when year = 2022 then ad_revenue * 82.72
                                        when year = 2023 then ad_revenue * 89.20
                                        when year = 2024 then ad_revenue * 90.58 end
         else ad_revenue                               
                                        end, 0) as revenue
from
	half_clean_revenue;
    
# City
create table n.city_ as 
select
	city_id,
    concat(upper(substring(city, 1, 1)), lower(substring(city,2))) as city,
    concat(upper(substring(state, 1, 1)), lower(substring(state,2))) as state,
    tier
from 
	n.city;

# city_readiness
create table n.cityreadiness_ as 
select
	city_id,
    replace(substring_index(quarter, '-', -1), 'Q', '') as quarter,
    substring_index(quarter, '-', 1) as year,
    literacy_rate, smartphone_penetration, internet_penetration
from
	n.city_readiness;

# digital_pilot
create table n.digitalpilot_ as 
select 
	platform,
    case
		when substring_index(launch_month, '-', -1) in (01, 02, 03) then 1
        when substring_index(launch_month, '-', -1) in (04, 05, 06) then 2
        when substring_index(launch_month, '-', -1) in (07, 08, 09) then 3
        else 4 end as quarter,
	substring_index(launch_month, '-', 1) as year,
    ad_category_id, dev_cost, marketing_cost, users_reached, downloads_or_accesses, avg_bounce_rate, city_id
from
	n.digital_pilot;

# print_sales
create table n.printsales_ as 
select
	edition_ID, City_ID as city_id,
    case
		when Language regexp '^[Hh]' then 'Hindi'
        else 'English' end as language,
	case
		when position('/' in Month) = 0
		then
			case
				when substring_index(Month, '-', 1) in ('Jan', 'Feb', 'Mar')
				then 1
                when substring_index(Month, '-', 1) in ('Apr', 'May', 'Jun')
                then 2
                when substring_index(Month, '-', 1) in ('Jul', 'Aug', 'Sep')
                then 3
                else 4 end
		when position('/' in Month) > 0
        then
			case
				when substring_index(Month, '/',-1) in (01, 02, 03)
                then 1
                when substring_index(Month, '/',-1) in (04, 05, 06)
				then 2
                when substring_index(Month, '/',-1) in (07, 08, 09)
                then 3
                else 4 end end as quarter,
	case
		when position('/' in Month) > 0
        then substring_index(Month, '/', 1)
        else concat(20, substring_index(Month, '-', -1)) end as year,
	`Copies Sold` as copies_sold, copies_returned, Net_Circulation as net_circulation
from 
	n.print_sales;
