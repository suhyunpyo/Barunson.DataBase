IF OBJECT_ID (N'dbo.sp_ERP_BillCompare', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_ERP_BillCompare
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE     procedure [dbo].[sp_ERP_BillCompare]
--exec sp_ERP_BillCompare '20081101','20081125'
 @SDate as char(8),
 @EDate as char(8)
as

SET NOCOUNT ON


--########################################################################################
--빠른손 매출 데이터 취합
--########################################################################################
Declare @ShopData  Table  (      
	h_orderid		nvarchar(20) 	 NOT NULL,
	h_sumPrice		numeric(28, 8) 	 NULL,
	h_date			char(8)			 NOT NULL
)

INSERT INTO @ShopData (h_orderid, h_sumPrice,h_date)
	--청첩장
	SELECT 
		order_seq, settle_price, Convert(char(8),src_send_date,112) 
	FROM CUSTOM_ORDER a JOIN Card b ON a.card_seq = b.card_seq
	WHERE a.status_seq = 15 and Convert(char(8),a.src_send_date,112) between @SDate and @EDate
		and pay_type <> '4' 
		and (sales_gubun in ('W','T','U','A','J','B','S','X') or (a.company_Seq = 237 and a.sales_gubun ='D' and b.company = 8))
		and a.pg_shopid <> 'tiaracard1' 

	UNION ALL

	--샘플
	SELECT 
		sample_order_seq, settle_price,Convert(char(8),delivery_date,112) 
	FROM custom_sample_order 
	WHERE status_Seq= 12 and sales_gubun in ('W','T','U','B','S') 
	and Convert(char(8),delivery_date,112) between @SDate and @EDate
	and pg_mertid <> 'tiaracard1' 

	UNION ALL

	--식권&연하 시판 샘플
	SELECT 
		order_Seq,settle_price,Convert(char(8),delivery_date,112) 
	FROM custom_etc_order 
	WHERE status_seq=12 and order_Type in ('F','P','C','S') and sales_gubun <> 'D' 
		and Convert(char(8),delivery_date,112) between @SDate and @EDate
		and pg_shopid <> 'tiaracard1' 
	
	UNION ALL
	--e청첩장
	SELECT order_id, settle_price,Convert(char(8),settle_date,112)
	FROM the_ewed_order 
	WHERE AC_STATE='P' and settle_Status=2 and status_Seq=2 and order_result in ('3','4') 
		and Convert(char(8),settle_date,112) between @SDate and @EDate
		and sales_gubun in ('U','T','W','J','B') 
	


--########################################################################################
--ERP 데이터 취합
--########################################################################################
Declare @ErpData  Table  (      
	h_oldid				nvarchar(20) 	 NOT NULL,
	h_orderid			nvarchar(20) 	 NOT NULL,
	h_sumPrice			numeric(28, 8) 	 NULL,
	h_date				char(8)			 NULL
)
INSERT INTO @ErpData (h_oldid,h_orderid, h_sumPrice, h_date)
SELECT h_orderid
	,h_orderid =   Case 
						When h_orderid like 'ICS%' Then Replace(h_orderid,'ICS','') 
						When h_orderid like 'IC%' Then  Replace(h_orderid,'IC','') 
						When h_orderid like 'IS%' Then  Replace(h_orderid,'IS','') 
						When h_orderid like 'EW%' Then  Replace(h_orderid,'EW','') 
						When h_orderid like 'D%'  Then  Replace(h_orderid,'D','') 
						When h_orderid like 'ET%' Then  Replace(h_orderid,'ET','') 
						When h_orderid like 'SC%' Then  Replace(h_orderid,'SC','') 
						Else h_orderid
					End 
		, h_sumPrice, h_date 
FROM [211.172.242.78].XERP.DBO.erp_salesData 
WHERE h_partCode in ('380','390','395','450','510','550') and	h_date BETWEEN @SDate and @EDate



--########################################################################################
--통합 데이터 (빠른손 + ERP) 
--########################################################################################
Declare @TotalData  Table  (      
	h_orderid		nvarchar(20) 	 NOT NULL,
	h_sumPrice		numeric(28, 8) 	 NULL,
	h_date			char(8)			 NULL
)

INSERT INTO @TotalData (h_orderid, h_sumPrice, h_date)
	SELECT h_orderid, h_sumPrice, h_date FROM @ShopData 

	UNION

	SELECT h_orderid, h_sumPrice, h_date FROM @ErpData 




--########################################################################################
--매출비교
--########################################################################################
SELECT Distinct
	a.h_orderid, a.h_sumPrice, a.h_date, b.h_orderid, b.h_sumPrice, b.h_date, c.h_orderid, c.h_sumPrice, c.h_date
FROM (SELECT distinct h_orderid, h_sumprice, h_date FROM @TotalData) a LEFT JOIN @ShopData b
	ON a.h_orderid = b.h_orderid 
	LEFT JOIN @ErpData c
	ON a.h_orderid = c.h_orderid			
WHERE (b.h_orderid is null or c.h_orderid is null) or (b.h_sumPrice <> c.h_sumPrice)
ORDER BY a.h_date , a.h_orderid




GO
