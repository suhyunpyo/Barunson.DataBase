IF OBJECT_ID (N'dbo.sp_ERP_Transfer_Magenta', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_ERP_Transfer_Magenta
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

-- ##########################################################################################################      
-- 티아라 매출 연동 (08.08.18 부터 티아라 매출 분리, 마젠타 매출로 잡힘)
-- ########################################################################################################## 
-- exec sp_ERP_Transfer_Magenta '20110526','20110526'
CREATE                            procedure [dbo].[sp_ERP_Transfer_Magenta]
 @SDate as char(8),
 @EDate as char(8)
as

set nocount on


--자료 Reporting을 위한 테이블 변수 생성      
Declare @erp_salesReport  Table  (      
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
	b_memo_temp	char(16) 	NULL,   --아이템 타입을 임시로 넣어 둔다.
	DeptGubun	char(2) 		NOT NULL,
	DiscountRate	numeric(28, 8) 	NULL
	 )    



--custom_order 테이블에서 대상데이터를 임시테이블에 넣음. 20090805-이상민
SELECT * 
INTO #custom_order
FROM custom_order A
WHERE A.status_Seq = 15  -- 배송완료
	and convert(char(8), A.src_send_date, 112) BETWEEN @SDate AND @EDate
	and pay_type <> '4' 
	and pg_shopid ='tiaracard1'
	
	


	
--카드정보
SELECT Card_Seq, Card_Code, CASE WHEN RTRIM(LTRIM(ISNULL(ERP_Code, ''))) = '' THEN Card_Code ELSE ERP_Code END  AS Card_ERPCode
	, Cont_Seq, Acc_Seq, Acc_seq2
INTO #CardMaster
FROM card A
WHERE  ISNULL(A.Card_Div, '') <> 'C05' --사은품 제거
Union ALL
SELECT A.Card_Seq, A.Card_Code, CASE WHEN RTRIM(LTRIM(ISNULL(A.Card_ERPCode, ''))) = '' THEN A.Card_Code ELSE A.Card_ERPCode END  AS Card_ERPCode 
	, ISNULL(B.Inpaper_seq, 0) AS Cont_Seq, ISNULL(B.Acc1_seq, 0) AS Acc_Seq, ISNULL(B.Acc2_seq, 0) AS Acc_seq2
FROM S2_Card A
LEFT JOIN S2_CardDetail B ON A.Card_Seq = B.Card_Seq
WHERE  ISNULL(A.Card_Div, '') <> 'C05' --사은품 제거




     
-- -- --1.청첩장
INSERT INTO @erp_salesReport ( 	h_biz,
				h_gubun,
				h_date,
				h_sysCode,
				h_usrCode,
				h_comcode,
				h_taxType,
				h_offerPrice,
				h_superTax,
				h_sumPrice,
				h_optionPrice,
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
				DeptGubun
			)
SELECT 
	h_biz		= 'MK10',
	h_gubun		= 'SO',
	h_date		= Convert(char(8),a.src_send_date,112),
	h_sysCode	= '270',
	h_usrCode	= '270',
	h_comcode	= '1495201',
	h_taxType	= '22',							-- 과세유형 일반과세
	h_offerPrice	=  Round(a.settle_price/1.1,0)  ,							-- 헤더 합계 금액 0으로 해 놓고 아래에서 업데이트 시킴
	h_superTax	=  Round(a.settle_price- a.settle_price/1.1,0),
	h_sumPrice	= a.settle_price,
	h_optionPrice      = 0,
	h_partCode	= '870',				
	h_staffcode	= '070802',				
	h_sonik		= '110',
	h_cost		= '152',
	h_orderid	= a.pg_tid,
	h_memo1	= null,
	h_memo2	= a.pg_tid,
	h_memo3	= null,
	b_biz		= 'MK10',
	b_goodGubun	= 'SO',
	b_seq		= 1,
	b_storeCode	= 'MF03',
	b_date		= Convert(char(8),a.src_send_date,112),
	b_goodCode	= b.card_code, --b.item_type
	b_goodUnit	= 'EA',
	b_OrderNum	= b.item_count,
	--**************************************************************************************************************
	--   * 아이템별 금액 셋팅
	--**************************************************************************************************************

	b_unitPrice	=  Case
				When b.item_Type in ('TBB','JAEBON','PANBI','EMBO','ENVINSERT','QICKDELIVERY')  Then b.item_Price				
				Else e.c_sobi
    			    End,					

	b_offerPrice	=  Case
				When b.item_Type  in ('TBB','JAEBON','PANBI','EMBO','ENVINSERT','QICKDELIVERY')  Then Round(b.item_Price/1.1,0)	
				When b.item_Type  in ('F','S','M')  and b.item_price > 0   Then 	Round(b.item_price/1.1 , 0)
				When b.item_Type  in ('F','S','M')  and b.item_price <= 0 Then 	0
				Else Round(e.c_sobi*b.item_count/1.1,0)

    			    End,	


	b_superTax	=  Case
				When b.item_Type in ('TBB','JAEBON','PANBI','EMBO','ENVINSERT','QICKDELIVERY')  Then b.item_Price - Round(b.item_Price/1.1,0)	
				When b.item_Type  in ('F','S','M')  and b.item_price > 0   Then 	b.item_price - Round(b.item_price/1.1 , 0)
				When b.item_Type  in ('F','S','M')  and b.item_price <= 0 Then 	0			
				Else (e.c_sobi*b.item_count) - Round(e.c_sobi*b.item_count/1.1,0)

    			    End,	


	b_sumPrice	=  Case
				When b.item_Type in ('TBB','JAEBON','PANBI','EMBO','ENVINSERT','QICKDELIVERY')  Then b.item_Price	
				When b.item_Type  in ('F','S','M')  and b.item_price > 0   Then 	b.item_price
				When b.item_Type  in ('F','S','M')  and b.item_price <= 0 Then 	0			
				Else (e.c_sobi)*b.item_count

    			    End,	
	------------------------------------------------------------------------------------------------------------------
		
	b_memo		= null,
	reg_date		= getdate(),
	FeeAmnt		= 0,
	ItemGubun	= 'item',
	PGCheck	    = 'N',
	PayAmnt		= 0,
	SampleCheck	= 'N',
	XartCheck	= 'N',
	SettleDate	= null,
	PayDate		= null,
	PayCheck	= null,
	DealAmnt	= null,
	b_memo_temp	= b.item_type,   --티아라 카드의 경우 동일한 카드 2장이 나가는 경우가 있음. (하나는 카드 형태 하나는 내지형태.. 하지만 코드가 같은.. 뒤에 이를 구분해 주기 위해 필요)
	DeptGubun	= 'TI'
FROM 
	#custom_order a JOIN  (
				SELECT order_seq,card_seq, card_code,item_type, item_count, item_price
				FROM 
					(
					--기본 아이템 정보 (청첩장,  청첩장과 함께 주문하는 식권, 미니청첩장, 별도로 주문하는 미니청첩장)
					SELECT  a.order_seq, b.card_seq,c.card_code, b.item_type,b.item_count as item_count ,  item_price
					FROM #custom_order a JOIN  custom_order_item b ON  a.order_seq = b.order_seq
					JOIN #CardMaster c ON b.card_seq = c.card_seq
					WHERE Convert(char(8),a.src_send_date,112) between @SDate and @EDate and pay_type <> '4' 
					and pg_shopid ='tiaracard1'  and b.item_count > 0
					and c.card_code <> 'BPC001' and c.card_code <> 'TCD01'
					--GROUP BY a.order_seq, b.card_seq, c.card_code, b.item_type, item_price
					 ) c
				
					UNION   
					--택배비
					(
					SELECT order_seq, card_seq,  'TBB', 'TBB', 1, delivery_price
					FROM #custom_order 
					WHERE 
					Convert(char(8),src_send_date,112) between @SDate and @EDate
					and delivery_price > 0
					and  status_seq = 15 
					and pay_type <> '4' 
					and pg_shopid ='tiaracard1' 
					)  
			
					UNION   
					--제본
					(
					SELECT order_seq, card_seq, 'JAEBON','JAEBON',  order_count, JEBON_price
					FROM #custom_order 
					WHERE 
					Convert(char(8),src_send_date,112) between @SDate and @EDate
					and jebon_price > 0
					and  status_seq = 15 
					and pay_type <> '4' 
					and pg_shopid ='tiaracard1' 
					)  
			
					UNION
					--추가판비   
					(
					SELECT order_seq, card_seq, 'PANBI','PANBI', 1, option_price
					FROM #custom_order 
					WHERE 
					Convert(char(8),src_send_date,112) between @SDate and @EDate
					and option_price > 0
					and  status_seq = 15 
					and pay_type <> '4' 
					and pg_shopid ='tiaracard1' 
					)  
			
					UNION
					--엠보   
					(
					SELECT order_seq, card_seq,'EMBO', 'EMBO',order_count, embo_price
					FROM #custom_order 
					WHERE 
					Convert(char(8),src_send_date,112) between @SDate and @EDate
					and embo_price > 0
					and  status_seq = 15 
					and pay_type <> '4' 
					and pg_shopid ='tiaracard1' 
					)  
					UNION   
					--봉투삽입
					(
					SELECT order_seq, card_seq,'ENVINSERT', 'ENVINSERT',order_count,  envInsert_price
					FROM #custom_order 
					WHERE 
					Convert(char(8),src_send_date,112) between @SDate and @EDate
					and envinsert_price > 0
					and  status_seq = 15 
					and pay_type <> '4' 
					and pg_shopid ='tiaracard1' 
					)  
				
					UNION
					--초특급 배송(custom_order.isSpecial='1' 그리고, custom_order.delivery_price=30000)
					(
					SELECT order_seq, card_seq,'QICKDELIVERY', 'QICKDELIVERY',order_count, delivery_price = 30000
					FROM #custom_order 
					WHERE 
					Convert(char(8),src_send_date,112) between @SDate and @EDate
					and isSpecial = '1'
					and status_seq = 15 
					and pay_type <> '4' 
					and pg_shopid ='tiaracard1' 
					)
				) b ON a.order_seq = b.order_seq
	JOIN company c ON a.company_seq = c.company_seq
	JOIN #CardMaster d ON b.card_seq = d.card_seq
	LEFT JOIN  OPENQUERY([114.111.54.142], 'SELECT  IsNull(stdPurprice,0) as stdPurprice, IsNull(c_sobi,0) as c_sobi,itemcode,itemgroup FROM XERP.DBO.itemSiteMaster WHERE SiteCode = ''BK10'' ') e ON d.card_code = e.itemCode

WHERE 
a.status_seq = 15 
and  Convert(char(8),a.src_send_date,112) between @SDate and @EDate
and pay_type <> '4' 
and pg_shopid ='tiaracard1'
--and a.src_erp_date is null  
ORDER BY a.order_seq 




	
	
	

-- --2.샘플
-- -- 샘플 매출은 자사카드는 출고가 기준 10% 할인율 적용해서 올림
-- --      "  "         타사카드는 매입가 기준으로 올림

INSERT INTO @erp_salesReport ( 	h_biz,
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
				DeptGubun
			)

SELECT 
	h_biz		= 'MK10',
	h_gubun		= 'SO',
	h_date		= Convert(char(8),a.delivery_Date,112),
	h_sysCode	= Case 
				When b.card_code = 'TBB' Then '300'  --택배비
				Else '300'
			   End,

	h_usrCode	= Case 
				When b.card_code = 'TBB' Then '308'  --택배비
				Else '308'
			   End,
	h_comcode	= '1495201',
	h_taxType	= '22',							-- 과세유형 일반과세
	h_offerPrice = Round(a.settle_price/1.1,0)  ,							-- 헤더 합계 금액 0으로 해 놓고 아래에서 업데이트 시킴
	h_superTax	 = Round(a.settle_price- a.settle_price/1.1,0),
	h_sumPrice	 = a.settle_price,
	h_partCode	 = '870',				
	h_staffcode	 = '070802',				
	h_sonik		 = '110',
	h_cost		 = '152',
	h_orderid	 = a.pg_tid,
	h_memo1	     = null,
	h_memo2	     = a.pg_tid,
	h_memo3	     = null,
	b_biz		 = 'MK10',
	b_goodGubun	 = 'SO',
	b_seq		 = 1,
	b_storeCode	 = 'MF03',
	b_date		 = Convert(char(8),a.delivery_Date,112),
	b_goodCode	 = Case 
						When b.card_code = 'TBB' Then 'TBB'  --택배비
						Else  ISNULL(e.itemcode, d.Card_ErpCode)
				    End,
	b_goodUnit	= 'EA',
	b_OrderNum	= 1,
	b_unitPrice	= Case
					When b.card_code = 'TBB' Then a.settle_price
					Else 0
				   End ,
	
	b_offerPrice	= Case
						When b.card_code = 'TBB' Then Round(a.settle_price/1.1, 0)		
						Else 0
					   End ,
	b_superTax	= Case
					When b.card_code = 'TBB' Then  Round(a.settle_price - (a.settle_price/1.1) ,0)	
					Else 0
				   End ,
	b_sumPrice	= Case
					When b.card_code = 'TBB' Then  a.settle_price	
					Else 0
				   End ,
	b_memo		= null,
	reg_date		= getdate(),
	FeeAmnt		=  dbo.getPGFee (a.pg_mertid, a.settle_method, a.settle_price,  Case
													   When pg_resultinfo like '국민%' then '국민'	
													   When pg_resultinfo like '씨티%' then '국민'		
													   When pg_resultinfo like '농협%' then '국민'	
									  				   When pg_resultinfo like '외환%' then '외환'		
													   When pg_resultinfo like '산은%' then '외환'	
													   When pg_resultinfo like '비씨%' then '비씨'
													   When pg_resultinfo like '하나%' then '비씨'
													   When pg_resultinfo like '구 LG%'   then 'LG'
													   When pg_resultinfo like '삼성%'   then '삼성'
													   When pg_resultinfo like '현대%'   then '현대'
													   When pg_resultinfo like '롯데%'   then '롯데'
													   When pg_resultinfo like '신한%'   then '신한'			
													   When pg_resultinfo like '수협%'   then '신한'				
																 When pg_resultinfo like '제주%'   then '신한'						 
													   When pg_resultinfo like '광주%'   then '신한'				
													   When pg_resultinfo like '전북%'   then '신한'	
									             End),
	ItemGubun	= 'item',
	PGCheck	= 'N',
	PayAmnt		= 0,
	SampleCheck	= 'Y',
	XartCheck	= 'N',
	SettleDate	= null,
	PayDate		= null,
	PayCheck	= null,
	DealAmnt	= null,
	b_memo_temp	= 'C',
	DeptGubun	= 'TI'
FROM 
	custom_sample_order a JOIN (SELECT sample_order_seq, card_seq, card_code, settle_price FROM  
						(SELECT a.sample_order_seq,  b.card_seq,  'item' as card_code, settle_price  FROM custom_sample_order a JOIN custom_sample_order_item b 
					      	ON a.sample_order_seq = b.sample_order_seq
						WHERE Convert(char(8),a.delivery_Date,112) between @SDate and @EDate ) c
		
						UNION

						SELECT  sample_order_seq, 1, 'TBB' as card_code, settle_price
						FROM custom_sample_order 
						WHERE Convert(char(8),delivery_Date,112) between @SDate and @EDate 

				     )  b ON a.sample_order_seq = b.sample_order_seq
	JOIN #CardMaster d ON b.card_seq = d.card_seq
	LEFT JOIN  OPENQUERY([114.111.54.142], 'SELECT  IsNull(stdPurprice,0) as stdPurprice, IsNull(c_sobi,0) as c_sobi,itemcode,itemgroup FROM XERP.DBO.itemSiteMaster WHERE SiteCode = ''BK10'' ') e ON d.card_code = e.itemCode

WHERE 
a.status_seq = 12 
and  Convert(char(8),a.delivery_Date,112) between @SDate and @EDate
and (pg_mertid ='tiaracard1' or (pg_mertid is null and Convert(char(8),a.delivery_Date,112) >= '20080820'))
and a.sales_gubun = 'A'
--and a.src_erp_date is null  
ORDER BY a.sample_order_seq 






--3. 미니청첩장 및 식권 등 옵션 상품 따로 주문시 
INSERT INTO @erp_salesReport ( 	h_biz,
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
				DeptGubun
			)
SELECT 
	h_biz		= 'MK10',
	h_gubun		= 'SO',
	h_date		= Convert(char(8),a.delivery_date,112),
	h_sysCode	= '270',
	h_usrCode	= '270',
	h_comcode	= '1495201',
	h_taxType	= '22',							-- 과세유형 일반과세
	h_offerPrice	= Round(a.settle_price/1.1,0)  ,							-- 헤더 합계 금액 0으로 해 놓고 아래에서 업데이트 시킴
	h_superTax	= Round(a.settle_price- a.settle_price/1.1,0),
	h_sumPrice	= a.settle_price,
	h_partCode	= '870',				
	h_staffcode	= '070802',				
	h_sonik		= '110',
	h_cost		= '152',
	h_orderid	= a.pg_tid,
	h_memo1	= null,
	h_memo2	= a.pg_tid,
	h_memo3	= null,
	b_biz		= 'MK10',
	b_goodGubun	= 'SO',
	b_seq		= 1,
	b_storeCode	= 'MF03',
	b_date		= Convert(char(8),a.delivery_date,112),
	b_goodCode	= d.card_code, --b.item_type
	b_goodUnit	= 'EA',
	b_OrderNum	= b.order_count,
	--**************************************************************************************************************
	--   * 아이템별 금액 셋팅
	--**************************************************************************************************************
	b_unitPrice	=  e.c_sobi,					
	b_offerPrice	=  Round(e.c_sobi*b.order_count/1.1,0),	
	b_superTax	=  (e.c_sobi*b.order_count) - Round(e.c_sobi*b.order_count/1.1,0),	
	b_sumPrice	=  e.c_sobi*b.order_count,	
	------------------------------------------------------------------------------------------------------------------

	b_memo		= null,
	reg_date		= getdate(),
	--**************************************************************************************************************
	--   * PG수수료 (PG로 넘어가는 것은 수수료를 셋팅해 준다.)
	--   pgFee getPGFee 함수 호출 (pg아이디, 결제수단, 결제금액, 카드사정보)
	--**************************************************************************************************************
	FeeAmnt		=  dbo.getPGFee (a.pg_shopid, a.settle_method, a.settle_price,  Case
									                 When pg_resultinfo like '국민%' then '국민'	
										   When pg_resultinfo like '씨티%' then '국민'		
										   When pg_resultinfo like '농협%' then '국민'	
									  	   When pg_resultinfo like '외환%' then '외환'		
									                 When pg_resultinfo like '산은%' then '외환'	
										   When pg_resultinfo like '비씨%' then '비씨'
										   When pg_resultinfo like '하나%' then '비씨'
									                 When pg_resultinfo like '구 LG%'   then 'LG'
									                 When pg_resultinfo like '삼성%'   then '삼성'
									                 When pg_resultinfo like '현대%'   then '현대'
										   When pg_resultinfo like '롯데%'   then '롯데'
										   When pg_resultinfo like '신한%'   then '신한'			
										   When pg_resultinfo like '수협%'   then '신한'				
									                 When pg_resultinfo like '제주%'   then '신한'						 
										   When pg_resultinfo like '광주%'   then '신한'				
										   When pg_resultinfo like '전북%'   then '신한'	
									             End),

	------------------------------------------------------------------------------------------------------------------
	ItemGubun	= 'item',
	PGCheck	= 'Y',
	PayAmnt		= 0,
	SampleCheck	= 'N',
	XartCheck	= 'N',
	SettleDate	= null,
	PayDate		= null,
	PayCheck	= null,
	DealAmnt	= null,
	b_memo_temp	= order_type,
	DeptGubun	= 'TI'
FROM 
	custom_etc_order a JOIN custom_etc_order_item b ON a.order_seq = b.order_seq
	JOIN company c ON a.company_seq = c.company_seq
	JOIN #CardMaster d ON b.card_seq = d.card_seq
	
	LEFT JOIN  OPENQUERY([114.111.54.142], 'SELECT  IsNull(stdPurprice,0) as stdPurprice, IsNull(c_sobi,0) as c_sobi,itemcode,itemgroup FROM XERP.DBO.itemSiteMaster WHERE SiteCode = ''BK10'' ') e ON d.card_code = e.itemCode


WHERE 	A.status_seq = 12
	and Convert(char(8),delivery_date,112) between @SDate and  @EDate
	and status_seq = 12  
	and order_type in ('F','P')
	and pg_shopid ='tiaracard1'
	--and src_erp_date is null
ORDER BY a.order_seq 




--4. e청첩장
INSERT INTO @erp_salesReport ( 	h_biz,
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
				DeptGubun
			)
SELECT 
	h_biz		= 'MK10',
	h_gubun		= 'SO',
	h_date		= Convert(char(8),settle_date,112),
	h_sysCode	= '270',
	h_usrCode	= '270',
	h_comcode	= '1495201',
	h_taxType	= '22',							-- 과세유형 일반과세
	h_offerPrice	= Round(settle_price/1.1,0)  ,							-- 헤더 합계 금액 0으로 해 놓고 아래에서 업데이트 시킴
	h_superTax	= Round(settle_price- settle_price/1.1,0),
	h_sumPrice	= settle_price,
	h_partCode	= '870',				
	h_staffcode	= '070802',				
	h_sonik		= '110',
	h_cost		= '152',
	h_orderid	= pg_tid,
	h_memo1	= null,
	h_memo2	= pg_tid,
	h_memo3	= null,
	b_biz		= 'MK10',
	b_goodGubun	= 'SO',
	b_seq		= 1,
	b_storeCode	= 'MF03',
	b_date		= Convert(char(8),settle_date,112),
	b_goodCode	= 'ON006', --b.item_type
	b_goodUnit	= 'EA',
	b_OrderNum	= 1,
	--**************************************************************************************************************
	--   * 아이템별 금액 셋팅
	--**************************************************************************************************************
	b_unitPrice	=  50000,					
	b_offerPrice	=  45455,	
	b_superTax	=  4545,	
	b_sumPrice	=  50000,	
	------------------------------------------------------------------------------------------------------------------

	b_memo		= null,
	reg_date		= getdate(),
	--**************************************************************************************************************
	--   * PG수수료 (PG로 넘어가는 것은 수수료를 셋팅해 준다.)
	--   pgFee getPGFee 함수 호출 (pg아이디, 결제수단, 결제금액, 카드사정보)
	--   pg아이디, 결제수단(1:계좌이체  2,6: 신용카드 5:핸드폰   3:가상계좌)
	--**************************************************************************************************************
	FeeAmnt		=  dbo.getPGFee (pg_shopid,  Case
							When settle_method = 'C' Then 2
							When settle_method = 'H' Then 5
 						      End,	settle_price,
						      Case
						               When pg_resultinfo like '국민%' then '국민'	
							 When pg_resultinfo like '씨티%' then '국민'		
							 When pg_resultinfo like '농협%' then '국민'	
						  	 When pg_resultinfo like '외환%' then '외환'		
						               When pg_resultinfo like '산은%' then '외환'	
							 When pg_resultinfo like '비씨%' then '비씨'
							 When pg_resultinfo like '하나%' then '비씨'
						               When pg_resultinfo like '구 LG%'   then 'LG'
						               When pg_resultinfo like '삼성%'   then '삼성'
						               When pg_resultinfo like '현대%'   then '현대'
							 When pg_resultinfo like '롯데%'   then '롯데'
							 When pg_resultinfo like '신한%'   then '신한'			
							 When pg_resultinfo like '수협%'   then '신한'				
						               When pg_resultinfo like '제주%'   then '신한'						 
							 When pg_resultinfo like '광주%'   then '신한'				
							 When pg_resultinfo like '전북%'   then '신한'	
						           End),

	------------------------------------------------------------------------------------------------------------------
	ItemGubun	= 'item',
	PGCheck	= 'Y',
	PayAmnt		= 0,
	SampleCheck	= 'N',
	XartCheck	= 'N',
	SettleDate	= null,
	PayDate		= null,
	PayCheck	= null,
	DealAmnt	= null,
	b_memo_temp      = 'EC',
	DeptGubun	= 'TI'
FROM 
	the_ewed_order 
WHERE 	AC_STATE='P' and settle_Status=2 and status_Seq=2 
	and order_result in ('3','4')
	and Convert(char(8),settle_date,112) between @SDate and  @EDate
	and pg_shopid ='tiaracard1'
	--and src_erp_date is null


--**************************************************************************************************************
--   * 할인율에 맞추어 각 아이템 금액 재계산  	
--**************************************************************************************************************
UPDATE @erp_salesReport 
SET 

	h_optionPrice = a.option_sumPrice ,
	DiscountRate  = a.discountRate,
 
	
	b_sumPrice    =	Case 
						When b.b_goodCode in ('TBB','JAEBON','PANBI','EMBO','ENVINSERT','QICKDELIVERY') Then b.b_sumPrice
						Else Round(b.b_sumPrice * (100-a.DiscountRate)/100,0)
					End,

 	b_offerPrice    = Case 
						When b.b_goodCode in ('TBB','JAEBON','PANBI','EMBO','ENVINSERT','QICKDELIVERY') Then Round(b.b_sumPrice/1.1,0)
						Else Round((b.b_sumPrice * (100-a.DiscountRate)/100)/1.1,0)
					  End,


 	b_superTax    = Case 
						When b.b_goodCode in ('TBB','JAEBON','PANBI','EMBO','ENVINSERT','QICKDELIVERY') Then Round(b.b_sumPrice - b.b_sumPrice/1.1,0)
						Else Round((b.b_sumPrice * (100-a.DiscountRate)/100)  - ((b.b_sumPrice * (100-a.DiscountRate)/100)/1.1),0)
		            End

FROM @erp_salesReport  b JOIN
	 (
	
	SELECT 
		h_orderid             = a.h_orderid,
		option_sumPrice 	= c.option_sumprice,
		b_sumPrice 	= b.b_sumprice,
		h_sumPrice 	= a.h_sumPrice,
		DiscountRate  =  Case
							When c.option_sumprice is  null  Then ((b.b_sumprice - a.h_sumprice)*100 )/b.b_sumprice
							Else (((b.b_sumprice-c.option_sumprice) - (a.h_sumprice-c.option_sumprice))*100) / (b.b_sumprice-c.option_sumprice)	
			             End
	FROM @erp_salesReport  a 
	JOIN 	( SELECT h_orderid, sum(b_offerprice) as b_offerPrice,sum(b_superTax) as b_superTax,sum(b_sumprice) as b_sumPrice 
			  FROM @erp_salesReport 
			  GROUP BY h_orderid) b  ON a.h_orderid = b.h_orderid	 --아이템 합계 금액  
		
	LEFT JOIN (	SELECT h_orderid,  sum(b_sumprice)  as option_sumPrice 
				FROM @erp_salesReport
				WHERE b_goodCode  in ('TBB','JAEBON','PANBI','EMBO','ENVINSERT','QICKDELIVERY') 
				GROUP BY h_orderid ) c ON a.h_orderid = c.h_orderid --옵션비용  합계 금액
	) a  ON a.h_orderid = b.h_orderid	
WHERE b.SampleCheck = 'N'




--**************************************************************************************************************
--b_seq를 생성해 내기 위한 템프 테이블 생성
--**************************************************************************************************************
SELECT  IDENTITY(int, 1, 1) AS seq, h_OrderID, b_goodCode,b_unitprice,b_OrderNum,b_memo_temp
INTO #TempSEQ
FROM @erp_salesReport   
--GROUP BY h_orderID, b_goodCode, b_unitPrice, b_orderNum
ORDER BY h_Orderid, b_goodcode
----------------------------------------------------------------------------------------------------------------


--주문 수량이 50매일 경우 업무 효율을 위해 100단위로 출고(정광수 차장 요청)-20111017
UPDATE #TempSEQ
SET b_OrderNum = round(b_OrderNum/100, 0)*100
where b_goodCode IN ( 'FS19', 'FS20', 'FS25', 'FS26', 'FS27', 'FS28', 'FS15', 'FS16', 'FS17', 'FS18', 'YC01', 'YC02' )



--**************************************************************************************************************
--   *  헤더와 아이템 단수조정
--**************************************************************************************************************
UPDATE @erp_salesReport
SET 	
		b_offerPrice = Case 
						 When a.h_offerPrice > b.b_offerPrice Then  a.b_offerPrice + (a.h_offerPrice - b.b_offerPrice)
						 Else a.b_offerPrice - (b.b_offerPrice - a.h_offerPrice) 
					   End,
		
		b_superTax = Case 
						 When a.h_superTax > b.b_superTax Then  a.b_superTax + (a.h_superTax - b.b_superTax)
						 Else a.b_superTax - (b.b_superTax - a.h_superTax) 
					 End,
		
		b_sumPrice = Case 
						 When a.h_sumPrice > b.b_sumPrice Then  a.b_sumPrice + (a.h_sumPrice - b.b_sumPrice)
						 Else a.b_sumPrice - (b.b_sumPrice - a.h_sumPrice) 
					 End
FROM 	@erp_salesReport  a 
JOIN 	( SELECT h_orderid,SUM(b_offerPrice) as b_offerPrice, SUM(b_superTax) as b_superTax, SUM(b_sumPrice) as b_sumPrice 
		  FROM @erp_salesReport
		  GROUP BY h_orderid
		) b ON a.h_orderid = b.h_orderid
	
JOIN 	( SELECT  A.h_OrderID, A.b_goodCode  , A.seq - B.MinSeq + 1 AS b_seq
		  FROM #TempSEQ  A JOIN ( SELECT h_OrderID, MIN(seq) AS MinSeq
								  FROM #TempSEQ
								  GROUP BY h_Orderid
								) B ON A.h_OrderID = B.h_OrderID
		) c ON a.h_orderid = c.h_orderid and a.b_goodCode = c.b_goodCode
WHERE (a.h_sumPrice <> b.b_sumPrice or a.h_offerPrice <> b.b_OfferPrice or a.h_superTax <> b.b_superTax)
	  and c.b_Seq = 1 and a.SampleCheck = 'N' and b.b_sumPrice > 0
	  



----**************************************************************************************************************
----헤더 금액 update (아이템 금액의 합계로 Update)
----**************************************************************************************************************
UPDATE @erp_salesReport
SET h_sumPrice = h_offerPrice + h_superTax, b_sumPrice = b_offerPrice + b_superTax
--UPDATE @erp_salesReport 
--SET h_offerprice = b.b_offerPrice, h_superTax = b.b_superTax
--FROM @erp_salesReport  a 
--JOIN (SELECT h_orderid, sum(b_offerprice) as b_offerPrice,sum(b_superTax) as b_superTax,sum(b_sumprice) as b_sumPrice FROM @erp_salesReport GROUP BY h_orderid) b
--ON a.h_orderid = b.h_orderid	
--WHERE a.SampleCheck = 'N'



select h_orderid 
INTO #h_orderidTemp
from OPENQUERY([222.120.91.63], 'SELECT DISTINCT h_orderid FROM MagentaERP.DBO.erp_salesData ')


--**************************************************************************************************************
-- --erp_salesData에 자료 Insert
--**************************************************************************************************************
INSERT INTO  OPENQUERY([222.120.91.63], 'SELECT  
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
					ItemGubun,					PGCheck,
					PayAmnt,
					SampleCheck,
					XartCheck,
					SettleDate,
					PayDate,
					PayCheck,
					DealAmnt,
					b_memo_temp,
					DeptGubun
					FROM MagentaERP.DBO.erp_salesData ') 
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
	b.b_OrderNum,
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
	a.DeptGubun
FROM @erp_salesReport  a  
JOIN (
		SELECT  A.h_OrderID, A.b_goodCode  , A.seq - B.MinSeq + 1 AS b_seq, a.b_orderNum,a.b_memo_temp
		FROM #TempSEQ  A 
		JOIN (
				 SELECT h_OrderID, MIN(seq) AS MinSeq
				 FROM #TempSEQ
				 GROUP BY h_Orderid
			) B ON A.h_OrderID = B.h_OrderID

) b ON a.h_orderid = b.h_orderid and a.b_goodCode = b.b_goodCode  and  a.b_memo_temp = b.b_memo_temp
LEFT JOIN #h_orderidTemp  c ON a.h_orderid = c.h_orderid	--erp_SalesData에 중복 입력 오류 방지
WHERE c.h_orderid is null


	


-- 
-- -- -- --ERP 업데이트 되었음을 표시함
-- UPDATE custom_order
-- SET src_erp_date = Convert(char(10),getdate(),120)
-- WHERE 	status_seq = 15 
-- 	and  Convert(char(8),src_send_date,112) between @SDate and @EDate
-- 	and pay_type <> '4' 
-- 	and pg_shopid ='tiaracard1'
-- 	and src_erp_date is null  
-- 
-- 
-- UPDATE custom_sample_order
-- SET src_erp_date = Convert(char(10),getdate(),120)
-- WHERE  status_seq = 12 
-- 	and  Convert(char(8),delivery_Date,112) between @SDate and @EDate
-- 	and sales_gubun = 'A'
-- 	and src_erp_date is null  
-- 
--  
-- UPDATE custom_etc_order
-- SET src_erp_date = Convert(char(10),getdate(),120)
-- WHERE 	status_seq = 12
-- 	and Convert(char(8),delivery_date,112) between @SDate and  @EDate
-- 	and order_type in ('F','P')
-- 	and pg_shopid ='tiaracard1'
-- 	and src_erp_date is null

--UPDATE the_ewed_order 
--SET src_erp_date = Convert(char(10),getdate(),120)
--WHERE  AC_STATE='P' and settle_Status=2 and status_Seq=2 
--	and order_result in ('3','4')
--	and Convert(char(8),settle_date,112) between @SDate and  @EDate
--	and pg_shopid ='tiaracard1'


GO
