/*Task 1. Aggregating and analyzing marketing data from Facebook Ads to evaluate the performance of various campaigns. */
WITH fabd_agr_res AS 
(
	-- Aggregating data by date and campaign ID
	SELECT 
		ad_date 
		, campaign_id 
		, SUM (spend) AS total_spend
		, SUM (impressions) AS total_impressions
		, SUM (clicks) AS total_clicks
		, SUM (value) AS total_value
	FROM facebook_ads_basic_daily fabd 
	WHERE clicks>0
	GROUP BY 
		ad_date
		, campaign_id
)
SELECT 
	ad_date 
	, campaign_id 
-- Calculating CPC, CPM, CTR, and ROMI
	, total_spend::NUMERIC/total_clicks::NUMERIC AS CPC
	, total_spend::NUMERIC/total_impressions::NUMERIC*1000 AS CPM
	, total_clicks::NUMERIC/total_impressions::NUMERIC*100 AS CTR
	, total_value::NUMERIC/total_spend::NUMERIC*100 AS ROMI
FROM fabd_agr_res;
