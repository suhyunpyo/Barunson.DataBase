IF OBJECT_ID (N'dbo.sp_ERP_Transfer_Photobook', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_ERP_Transfer_Photobook
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE            procedure [dbo].[sp_ERP_Transfer_Photobook]
 @SDate as char(8),
 @EDate as char(8)
as

set nocount on




-- EXEC sp_ERP_Transfer_Photobook '20120701','20120716' 



--자료 Reporting을 위한 임시 테이블 생성      
Declare @Report  Table  (      
	h_biz		nvarchar(4)	NOT NULL,
	h_gubun		nvarchar(2)	NOT NULL,
	h_date		nvarchar(8)	NOT NULL,
	h_sysCode	nvarchar(3)	NOT NULL,
	h_usrCode	nvarchar(3)	NOT NULL,
	h_comcode	nvarchar(8)	NOT NULL,  
	h_taxType	nvarchar(2)	NOT NULL,
	h_offerPrice	numeric(28,8)	NULL,
	h_superTax	numeric(28,8)	NULL,
	h_sumPrice	numeric(28,8)	NULL,
	h_optionPrice	numeric(28,8)	NULL,
	h_partCode	nvarchar(8)	NOT NULL,
	h_staffcode	nvarchar(8)	NOT NULL,
	h_sonik		nvarchar(8) 	NOT NULL,
	h_cost		nvarchar(8) 	NOT NULL,
	h_orderid	nvarchar(20) 	NOT NULL,
	h_memo1	nvarchar(20) 	NULL,
	h_memo2	nvarchar(50) 	NOT NULL,
	h_memo3	nvarchar(20) 	NULL,
	b_biz		nvarchar(4) 	NOT NULL,
	b_goodGubun	nvarchar(2) 	NOT NULL,
	b_seq		smallint		NOT NULL,
	b_storeCode	nvarchar(4) 	NOT NULL,
	b_date		nvarchar(8) 	NOT NULL,
	b_goodCode	nvarchar(20)	NOT NULL,
	b_goodUnit	nvarchar(4) 	NOT NULL,
	b_OrderNum	int		NOT NULL,
	b_unitPrice	numeric(28, 8) 	NULL,
	b_offerPrice	numeric(28, 8) 	NULL,
	b_superTax	numeric(28, 8) 	NULL,
	b_sumPrice	numeric(28, 8) 	NULL,
	b_memo		char(16) 	NULL,
	reg_date		smalldatetime	NOT NULL,
	FeeAmnt		numeric(28, 8) 	NOT NULL,
	ItemGubun	nchar(4) 	NOT NULL,
	PGCheck	nchar(1) 	NOT NULL,
	PayAmnt		numeric(28, 8) 	NOT NULL,
	SampleCheck	nchar(1) 	NOT NULL,
	XartCheck	nchar(1) 	NOT NULL,
	SettleDate	nchar(8) 	NULL,
	PayDate		nchar(8) 	NULL,
	PayCheck	char(1) 		NULL,
	DealAmnt	numeric(18, 0) 	NULL,
	b_memo_temp	char(16) 	NULL,
	DeptGubun	char(2) 		NOT NULL,
	DiscountRate	numeric(28, 8) 	NULL,
	InoutCheck	nchar(1) 	NULL
	 )    


INSERT INTO @Report  (
	h_biz,h_gubun,h_date,h_sysCode,h_usrCode,h_comcode,h_taxType,h_offerPrice,h_superTax,h_sumPrice,h_optionPrice,
	h_partCode,h_staffcode,h_sonik,h_cost,h_orderid,h_memo1,h_memo2,h_memo3,
	b_biz,b_goodGubun,b_seq,b_storeCode,b_date,b_goodCode,b_goodUnit,b_OrderNum,b_unitPrice,b_offerPrice,b_superTax,b_sumPrice,
	b_memo,reg_date,FeeAmnt,ItemGubun,PGCheck,PayAmnt,SampleCheck,XartCheck,SettleDate,PayDate,PayCheck,DealAmnt,b_memo_temp,DeptGubun,InoutCheck
)

SELECT 
	h_biz 			= 'BK10',
	h_gubun 		= 'SO',
	h_date 			= Convert(char(8),delivery_date,112),
	syscode 		= '270' ,
	usrCode 		= '270'  , 	
	h_comcode 		= CASE WHEN site_code IN ( '3', '4') THEN '1495518' ELSE '1450064' END , --site_code  IN ( '3', '4') 롯데관광개발(주)
	h_TaxType 		= CASE WHEN site_code  IN ( '3', '4') THEN '10' ELSE '22' END , --site_code  IN ( '3', '4') 롯데관광개발(주) 일반과세
	h_offerPrice 	= CASE WHEN site_code  IN ( '3', '4') THEN 16000 ELSE  ROUND(CAST(settle_price/1.1 as int), 0) END , --site_code  IN ( '3', '4') 롯데관광개발(주) 금액 16000
	h_superTax 		= CASE WHEN site_code  IN ( '3', '4') THEN 1600 ELSE  settle_price - ROUND((CAST(settle_price/1.1 as int)), 0) END , --site_code  IN ( '3', '4') 롯데관광개발(주) 금액 1600
	h_sumPrice 		= CASE WHEN site_code  IN ( '3', '4') THEN 16000+1600 ELSE  settle_price END , --site_code  IN ( '3', '4') 롯데관광개발(주) 금액 16000+1600
	h_optionPrice   = 0,
	h_partCode 		= '880',
	h_staffCode 	= '110401',  --'030603',
	h_sonik 		= '110',
	h_cost 			= '116',
	h_orderid 		= CASE WHEN site_code  IN ( '3', '4') THEN 'PB'+convert( nchar(8), a.id) ELSE  pg_tid END , --site_code  IN ( '3', '4') 롯데호텔 금액 ,
	h_memo1			= null,
	h_memo2 		= CASE WHEN site_code  IN ( '3', '4') THEN 'PB'+convert( nchar(8), a.id) ELSE  pg_tid END , --site_code  IN ( '3', '4') 롯데호텔
	h_memo3			= null,
	b_biz 			= 'BK10',
	b_goodGubun 	= 'SO',
	b_seq 			= 1,	
	b_storeCode 	= 'MF03',
	b_date 			=  Convert(char(8),delivery_date,112),
	b_goodCode 		=  Case When c.itemCode = 'TBB' Then 'TBB' Else erp_code End,
	b_goodUnit 		= 'EA',
	--할인율
	--disrate  = (-reduce_price*100)/(settle_price - reduce_price),
	b_orderNum 		=  SUM(item_count)  ,
	
	b_unitPrice 	= CASE WHEN site_code  IN ( '3', '4') THEN 16000 ELSE  Case When c.itemCode = 'TBB' Then ROUND(2500/1.1, 0) Else c.item_price End END ,	
	
	b_offerPrice 	= CASE WHEN site_code  IN ( '3', '4') THEN 16000 ELSE  CASE WHEN c.itemCode = 'TBB' Then ROUND(2500/1.1, 0)
								ELSE CASE WHEN SUM(item_count) <> 0 THEN ROUND(c.item_price*SUM(item_count)/1.1, 0) ELSE ROUND(c.item_price*COUNT(*)/1.1, 0) END END END,	--이상민 count(*) ==> SUM(item_count) 바꿈_20090619
	
	b_superTax 		= CASE WHEN site_code  IN ( '3', '4') THEN 1600 ELSE  CASE WHEN c.itemCode = 'TBB' Then (2500 - (ROUND(2500/1.1 , 0)))	
						ELSE  CASE WHEN SUM(item_count) <> 0 THEN (c.item_price*SUM(item_count) - (ROUND(c.item_price*SUM(item_count)/1.1 , 0))) ELSE (c.item_price*COUNT(*) - (ROUND(c.item_price*COUNT(*)/1.1, 0))) END END END , --site_code  IN ( '3', '4') 롯데호텔
	
	b_sumPrice 		= CASE WHEN site_code  IN ( '3', '4') THEN 16000+1600 ELSE CASE WHEN c.itemCode = 'TBB' Then 2500 
						ELSE CASE WHEN SUM(item_count) <> 0 THEN c.item_price*SUM(item_count) ELSE c.item_price*COUNT(*) END END END,		--이상민 count(*) ==> SUM(item_count) 바꿈_20090619
	b_memo			= null,
	reg_date			= getdate(),
			
	FeeAmnt			= dbo.getPGFee_New ('zzico', settle_method, settle_price), --2009년 3월 16일 결제부터 새로운 PG수수료율 적용			
	itemGubun 		= 'item',
	PGCheck 		= CASE WHEN site_code  IN ( '3', '4') THEN 'N' ELSE  'Y' END , --site_code  IN ( '3', '4') 롯데호텔
	PayAmnt			= 0,
	SampleCheck 	= 'N',
	XartCheck 		= 'Y',
	SettleDate		= null,
	PayDate			= null,
	PayCheck		= null,
	DealAmnt		= null,
	b_memo_temp		= null,
	DeptGubun 		= 'ZI',
	InoutCheck		= 'Y'
		     
FROM  photobook_order a 
join photobook_order_detail_erp b ON a.id = b.order_id 
LEFT JOIN   
	--택배비
	(
	SELECT id, erp_code as itemCode, b.item_price as item_price, b.product_order_id
	FROM  photobook_order a JOIN photobook_order_detail_erp b ON a.id = b.order_id
	WHERE  Convert(char(8),delivery_date,112) between @SDate and @EDate  	
	UNION
	SELECT id,'TBB' as itemCode, delivery_price as item_price, b.product_order_id
	FROM  photobook_order a JOIN photobook_order_detail_erp b ON a.id = b.order_id
	WHERE  Convert(char(8),delivery_date,112) between @SDate and @EDate and  delivery_price > 0	
	)  c
ON a.id  = c.id and ( b.product_order_id = c.product_order_id or c.itemCode = 'TBB' )

WHERE status_seq = 12 
--and src_erp_date is null 
and pay_type <> 4 --사고건이 아닌것
and Convert(char(8),delivery_date,112) between @SDate and @EDate
GROUP BY a.pg_tid, b.erp_code, a.settle_price,a.delivery_price, a.delivery_date,a.settle_method, a.pg_resultinfo,b.item_sale_price,a.order_price,c.item_price, c.itemCode
		, site_code,a.id
ORDER BY  pg_tid  DESC




--select * from @Report where h_orderid = 'PB17375'

--########################################################################################
--기초데이터에서 필요한 데이터 Update
--########################################################################################
UPDATE @Report
SET 
	b_sumPrice = Case
			When a.b_goodCode = 'TBB' Then a.b_sumPrice
			Else Round(a.b_sumPrice * (100-b.DiscountRate)/100, 0)
		         End,
    b_unitPrice = Case
			When a.b_goodCode= 'TBB' Then Round(a.b_sumPrice/1.1, 0)
			Else Round( ((a.b_sumPrice * (100-b.DiscountRate)/100)/1.1) / a.b_OrderNum, 0)	
		         End,	
	b_offerPrice = Case
			When a.b_goodCode= 'TBB' Then Round(a.b_sumPrice/1.1, 0)
			Else Round((a.b_sumPrice * (100-b.DiscountRate)/100)/1.1, 0)	
		         End,
	b_superTax = Case
			When a.b_goodCode = 'TBB' Then Round(a.b_sumPrice - a.b_sumPrice/1.1, 0)
			Else Round(a.b_sumPrice * (100-b.DiscountRate)/100, 0)  - Round((a.b_sumPrice * (100-b.DiscountRate)/100)/1.1, 0)	
		         End	
FROM @Report a 
JOIN (
		SELECT
			h_orderid		= a.h_orderid,
			option_sumPrice = ISNULL(c.option_sumprice, 0),
			b_sumprice		= b.b_sumPrice,
			h_sumPrice		= a.h_sumPrice-ISNULL(c.option_sumprice, 0),
			DiscountRate	= (b.b_sumprice - (a.h_sumPrice-ISNULL(c.option_sumprice, 0)))*100 / b.b_sumprice
		FROM @Report a	
			JOIN 		(
					SELECT h_orderid, sum(b_offerprice) as b_offerPrice,sum(b_superTax) as b_superTax,sum(b_sumprice) as b_sumPrice 
					FROM @Report 
					WHERE  b_goodCode  <> 'TBB'		--이상민추가
					GROUP BY h_orderid
				              ) b --아이템 합계 금액  	
					ON a.h_orderid = b.h_orderid	
			LEFT JOIN 
					(
					SELECT h_orderid,  sum(b_sumprice)  as option_sumPrice 
					FROM @Report
					WHERE b_goodCode  = 'TBB'
					GROUP BY h_orderid
				              ) c --옵션비용  합계 금액
				 	ON a.h_orderid = c.h_orderid	
	
	) b  ON a.h_orderid = b.h_orderid	


--select * from @Report where h_orderid = 'PB17375'





--**************************************************************************************************************
--b_seq를 생성해 내기 위한 템프 테이블 생성
--**************************************************************************************************************
SELECT  IDENTITY(int, 1, 1) AS seq, h_OrderID, b_goodCode,b_unitprice
INTO #TempSEQ
FROM @Report   
ORDER BY h_Orderid, b_goodcode
----------------------------------------------------------------------------------------------------------------




--**************************************************************************************************************
--   *  헤더와 아이템 단수조정
--**************************************************************************************************************
UPDATE @Report
SET 	
	b_sumPrice = Case 
			When a.h_sumPrice > b.b_sumPrice Then  a.b_sumPrice + (a.h_sumPrice - b.b_sumPrice)
			Else a.b_sumPrice - (b.b_sumPrice - a.h_sumPrice) 
		          End
FROM 	@Report  a 
JOIN 	(	SELECT h_orderid,sum(b_offerPrice) as b_offerPrice,sum(b_superTax) as b_superTax,sum(b_sumPrice) as b_sumPrice FROM @Report
		GROUP BY h_orderid
	) b ON a.h_orderid = b.h_orderid
JOIN 	(
		SELECT  A.h_OrderID, A.b_goodCode , A.seq - B.MinSeq + 1 AS b_seq
		FROM #TempSEQ  A JOIN (
					 SELECT h_OrderID, MIN(seq) AS MinSeq
					 FROM #TempSEQ
					 GROUP BY h_Orderid
					) B ON A.h_OrderID = B.h_OrderID
	 ) c ON a.h_orderid = c.h_orderid and a.b_goodCode = c.b_goodCode 
WHERE a.h_sumPrice <> b.b_sumPrice and c.b_Seq = 1
----------------------------------------------------------------------------------------------------------------

--select * from @Report where h_orderid = 'PB17375'

--**************************************************************************************************************
--헤더 금액 update (아이템 금액의 합계로 Update)
--**************************************************************************************************************
UPDATE @Report 
SET h_offerprice = b.b_offerPrice, h_superTax = b.b_superTax
FROM @Report  a 
JOIN (SELECT h_orderid, sum(b_offerprice) as b_offerPrice,sum(b_superTax) as b_superTax,sum(b_sumprice) as b_sumPrice FROM @Report GROUP BY h_orderid) b
ON a.h_orderid = b.h_orderid	
----------------------------------------------------------------------------------------------------------------




--select a.*
--FROM @Report  a 
--JOIN (
--		SELECT  A.h_OrderID, A.b_goodCode, A.b_unitPrice  , A.seq - B.MinSeq + 1 AS b_seq
--		FROM #TempSEQ  A 
--			JOIN (
--						 SELECT h_OrderID, MIN(seq) AS MinSeq
--						 FROM #TempSEQ
--						 GROUP BY h_Orderid
--					) B ON A.h_OrderID = B.h_OrderID
-- ) b ON a.h_orderid = b.h_orderid and a.b_goodCode = b.b_goodCode AND A.b_unitPrice = b.b_unitPrice
--LEFT JOIN OPENQUERY([erpdb.bhandscard.com], 'SELECT DISTINCT h_orderid FROM XERP.DBO.erp_salesData ' )  c ON a.h_orderid = c.h_orderid	
	
--WHERE c.h_orderid is null 

--goto GG


--**************************************************************************************************************
--Erp_salesData에 Insert
--**************************************************************************************************************
INSERT INTO  OPENQUERY([erpdb.bhandscard.com], 'SELECT  
					h_biz,
					h_gubun,
					h_date,
					h_sysCode,
					h_usrCode,
					h_comcode,
					h_taxType,
					h_offerPrice,
					h_superTax,
					h_sumPrice,
					h_partCode,
					h_staffcode,
					h_sonik,
					h_cost,
					h_orderid,
					h_memo1,
					h_memo2,
					h_memo3,
					b_biz,
					b_goodGubun,
					b_seq,
					b_storeCode,
					b_date,
					b_goodCode,
					b_goodUnit,
					b_OrderNum,
					b_unitPrice,
					b_offerPrice,
					b_superTax,
					b_sumPrice,
					b_memo,
					reg_date,
					FeeAmnt,
					ItemGubun,
					PGCheck,
					PayAmnt,
					SampleCheck,
					XartCheck,
					SettleDate,
					PayDate,
					PayCheck,
					DealAmnt,
					b_memo_temp,
					DeptGubun,
					InoutCheck					

					FROM XERP.DBO.erp_salesData ') 
SELECT  
	a.h_biz,
	a.h_gubun,
	a.h_date,
	a.h_sysCode,
	a.h_usrCode,
	a.h_comcode,
	a.h_taxType,
	a.h_offerPrice,
	a.h_superTax,
	a.h_sumPrice,
	a.h_partCode,
	a.h_staffcode,
	a.h_sonik,
	a.h_cost,
	a.h_orderid,
	a.h_memo1,
	a.h_memo2,
	a.h_memo3,
	a.b_biz,
	a.b_goodGubun,
	b.b_seq,
	a.b_storeCode,
	a.b_date,
	a.b_goodCode,
	a.b_goodUnit,
	a.b_OrderNum,
	a.b_unitPrice,
	a.b_offerPrice,
	a.b_superTax,
	a.b_sumPrice,
	a.b_memo,
	a.reg_date,
	a.FeeAmnt,
	a.ItemGubun,
	a.PGCheck,
	a.PayAmnt,
	a.SampleCheck,
	a.XartCheck,
	a.SettleDate,
	a.PayDate,
	a.PayCheck,
	a.DealAmnt,
	a.b_memo_temp,
	a.DeptGubun,
	a.InoutCheck
FROM @Report  a 
JOIN (
		SELECT  A.h_OrderID, A.b_goodCode, A.b_unitPrice  , A.seq - B.MinSeq + 1 AS b_seq
		FROM #TempSEQ  A JOIN (
					 SELECT h_OrderID, MIN(seq) AS MinSeq
					 FROM #TempSEQ
					 GROUP BY h_Orderid
					) B ON A.h_OrderID = B.h_OrderID
	         ) b ON a.h_orderid = b.h_orderid and a.b_goodCode = b.b_goodCode AND A.b_unitPrice = b.b_unitPrice
	     LEFT JOIN OPENQUERY([erpdb.bhandscard.com], 'SELECT DISTINCT h_orderid FROM XERP.DBO.erp_salesData WHERE h_partCode = ''880'''		--erp_SalesData에 중복 입력 오류 방지
	     
	)  c ON a.h_orderid = c.h_orderid	
	
WHERE c.h_orderid is null
----------------------------------------------------------------------------------------------------------------


--GG:

/*
--**************************************************************************************************************
--ERP 업데이트 되었음을 표시함
--**************************************************************************************************************
UPDATE photobook_order
SET src_erp_date = getdate()
WHERE status_seq = 12 
and src_erp_date is null 
and delivery_date between @SDate and @EDate

*/


GO
