/*Task 2. Aggregating and preparing marketing data from both Facebook Ads and Google Ads platforms for visualization in Looker Studio. */
WITH facebook_ads_general AS 
(
	-- Extracting relevant data from Facebook Ads
	SELECT 
		fabd.ad_date
		, fc.campaign_name
		, fa.adset_name
		, fabd.spend 
		, fabd.impressions 
		, fabd.reach 
		, fabd.clicks 
		, fabd.leads 
		, fabd.value 
	FROM facebook_ads_basic_daily fabd
	LEFT JOIN facebook_campaign fc ON fabd.campaign_id=fc.campaign_id
	LEFT JOIN facebook_adset fa    ON fabd.adset_id=fa.adset_id
),
combined_ads AS 
(
	-- Combining data from Facebook Ads and Google Ads
	SELECT 
		ad_date
		, 'Google Ads' AS media_source
		, campaign_name
		, adset_name
		, spend 
		, impressions 
		, reach 
		, clicks 
		, leads 
		, value 
	FROM google_ads_basic_daily gabd
	UNION ALL
	SELECT 
		ad_date
		, 'Facebook Ads' AS media_source
		, campaign_name
		, adset_name
		, spend 
		, impressions 
		, reach 
		, clicks 
		, leads 
		, value 
	FROM facebook_ads_general
)
SELECT 
	ad_date
	, media_source
	, campaign_name	
	, adset_name
	, SUM (spend) AS total_spend
	, SUM (impressions) AS total_impressions
	, SUM (clicks) AS total_clicks
	, SUM (value) AS total_value
FROM combined_ads
WHERE ad_date IS NOT NULL
GROUP BY
	ad_date
	, media_source
	, campaign_name	
	, adset_name;
