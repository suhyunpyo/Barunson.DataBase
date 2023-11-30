IF OBJECT_ID (N'dbo.sp_ERP_Transfer_Shop_S2_eCardOrder', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_ERP_Transfer_Shop_S2_eCardOrder
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
-- ##########################################################################################################      
-- 영업2본부 매출 연동
-- 업데이트내역
   -- 1. 2009.06.03
   --==> 샘플 출고시 내지정보와 악세사리 정보도 함께 출력되도록 적용 
-- ########################################################################################################## 


--SP_LOCK
-- EXEC sp_ERP_Transfer_Shop_S2_eCardOrder '20100917','20100917'


CREATE PROCEDURE [dbo].[sp_ERP_Transfer_Shop_S2_eCardOrder]
 @SDate as char(8)
 , @EDate as char(8)

AS
SET NOCOUNT ON




DECLARE @Syscode1 as char(3),@UsrCode1 as char(3) --정상출고 (270,270)
Set @SysCode1 = '270'
Set @UsrCode1 = '270'

DECLARE @Syscode2 as char(3),@UsrCode2 as char(3) --예외출고(판매촉진비)  (300,322)
Set @SysCode2 = '300'
Set @UsrCode2 = '322'

DECLARE @Syscode3 as char(3),@UsrCode3 as char(3) --예외출고(샘플-영업3팀) (300,308)
Set @SysCode3 = '300'
Set @UsrCode3 = '308'



--자료 Reporting을 위한 테이블 변수 생성      
CREATE   Table #erp_salesReport  (      
			h_biz		nvarchar(4)			NOT NULL,
			h_gubun		nvarchar(2)			NOT NULL,
			h_date		nvarchar(8)			NOT NULL,
			h_sysCode	nvarchar(3)			NOT NULL,
			h_usrCode	nvarchar(3)			NOT NULL,
			h_comcode	nvarchar(20)		NOT NULL,  
			h_taxType	nvarchar(2)			NOT NULL,
			h_offerPrice	numeric(28,8)	NULL,
			h_superTax	numeric(28,8)		NULL,
			h_sumPrice	numeric(28,8)		NULL,
			h_optionPrice	numeric(28,8)	NULL,
			h_partCode	nvarchar(8)			NOT NULL,
			h_staffcode	nvarchar(8)			NOT NULL,
			h_sonik		nvarchar(8) 		NOT NULL,
			h_cost		nvarchar(8) 		NOT NULL,
			h_orderid	nvarchar(20) 		NOT NULL,
			h_memo1	nvarchar(20) 			NULL,
			h_memo2	nvarchar(50) 			NULL,
			h_memo3	nvarchar(20) 			NULL,
			
			b_biz		nvarchar(4) 		NOT NULL,
			b_goodGubun	nvarchar(2) 		NOT NULL,
			b_seq		smallint			NOT NULL,
			b_storeCode	nvarchar(4) 		NOT NULL,
			b_date		nvarchar(8) 		NOT NULL,
			b_goodCode	nvarchar(20)		NOT NULL,
			b_goodUnit	nvarchar(4) 		NOT NULL,
			b_OrderNum	int					NOT NULL,
			b_unitPrice	numeric(28, 8) 		NULL,
			b_offerPrice	numeric(28, 8) 	NULL,
			b_superTax	numeric(28, 8) 		NULL,
			b_sumPrice	numeric(28, 8) 		NULL,
			b_memo		char(16) 			NULL,
			reg_date		smalldatetime	NOT NULL,
			FeeAmnt		numeric(28, 8) 		NOT NULL,
			ItemGubun	nchar(4) 			NOT NULL,
			PGCheck	nchar(1) 				NOT NULL,
			PayAmnt		numeric(28, 8) 		NOT NULL,
			SampleCheck	nchar(1) 			NOT NULL,
			XartCheck	nchar(1) 			NOT NULL,
			SettleDate	nchar(8) 			NULL,
			PayDate		nchar(8) 			NULL,
			PayCheck	char(1) 			NULL,
			DealAmnt	numeric(18, 0) 		NULL,
			b_memo_temp	char(16) 			NULL,
			DeptGubun	char(2) 			NULL,
			DiscountRate	numeric(28, 8) 	NULL
		 )    
     


----**************************************************************************************************************
----1.청첩장
----**************************************************************************************************************

--custom_order 테이블에서 대상데이터를 임시테이블에 넣음. 20090805-이상민
SELECT * 
INTO #custom_order
FROM custom_order A
WHERE A.status_Seq = 15  -- 배송완료
	and convert(char(8), A.src_send_date, 112) BETWEEN @SDate AND @EDate
	and A.sales_gubun in ('W','T','U','J','B','S','X','G', 'SB', 'SW', 'SS', 'SP', 'SH') 
	
	
	
		
--카드정보
SELECT Card_Seq, Card_Code, CASE WHEN RTRIM(LTRIM(ISNULL(ERP_Code, ''))) = '' THEN Card_Code ELSE ERP_Code END  AS Card_ERPCode
	, Cont_Seq, Acc_Seq, Acc_seq2
INTO #CardMaster
FROM Card A
WHERE  ISNULL(A.Card_Div, '') <> 'C05' --사은품 제거
Union ALL
SELECT A.Card_Seq, A.Card_Code, CASE WHEN RTRIM(LTRIM(ISNULL(A.Card_ERPCode, ''))) = '' THEN A.Card_Code ELSE A.Card_ERPCode END  AS Card_ERPCode 
	, ISNULL(B.Inpaper_seq, 0) AS Cont_Seq, ISNULL(B.Acc1_seq, 0) AS Acc_Seq, ISNULL(B.Acc2_seq, 0) AS Acc_seq2
FROM S2_Card A
LEFT JOIN S2_CardDetail B ON A.Card_Seq = B.Card_Seq
WHERE  ISNULL(A.Card_Div, '') <> 'C05' --사은품 제거


--기준정보 셋팅
SELECT 'W' AS sales_gubun,  '1450002' AS h_comcode, '510'  AS h_partCode, '030603' AS h_staffcode, '117' AS h_cost, 'Y' AS PGCheck, 'BA' AS DeptGubun , '' AS Company_seq
INTO #sales_gubunTemp UNION ALL
SELECT 'T' AS sales_gubun,  '1450005' AS h_comcode, '380'  AS h_partCode, '100906' AS h_staffcode, '143' AS h_cost, 'Y' AS PGCheck, 'TH' AS DeptGubun , '' AS Company_seq UNION ALL
SELECT 'U' AS sales_gubun,  '17577'	  AS h_comcode, '550'  AS h_partCode, '100906' AS h_staffcode, '149' AS h_cost, 'N' AS PGCheck, 'TU' AS DeptGubun , '' AS Company_seq UNION ALL
SELECT 'S' AS sales_gubun,  '1450065' AS h_comcode, '450'  AS h_partCode, '100906' AS h_staffcode, '163' AS h_cost, 'Y' AS PGCheck, 'SI' AS DeptGubun , '' AS Company_seq UNION ALL
SELECT 'X' AS sales_gubun,  '1450003' AS h_comcode, '395'  AS h_partCode, '030603' AS h_staffcode, '153' AS h_cost, 'Y' AS PGCheck, 'TI' AS DeptGubun , '' AS Company_seq UNION ALL
SELECT 'G' AS sales_gubun,  '1450066' AS h_comcode, '890'  AS h_partCode, '080403' AS h_staffcode, '155' AS h_cost, 'Y' AS PGCheck, 'AG' AS DeptGubun , '' AS Company_seq UNION ALL
SELECT 'B' AS sales_gubun,  '1489998' AS h_comcode, '390'  AS h_partCode, '030603' AS h_staffcode, '148' AS h_cost, 'Y' AS PGCheck, 'BR' AS DeptGubun , '' AS Company_seq UNION ALL		
SELECT 'SB' AS sales_gubun, '1450071' AS h_comcode, 'N110' AS h_partCode, '030603' AS h_staffcode, '117' AS h_cost, 'Y' AS PGCheck, 'SB' AS DeptGubun , '5001' AS Company_seq UNION ALL
SELECT 'SW' AS sales_gubun, '1450072' AS h_comcode, 'N210' AS h_partCode, '100906' AS h_staffcode, '143' AS h_cost, 'Y' AS PGCheck, 'SW' AS DeptGubun , '5002' AS Company_seq UNION ALL
SELECT 'SS' AS sales_gubun, '1450073' AS h_comcode, 'N130' AS h_partCode, '030603' AS h_staffcode, '117' AS h_cost, 'Y' AS PGCheck, 'SS' AS DeptGubun , '5003' AS Company_seq UNION ALL
SELECT 'SH' AS sales_gubun, '1450074' AS h_comcode, 'N220' AS h_partCode, '030603' AS h_staffcode, '143' AS h_cost, 'Y' AS PGCheck, 'SH' AS DeptGubun , '5004' AS Company_seq UNION ALL
SELECT 'SP' AS sales_gubun, '1450075' AS h_comcode, 'N120' AS h_partCode, '100906' AS h_staffcode, '117' AS h_cost, 'Y' AS PGCheck, 'SP' AS DeptGubun , '5005' AS Company_seq 

				

	--drop table #custom_order_item_Temp
	--drop table #custom_order_item
	
--###############################################################################################################################################################
--###############################################################################################################################################################
--아이템 정보취합 BEGIN 
--###############################################################################################################################################################
--###############################################################################################################################################################

	--기본 아이템 정보
	SELECT a.order_seq, a.order_type, a.order_count,  a.mini_price, a.fticket_price, b.card_seq, c.Card_ErpCode, b.item_type, b.item_count as item_count, IsNUll(b.item_sale_price,0) as item_price
	INTO #custom_order_item_Temp
	FROM #custom_order a 
	JOIN custom_order_item b ON  a.order_seq = b.order_seq
	JOIN #CardMaster c ON b.card_seq = c.card_seq
	WHERE a.status_Seq = 15  -- 배송완료
		and convert(char(8),a.src_send_date,112) between @SDate AND @EDate
		and a.sales_gubun in ('W','T','U','J','B','S','X','G', 'SB', 'SW', 'SS', 'SH', 'SP')
ORDER BY a.order_seq, b.card_seq



	

		




--**************************************************************************************************************
-- --4. e청첩장 
--**************************************************************************************************************
	INSERT INTO #erp_salesReport 
	( 	h_biz, h_gubun, h_date, h_sysCode, h_usrCode, h_comcode, h_taxType, h_offerPrice, h_superTax, h_sumPrice
		, h_partCode, h_staffcode, h_sonik, h_cost, h_orderid, h_memo2
		, b_biz, b_goodGubun, b_seq, b_storeCode, b_date, b_goodCode, b_goodUnit, b_OrderNum, b_unitPrice, b_offerPrice, b_superTax, b_sumPrice
		, b_memo, reg_date, FeeAmnt, ItemGubun, PGCheck, PayAmnt, SampleCheck, XartCheck, SettleDate, PayDate, PayCheck, b_memo_temp, DeptGubun
	)
	SELECT 
		h_biz		= 'BK10',
		h_gubun		= 'SO',
		h_date		= Convert(char(8),a.settle_date,112),
		h_sysCode	= @SysCode1,
		h_usrCode	= @UsrCode1, 	
		O.h_comcode,
		h_taxType = '22', 
		h_offerPrice	= Round(a.settle_price/1.1,0),				
		h_superTax		= Round(a.settle_price- a.settle_price/1.1,0),	
		h_sumPrice		= a.settle_price,	
		O.h_partCode,
		O.h_staffcode,
		h_sonik		= '110',
		O.h_cost,						
		h_orderid	= Cast(a.pg_tid as varchar(20)),	
		h_memo2		=  Cast(a.pg_tid as varchar(20)),	
		
		b_biz		= 'BK10',
		b_goodGubun	= 'SO',
		b_seq		= 1,
		b_storeCode	= 'MF03',
		b_date		= Convert(char(8),a.settle_date,112),
		b_goodCode	= 'ON006',
		b_goodUnit	= 'EA',
		b_OrderNum	= 1,

		b_unitPrice	 =  a.settle_price,
		b_offerPrice =  Round(a.settle_price/1.1,0),	
		b_superTax	 =  a.settle_price - Round(a.settle_price/1.1,0),	
		b_sumPrice	 =  a.settle_price,	
		b_memo		= null,
		reg_date	= getdate(),
		FeeAmnt		=  dbo.getPGFee_New (a.pg_shopid, 
														Case	
															When a.settle_method = 'H' Then 5
															When a.settle_method = 'B' Then 3
															When a.settle_method = 'C' Then 2
														End
										,a.settle_price),
		ItemGubun	= 'ITEM',
		O.PGCheck, 
		PayAmnt		= 0,
		SampleCheck	= 'N',
		XartCheck	= 'N',
		SettleDate	= null,
		PayDate		= null,
		PayCheck	= null,
		b_memo_temp	= null,
		O.DeptGubun	
	FROM the_ewed_order a 
		LEFT JOIN #sales_gubunTemp O ON a.sales_gubun = O.sales_gubun
	WHERE AC_STATE='P' and settle_Status=2 and status_Seq=2 and order_result in ('3','4') 
		and Convert(char(8), a.settle_date, 112) BETWEEN @SDate and @EDate
		and a.sales_gubun in ('W','T','U','J','B','S','X','G', 'SB', 'SW', 'SS', 'SH', 'SP') 


--select * from the_ewed_order where order_id = 81765

--시즌2 e청첩장 등록 BEGIN 	20100823 이상민
INSERT INTO #erp_salesReport 
	( 	h_biz, h_gubun, h_date, h_sysCode, h_usrCode, h_comcode, h_taxType, h_offerPrice, h_superTax, h_sumPrice
		, h_partCode, h_staffcode, h_sonik, h_cost, h_orderid, h_memo2
		, b_biz, b_goodGubun, b_seq, b_storeCode, b_date, b_goodCode, b_goodUnit, b_OrderNum, b_unitPrice, b_offerPrice, b_superTax, b_sumPrice
		, b_memo, reg_date, FeeAmnt, ItemGubun, PGCheck, PayAmnt, SampleCheck, XartCheck, SettleDate, PayDate, PayCheck, b_memo_temp, DeptGubun
	)
	SELECT 
		h_biz		= 'BK10',
		h_gubun		= 'SO',
		h_date		= Convert(char(8),a.settle_date,112),
		h_sysCode	= @SysCode1,
		h_usrCode	= @UsrCode1, 	
		O.h_comcode,
		h_taxType = '22', 
		h_offerPrice	= Round(a.settle_price/1.1,0),				
		h_superTax		= Round(a.settle_price- a.settle_price/1.1,0),	
		h_sumPrice		= a.settle_price,	
		O.h_partCode,
		O.h_staffcode,
		h_sonik		= '110',
		O.h_cost,						
		h_orderid	= Cast(a.pg_tid as varchar(20)),	
		h_memo2		=  Cast(a.pg_tid as varchar(20)),	
		
		b_biz		= 'BK10',
		b_goodGubun	= 'SO',
		b_seq		= 1,
		b_storeCode	= 'MF03',
		b_date		= Convert(char(8),a.settle_date,112),
		b_goodCode	= 'ON006',
		b_goodUnit	= 'EA',
		b_OrderNum	= 1,

		b_unitPrice	 =  a.settle_price,
		b_offerPrice =  Round(a.settle_price/1.1,0),	
		b_superTax	 =  a.settle_price - Round(a.settle_price/1.1,0),	
		b_sumPrice	 =  a.settle_price,	
		b_memo		= null,
		reg_date	= getdate(),
		FeeAmnt		=  dbo.getPGFee_New (a.pg_shopid, 
														Case	
															When a.settle_method = 'H' Then 5
															When a.settle_method = 'B' Then 3
															When a.settle_method = 'C' Then 2
															else settle_method
														End
										,a.settle_price),
		ItemGubun	= 'ITEM',
		O.PGCheck, 
		PayAmnt		= 0,
		SampleCheck	= 'N',
		XartCheck	= 'N',
		SettleDate	= null,
		PayDate		= null,
		PayCheck	= null,
		b_memo_temp	= null,
		O.DeptGubun	
	FROM S2_eCardOrder a 
		LEFT JOIN #sales_gubunTemp O ON a.Company_seq = O.Company_seq
	WHERE settle_Status=2 and status_Seq=2
		AND a.Settle_date is not null and A.dacom_tid is not null	
		and Convert(char(8), a.settle_date, 112) BETWEEN @SDate and @EDate
		and a.Company_seq in ('5001', '5002', '5003', '5004', '5005') 
		


--select * from S2_eCardOrder a
--	WHERE settle_Status=2 and status_Seq=2 
--	--and order_result in ('3','4') 
--		and Convert(char(8), a.settle_date, 112) BETWEEN '20100301' and '20101231'
--		and a.Company_seq in ('5001', '5002', '5003', '5004', '5005') 
--delete from #erp_salesReport


--시즌2 e청첩장 등록 END 	20100823 이상민



--**************************************************************************************************************
--   * 할인율에 맞추어 각 아이템 금액 재계산  	
--**************************************************************************************************************
--rollback

--begin tran 
	UPDATE #erp_salesReport 
	SET h_optionPrice = a.option_sumPrice ,
		DiscountRate  = a.discountRate,	 
		b_sumPrice    =	Case 
							When b.b_goodCode in ('TBB','JAEBON','PANBI','EMBO','ENVINSERT','QICKDELIVERY') Then b.b_sumPrice
							Else Round( ((b.b_sumPrice * (100-a.DiscountRate)/100)/1.1) 
								+ (b.b_sumPrice * (100-a.DiscountRate)/100) - ((b.b_sumPrice * (100-a.DiscountRate)/100)/1.1), 0)
						End,
 		b_offerPrice    = Case 
							When b.b_goodCode in ('TBB','JAEBON','PANBI','EMBO','ENVINSERT','QICKDELIVERY') Then Round(b.b_sumPrice/1.1, 0)
							--Else Round( (b.b_sumPrice * (100-a.DiscountRate)/100)/1.1, 0)
							ELSE  Round( ( ((b.b_sumPrice * (100-a.DiscountRate)/100)/1.1) 
								+ (b.b_sumPrice * (100-a.DiscountRate)/100) - ((b.b_sumPrice * (100-a.DiscountRate)/100)/1.1) ) / 1.1, 0)
						
						End,
 		b_superTax    = Case 
							When b.b_goodCode in ('TBB','JAEBON','PANBI','EMBO','ENVINSERT','QICKDELIVERY') Then Round(b.b_sumPrice - b.b_sumPrice/1.1,0)
							--Else Round((b.b_sumPrice * (100-a.DiscountRate)/100)  - ((b.b_sumPrice * (100-a.DiscountRate)/100)/1.1), 0)
							ELSE Round( ((b.b_sumPrice * (100-a.DiscountRate)/100)/1.1) 
								+ (b.b_sumPrice * (100-a.DiscountRate)/100) - ((b.b_sumPrice * (100-a.DiscountRate)/100)/1.1), 0)
								- Round( ( ((b.b_sumPrice * (100-a.DiscountRate)/100)/1.1) 
								+ (b.b_sumPrice * (100-a.DiscountRate)/100) - ((b.b_sumPrice * (100-a.DiscountRate)/100)/1.1) ) / 1.1, 0)
						End
							
	FROM #erp_salesReport  b 
	JOIN (		
				SELECT 
					h_orderid       = a.h_orderid,
					option_sumPrice = c.option_sumprice,
					b_sumPrice 		= b.b_sumprice,
					h_sumPrice 		= a.h_sumPrice,
					DiscountRate	= Case When c.option_sumprice is  null  Then CASE WHEN ISNULL(b.b_sumprice, 0) = 0 THEN 0 ELSE ((ISNULL(b.b_sumprice, 0) - ISNULL(a.h_sumprice, 0))*100 )/ b.b_sumprice END
										 Else CASE WHEN (ISNULL(b.b_sumprice, 0)- ISNULL(c.option_sumprice, 0)) = 0 THEN 0 ELSE  (((ISNULL(b.b_sumprice, 0)-ISNULL(c.option_sumprice, 0)) - (ISNULL(a.h_sumprice, 0)-ISNULL(c.option_sumprice, 0)))*100) / (ISNULL(b.b_sumprice, 0)- ISNULL(c.option_sumprice, 0)) END
									  End
				FROM #erp_salesReport  a 
				JOIN 	(
						 SELECT h_orderid, sum(b_offerprice) as b_offerPrice,sum(b_superTax) as b_superTax,sum(b_sumprice) as b_sumPrice 
						 FROM #erp_salesReport 
						 GROUP BY h_orderid
						) b --아이템 합계 금액 
					ON a.h_orderid = b.h_orderid	
				LEFT JOIN (
							SELECT h_orderid,  sum(b_sumprice)  as option_sumPrice 
							FROM #erp_salesReport
							WHERE b_goodCode  in ('TBB','JAEBON','PANBI','EMBO','ENVINSERT','QICKDELIVERY') 
							GROUP BY h_orderid
						   ) c --옵션비용  합계 금액
	 				ON a.h_orderid = c.h_orderid	
		
		) a  ON a.h_orderid = b.h_orderid	
	WHERE b.SampleCheck = 'N'


--**************************************************************************************************************
--b_seq를 생성해 내기 위한 Temp 테이블 생성
--**************************************************************************************************************
	SELECT  IDENTITY(int, 1, 1) AS seq, h_OrderID, b_goodCode, b_sumPrice,h_sysCode
	INTO #TempSEQ
	FROM #erp_salesReport   
	ORDER BY h_Orderid ASC, b_sumPrice DESC, b_goodCode

								


--UPDATE #erp_salesReport 
--SET  h_syscode ='270' , h_usrcode='270'
--WHERE h_syscode ='300' and h_usrcode='322' and b_sumPrice > 0
								
--**************************************************************************************************************
--   *  헤더와 아이템 단수조정
--**************************************************************************************************************
	UPDATE #erp_salesReport
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
						 End,
			FeeAmnt = Case 
						When pgCheck = 'N' Then 0
						Else FeeAmnt
					  End			 
	FROM 	#erp_salesReport  a 
	JOIN 	( SELECT h_orderid,SUM(b_offerPrice) as b_offerPrice, SUM(b_superTax) as b_superTax, SUM(b_sumPrice) as b_sumPrice 
			  FROM #erp_salesReport
			  GROUP BY h_orderid
			) b ON a.h_orderid = b.h_orderid
		
	JOIN 	( 
				SELECT  A.h_OrderID, (A.seq - B.MinSeq) + 1 AS b_seq
					, A.b_goodCode, A.h_sysCode
				FROM #TempSEQ  A 
				JOIN ( 
						SELECT h_OrderID, MIN(seq) AS MinSeq 
						FROM #TempSEQ GROUP BY h_Orderid
				) B ON A.h_OrderID = B.h_OrderID
				
			) c ON a.h_orderid = c.h_orderid and a.b_goodCode = c.b_goodCode and a.h_sysCode = c.h_sysCode
	WHERE (a.h_sumPrice <> b.b_sumPrice or a.h_offerPrice <> b.b_OfferPrice or a.h_superTax <> b.b_superTax)
		  and c.b_Seq = 1 
		  and a.SampleCheck = 'N' and b.b_sumPrice > 0



	--20100324
	SELECT  IDENTITY(int, 1, 1) AS ItemSerNo, *
	INTO #ERP_SalesDataTemp
	FROM #erp_salesReport
	ORDER BY h_Orderid ASC, b_sumPrice DESC, b_goodCode 
	


--**************************************************************************************************************
--Erp_salesData에 Insert
--**************************************************************************************************************

	INSERT INTO  [erpdb.bhandscard.com].XERP.DBO.erp_salesData 
	( h_biz, h_gubun, h_date, h_sysCode, h_usrCode, h_comcode, h_taxType, h_offerPrice, h_superTax, h_sumPrice
		, h_partCode, h_staffcode, h_sonik, h_cost, h_orderid, h_memo2
		, b_biz, b_goodGubun, b_seq, b_storeCode, b_date, b_goodCode, b_goodUnit, b_OrderNum, b_unitPrice, b_offerPrice, b_superTax, b_sumPrice
		, b_memo, reg_date, FeeAmnt, ItemGubun, PGCheck, PayAmnt, SampleCheck, XartCheck, SettleDate, PayDate, PayCheck, b_memo_temp, DeptGubun 
	)
	
	SELECT  a.h_biz, a.h_gubun, a.h_date, a.h_sysCode, a.h_usrCode, a.h_comcode, a.h_taxType, a.h_offerPrice, a.h_superTax, a.h_sumPrice
		, a.h_partCode, a.h_staffcode, a.h_sonik, a.h_cost, a.h_orderid, a.h_memo2
		, a.b_biz, a.b_goodGubun, b.b_seq, a.b_storeCode, a.b_date, a.b_goodCode, a.b_goodUnit, a.b_OrderNum, a.b_unitPrice, a.b_offerPrice, a.b_superTax, a.b_sumPrice
		, a.b_memo, a.reg_date, a.FeeAmnt, a.ItemGubun, a.PGCheck, a.PayAmnt, a.SampleCheck, a.XartCheck, a.SettleDate, a.PayDate, a.PayCheck, a.b_memo_temp, a.DeptGubun
	FROM #ERP_SalesDataTemp  a 
	JOIN (
				SELECT  A.h_OrderID, A.ItemSerNo
					, (A.ItemSerNo - B.MinSeq) + 1 AS b_seq
				FROM #ERP_SalesDataTemp  A 
				JOIN (
						 SELECT h_OrderID, MIN(ItemSerNo) AS MinSeq
						 FROM #ERP_SalesDataTemp
						 GROUP BY h_Orderid
					) B ON A.h_OrderID = B.h_OrderID
		 ) b ON a.h_orderid = b.h_orderid and a.ItemSerNo = b.ItemSerNo --and a.h_sysCode = b.h_sysCode
   	LEFT JOIN OPENQUERY([erpdb.bhandscard.com], 'SELECT DISTINCT h_orderid FROM XERP.DBO.erp_salesData ')  c ON a.h_orderid = c.h_orderid	   --Erp_SalesData에 중복 입력 오류 방지		
	--LEFT JOIN [erpdb.bhandscard.com].XERP.DBO.erp_salesData c ON a.h_orderid = c.h_orderid
	WHERE c.h_orderid is null

GO
