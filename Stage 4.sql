/*Task 4. Analyze campaign performance trends over time with the calculation of changes in CPC, CTR, CPM, and ROMI.*/
WITH combined_campaigns AS 
(
	-- Combining data from Facebook Ads and Google Ads for analysis
	SELECT 
		ad_date
		, url_parameters 
		, COALESCE (spend, 0) AS spend
		, COALESCE (impressions, 0) AS impressions
		, COALESCE (reach, 0) AS reach
		, COALESCE (clicks, 0) AS clicks
		, COALESCE (leads, 0) AS leads
		, COALESCE (value, 0) AS value
	FROM facebook_ads_basic_daily fabd 
	WHERE 
		ad_date IS NOT NULL
	UNION ALL
	SELECT 
		ad_date
		, url_parameters 
		, COALESCE (spend, 0) AS spend
		, COALESCE (impressions, 0) AS impressions
		, COALESCE (reach, 0) AS reach
		, COALESCE (clicks, 0) AS clicks
		, COALESCE (leads, 0) AS leads
		, COALESCE (value, 0) AS value
	FROM google_ads_basic_daily gabd 
)
, combined_campaigns_analytics AS 
(
	-- Aggregating data for analysis
	SELECT 
		CAST (date_trunc('month', ad_date) AS date) AS ad_month
		, CASE WHEN LOWER (SUBSTRING (url_parameters, 'utm_campaign=([^\&]+)' ))='nan' THEN NULL 
			ELSE LOWER (SUBSTRING (url_parameters, 'utm_campaign=([^\&]+)' )) END AS utm_campaign
		, SUM (spend) AS total_spend
		, SUM (impressions) AS total_impressions
		, SUM (clicks) AS total_clicks
		, SUM (value) AS total_value
		, CASE WHEN SUM (impressions)=0 THEN 0 ELSE ROUND (SUM (clicks)::NUMERIC/SUM (impressions)::NUMERIC*100,2) END 					AS CTR
		, CASE WHEN SUM (clicks)=0 		THEN 0 ELSE ROUND (SUM (spend)::NUMERIC/SUM (clicks)::NUMERIC,2) END 							AS CPC
		, CASE WHEN SUM (impressions)=0 THEN 0 ELSE ROUND (SUM (spend)::NUMERIC/SUM (impressions)::NUMERIC*1000,2) END 					AS CPM
		, CASE WHEN SUM (spend)=0 		THEN 0 ELSE ROUND ((SUM (value)::NUMERIC-SUM (spend)::NUMERIC)/SUM (spend)::NUMERIC*100,2) END  AS ROMI
	FROM combined_campaigns 
	GROUP BY 
	ad_month
	, utm_campaign
)
, monthly_campaigns AS 
(
	-- Analyzing monthly campaign performance and calculating changes
	SELECT 
		ad_month
		, utm_campaign
		, total_spend
		, total_impressions
		, total_clicks
		, total_value
		, CPC
		, LAG (CPC, 1) OVER (PARTITION BY utm_campaign ORDER BY ad_month ASC) AS prev_CPC
		, CTR
		, LAG (CTR, 1) OVER (PARTITION BY utm_campaign ORDER BY ad_month ASC) AS prev_CTR
		, CPM
		, LAG (CPM, 1) OVER (PARTITION BY utm_campaign ORDER BY ad_month ASC) AS prev_CPM
		, ROMI
		, LAG (ROMI, 1) OVER (PARTITION BY utm_campaign ORDER BY ad_month ASC) AS prev_romi
	FROM combined_campaigns_analytics
	ORDER BY 
		utm_campaign
		, ad_month
)
SELECT 
	ad_month
	, utm_campaign
	, total_spend
	, total_impressions
	, total_clicks
	, total_value
	, CPC
	, (CPC-prev_CPC)/prev_CPC	 AS CPC_change_pct
	, CTR
	, (CTR-prev_CTR)/prev_CTR 	 AS CTR_change_pct
	, CPM
	, (CPM-prev_CPM)/prev_CPM 	 AS CPM_change_pct
	, ROMI
	, (ROMI-prev_romi)/prev_romi AS ROMI_change_pct
FROM monthly_campaigns;
