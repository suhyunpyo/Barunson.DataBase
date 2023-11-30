IF OBJECT_ID (N'dbo.V_order_list_v2', N'V') IS NOT NULL DROP View dbo.V_order_list_v2
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[V_order_list_v2]
AS
SELECT 'S' AS order_case, --'샘플' AS order_type_str, 
	a.sample_order_seq AS order_seq, request_date AS order_Date, status_seq, --dbo.get_code_value('sample_status_seq', status_seq) AS status_seq_str, 
	settle_price, settle_method, pg_tid, pg_mertid AS pg_shopid, pg_resultinfo, pg_resultinfo2, settle_date, 
	delivery_date, delivery_com, --delivery_code_num AS delivery_code, 
	member_id, company_seq, MEMBER_NAME, member_email, 
	0 AS up_order_seq--, (select COUNT(sample_order_seq) from CUSTOM_SAMPLE_ORDER_ITEM with(nolock) where sample_order_seq=a.sample_order_seq) as unit_cnt
FROM CUSTOM_SAMPLE_ORDER a WITH (NOLOCK)
--WHERE status_seq >= 1
UNION ALL
SELECT 'E' AS order_case, --dbo.get_code_value('item_type', order_type) AS order_type_str, 
	order_seq, order_date, status_seq, --dbo.get_code_value('etc_status_seq', status_seq) AS status_seq_str, 
	settle_price, settle_method, pg_tid, pg_shopid, pg_resultinfo, pg_resultinfo2, settle_date, 
	delivery_date, delivery_com, --delivery_code, 
	member_id, company_seq, order_name  AS MEMBER_NAME, order_email AS member_email, 
	0 AS up_order_seq --, 0 as unit_cnt
FROM custom_etc_order WITH (NOLOCK)
--WHERE order_type NOT IN ('D', 'K', 'B', 'R') --AND status_seq >= 1 20171030 답례품때문에 변경
WHERE order_type NOT IN ('R') --AND status_seq >= 1 
UNION ALL
SELECT order_type AS order_case, --dbo.get_code_value('worder_type', order_type) AS order_type_str, 
order_seq, order_date, status_seq, --dbo.get_code_value('status_seq', status_seq) AS status_seq_str, 
last_total_price AS settle_price, settle_method, pg_tid, pg_shopid, pg_resultinfo, pg_resultinfo2, settle_date, 
NULL AS delivery_date, '' AS delivery_com, --(select top 1 DELIVERY_CODE_NUM from DELIVERY_INFO where order_seq=a.order_seq) AS delivery_code, 
member_id, company_seq, order_name  AS MEMBER_NAME, order_email AS member_email, 
a.up_order_seq --, 0 as unit_cnt
FROM custom_order a WITH (NOLOCK) 
	JOIN s2_card b WITH (NOLOCK) ON a.card_seq = b.card_seq
WHERE pay_type <> '4' AND order_type <> '4' --AND status_Seq >= 0


GO
