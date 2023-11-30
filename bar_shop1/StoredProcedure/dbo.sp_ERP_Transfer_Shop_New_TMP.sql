IF OBJECT_ID (N'dbo.sp_ERP_Transfer_Shop_New_TMP', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_ERP_Transfer_Shop_New_TMP
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_ERP_Transfer_Shop_New_TMP]
 @SDate as char(8)
 , @EDate as char(8)

AS
SET NOCOUNT ON
	

--EXEC sp_ERP_Transfer_Shop_New_TMP '20201221', '20210103'
-- select * from custom_etc_order where order_type = 'H' and status_seq = 12

--정상출고시 
--SysCase = 270, CaseCode = 270

--예외출고(판매촉진비) 
--SysCase = 300, CaseCode = 322

--예외출고(샘플-영업3팀)
--SysCase = 300, CaseCode = 308



DECLARE @Syscode1 as char(3),@UsrCode1 as char(3) --정상출고 (270,270)
Set @SysCode1 = '270'
Set @UsrCode1 = '270'

DECLARE @Syscode2 as char(3),@UsrCode2 as char(3) --예외출고(판매촉진비)  (300,322)
Set @SysCode2 = '300'
Set @UsrCode2 = '322'


--기존 예외출고(샘플-영업3팀)(300,308) 에서 예외출고(샘플-판매촉진비)(300,308) 로 변경함 - 관리팀, 온라인팀 요청 20120913 이상민
DECLARE @Syscode3 as char(3),@UsrCode3 as char(3) --예외출고(판매촉진비)  (300,308)
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
			h_orderid	nvarchar(50) 		NOT NULL,
			h_memo1	nvarchar(50) 			NULL,
			h_memo2	nvarchar(50) 			NULL,
			h_memo3	nvarchar(20) 			NULL,
			
			b_biz		nvarchar(4) 		NOT NULL,
			b_goodGubun	nvarchar(2) 		NOT NULL,
			b_seq		smallint			NOT NULL,
			b_storeCode	nvarchar(4) 		NOT NULL,
			b_date		nvarchar(8) 		NOT NULL,
			b_goodCode	nvarchar(20)		NOT NULL,
			b_goodUnit	nvarchar(4) 		NOT NULL,
			b_OrderNum	numeric(18,1)		NOT NULL,
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
			DiscountRate	numeric(28, 8) 	NULL ,
			inflow_route_settle     varchar(10)  NULL ,
			order_seq     int  NULL, 
			order_g_seq     int  NULL,
			item_type nvarchar(20) NULL
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
	and convert(char(8), A.Order_date,112) >= '20160101'
	and A.sales_gubun in ( 'W','T','J','B','S','G','SA', 'ST', 'SB', 'SW', 'SS', 'SP', 'SH', 'H', 'C', 'SG', 'P' ) --비핸즈, 더카드



--이지웰 매출은 비핸즈카드로 연동되도록 수정. 정소연 요청.
UPDATE #custom_order
SET sales_Gubun = 'C'
WHERE company_seq = 5780 --이지웰사이트
	AND sales_Gubun = 'H'
	
		
--카드정보
SELECT Card_Seq, Card_Code, CASE WHEN RTRIM(LTRIM(ISNULL(ERP_Code, ''))) = '' THEN Card_Code ELSE ERP_Code END  AS Card_ERPCode
	, Cont_Seq, Acc_Seq, Acc_seq2, 0 AS MapCard_Seq
INTO #CardMaster
FROM Card A
WHERE  ISNULL(A.CARD_CATE, '') <> 'SL' --사은품 제거
	AND CARD_CODE <> 'BE-BH' --정광수차장 요청 20120206
	AND CARD_CODE <> 'YM15' --정광수차장 요청 20120313
UNION ALL
SELECT A.Card_Seq, A.Card_Code, CASE WHEN RTRIM(LTRIM(ISNULL(A.Card_ERPCode, ''))) = '' THEN A.Card_Code ELSE A.Card_ERPCode END  AS Card_ERPCode 
	, ISNULL(B.Inpaper_seq, 0) AS Cont_Seq, ISNULL(B.Acc1_seq, 0) AS Acc_Seq, ISNULL(B.Acc2_seq, 0) AS Acc_seq2, ISNULL(B.MapCard_Seq, 0) AS MapCard_Seq
FROM S2_Card A
LEFT JOIN S2_CardDetail B ON A.Card_Seq = B.Card_Seq
WHERE  ISNULL(A.Card_Div, '') NOT IN ('C05', 'C13') --사은품 제거
	AND CARD_CODE <> 'BE-BH' --정광수차장 요청 20120206
	AND CARD_CODE <> 'YM15' --정광수차장 요청 20120313
	AND CARD_CODE <> '1_misty' --http://redmine.barunson.com/redmine/issues/5742

CREATE   Table #sales_gubunTemp  (      
	sales_gubun		nvarchar(2)			NOT NULL,
	h_comcode		nvarchar(8)			NOT NULL,
	h_partCode		nvarchar(8)			NOT NULL,
	h_staffcode	nvarchar(8)			NOT NULL,
	h_cost	nvarchar(3)			NOT NULL,
	PGCheck	nvarchar(1)		NOT NULL,  
	DeptGubun	nvarchar(2)		NOT NULL,  
	Company_seq	nvarchar(4)		NOT NULL,  
) 
			
--기준정보 셋팅
INSERT INTO #sales_gubunTemp 

--전자상거래
SELECT 'SB' AS sales_gubun, '1450071' AS h_comcode, 'N110' AS h_partCode, '171202' AS h_staffcode, '511' AS h_cost, 'Y' AS PGCheck, 'SB' AS DeptGubun , '5001' AS Company_seq UNION ALL		--바른손카드
SELECT 'SS' AS sales_gubun, '1450073' AS h_comcode, 'N130' AS h_partCode, '171202' AS h_staffcode, '513' AS h_cost, 'Y' AS PGCheck, 'SS' AS DeptGubun , '5003' AS Company_seq UNION ALL		--프리미어페이퍼
SELECT 'ST' AS sales_gubun, '2011021' AS h_comcode, 'N140' AS h_partCode, '171202' AS h_staffcode, '514' AS h_cost, 'Y' AS PGCheck, 'ST' AS DeptGubun , '5007' AS Company_seq UNION ALL		--더카드


--제휴영업
SELECT 'SA' AS sales_gubun, '2011022' AS h_comcode, 'N230' AS h_partCode, '030801' AS h_staffcode, '523' AS h_cost, 'Y' AS PGCheck, 'SA' AS DeptGubun , '5006' AS Company_seq UNION ALL		--비핸즈카드
SELECT 'C' AS sales_gubun,  '2012664' AS h_comcode, 'N230' AS h_partCode, '030801' AS h_staffcode, '523' AS h_cost, 'N' AS PGCheck, 'SA' AS DeptGubun , '5780' AS Company_seq UNION ALL		--이지웰	
SELECT 'B' AS sales_gubun,  '1489998' AS h_comcode, '390'  AS h_partCode, '030801' AS h_staffcode, '148' AS h_cost, 'Y' AS PGCheck, 'BR' AS DeptGubun , '' AS Company_seq UNION ALL
SELECT 'H' AS sales_gubun,  '1489998' AS h_comcode, '390'  AS h_partCode, '030801' AS h_staffcode, '148' AS h_cost, 'Y' AS PGCheck, 'BR' AS DeptGubun , '' AS Company_seq UNION ALL

--채널영업팀
SELECT 'SG' AS sales_gubun, '2012563' AS h_comcode, '405'  AS h_partCode, '150602' AS h_staffcode, '405' AS h_cost, 'N' AS PGCheck, 'SG' AS DeptGubun , '' AS Company_seq UNION ALL
SELECT 'P' AS sales_gubun, '1490020' AS h_comcode, '340-1'  AS h_partCode, '150602' AS h_staffcode, '112' AS h_cost, 'Y' AS PGCheck, 'OB' AS DeptGubun , '' AS Company_seq   

--030801  	원덕규
--150602  	임헌재
--171202  	정미진

--060404  	정광용
--090401  	김형
--030801  	원덕규
--030603  	김성동
--040401  	김용재
--140903  	정미옥
--110301  	전미선
--150602  	임헌재
--110201  	홍현기
--171001	이대원


	
--###############################################################################################################################################################
--###############################################################################################################################################################
--아이템 정보취합 BEGIN 
--###############################################################################################################################################################
--###############################################################################################################################################################

	--기본 아이템 정보
	SELECT a.order_seq, a.order_type, a.order_count,  a.mini_price, a.fticket_price, b.card_seq, c.Card_ErpCode, b.item_type
		, ISNULL(b.item_count, 0) as item_count
		, ISNULL(b.item_sale_price, 0) as item_price
		, ROUND(ISNULL(b.item_count, 0) * ISNULL(b.item_sale_price, 0), 0) AS Item_Amnt
	INTO #custom_order_item_Temp
	FROM #custom_order a 
	JOIN custom_order_item b ON  a.order_seq = b.order_seq
	JOIN #CardMaster c ON b.card_seq = c.card_seq
	WHERE a.status_Seq = 15  -- 배송완료
	ORDER BY a.order_seq, b.card_seq



	--기본 아이템 정보 + 서비스품목 추가
	SELECT order_seq,card_seq, Card_ErpCode, item_type, item_count, item_price, Item_Amnt
	INTO #custom_order_item
	FROM #custom_order_item_Temp 
	WHERE item_count > 0 
	--	AND item_type NOT IN ('F', 'L', 'H', 'M') --C:카드,E:봉투,I:내지,S:스티커,M:미니청첩장,F:식권,A:부속품 ,B:라벨지,R: 리본, L:방명록, 'H':메모리북
			
	--UNION ALL  --방명록, 메모리북
	--SELECT order_seq, card_seq, Card_ErpCode, item_type, item_count, item_price, Item_Amnt
	--FROM #custom_order_item_Temp
	--WHERE item_type IN ('L', 'H', 'M') and item_count > 0  and item_price > 0

	--UNION ALL  --1.무료식권 주문시 (fticket_price가 0원일 경우)
	--SELECT order_seq, card_seq, Card_ErpCode, item_type, item_count, item_price, Item_Amnt
	--FROM #custom_order_item_Temp
	--WHERE item_type = 'F' and item_count > 0 and fticket_price = 0 
	
	--UNION ALL --2.유료식권일 경우
	--SELECT  order_seq, card_seq, Card_ErpCode, item_type, item_count, item_price, Item_Amnt
	--FROM #custom_order_item_Temp 
	--WHERE item_type = 'F' and item_count > 0 and fticket_price > 0 

	--서비스품목 금액.#############################################################################
	UNION ALL  --택배비	
	SELECT order_seq, card_seq,  'TBB', 'SVC', 1, delivery_price, delivery_price
	FROM #custom_order WHERE pay_type <> '4' AND delivery_price > 0
	
	UNION ALL  --제본	
	SELECT order_seq, card_seq,  'JAEBON', 'SVC', 1, jebon_price, jebon_price
	FROM #custom_order WHERE pay_type <> '4' AND jebon_price > 0 
	
	UNION ALL --추가판비	
	SELECT order_seq, card_seq,  'PANBI', 'SVC', 1, option_price, option_price
	FROM #custom_order WHERE pay_type <> '4' AND option_price > 0
	
	UNION ALL	--엠보	
	SELECT order_seq, card_seq,  'EMBO', 'SVC', 1, embo_price, embo_price
	FROM #custom_order WHERE pay_type <> '4' AND embo_price > 0
	
	UNION ALL --봉투삽입	
	SELECT order_seq, card_seq,  'ENVINSERT', 'SVC', 1, envInsert_price, envInsert_price
	FROM #custom_order WHERE pay_type <> '4' AND envInsert_price > 0	
	
	UNION ALL --초특급 배송(custom_order.isSpecial='1' 그리고, custom_order.delivery_price=30000)
	SELECT order_seq, card_seq,  'QICKDELIVERY', 'SVC', 1, ISNULL(etc_price, 0), ISNULL(etc_price, 0) 
	FROM #custom_order WHERE pay_type <> '4' and isSpecial IN ( '1', '2') AND ISNULL(etc_price, 0) > 0
	
	UNION ALL  --유니세프 기부금아이템 정보추가  --20110404 이상민
	SELECT order_seq, card_seq,  'DONATION', 'SVC', 1, ISNULL(unicef_price, 0), ISNULL(unicef_price, 0)
	FROM #custom_order WHERE status_Seq = 15  -- 배송완료
		AND order_seq>=1000000 AND unicef_price > 0	
	
	UNION ALL --T맵	--20131017 이상민추가
	SELECT order_seq, card_seq,  'TMAP', 'SVC', 1, ISNULL(tmap_price, 0), ISNULL(tmap_price, 0)
	FROM #custom_order WHERE ISNULL(tmap_price, 0) > 0
	
	ORDER BY order_seq, card_seq, Card_ErpCode, item_count


	

		
--###############################################################################################################################################################
--###############################################################################################################################################################
--아이템 정보취합 END 
--###############################################################################################################################################################
--###############################################################################################################################################################



--Item_Type 
--C = 카드
--E = 일반봉투
--I = 내지
--A = 악세사리
--R = 리본
--B = 라벨지
--P = 추가내지(내지 2장 있는 카드)
--F = 식권 - 식권은 매출 금액이 있으면 정상출고(270), 무료이면 무료제공품(300)
--S = 스티커
--M = 미니청첩장
--L = 스크랩북
--V = 사은품
--D = 카드띠지 20091030_이상민
--G = 스토리오브러브 부속
--H = 카운팅사은품
--X = 메모리북
--W = 플라워

--** 결제금액이 있는것은 모든 아이템에 대하여 정상출고로 출고시킨다. 추후 ERP가 아이템별 출고 유형을 달리 할 수 있도록 수정하면 여기도 수정해 줘야 함


INSERT INTO #erp_salesReport 
( h_biz, h_gubun, h_date, h_sysCode, h_usrCode, h_comcode, h_taxType, h_offerPrice, h_superTax, h_sumPrice
	, h_optionPrice, h_partCode, h_staffcode, h_sonik, h_cost, h_orderid, h_memo2

	, b_biz, b_goodGubun, b_seq, b_storeCode, b_date, b_goodCode, b_goodUnit, b_OrderNum, b_unitPrice, b_offerPrice
	, b_superTax, b_sumPrice, b_memo, reg_date, FeeAmnt, ItemGubun, PGCheck, PayAmnt, SampleCheck, XartCheck
	, SettleDate, PayDate, PayCheck, b_memo_temp, DeptGubun, inflow_route_settle
	, order_seq, order_g_seq, item_type )

SELECT 'BK10' AS h_biz, 'SO' AS h_gubun, Convert(char(8),a.src_send_date,112) AS h_date

		, CASE WHEN b.item_Type IN ( 'C', 'I', 'A', 'R', 'B', 'P', 'D', 'G', 'SVC' ) THEN @SysCode1
				WHEN b.item_Type IN ('F', 'S', 'M', 'L', 'V', 'H', 'X', 'W', 'J' ) and Item_Amnt <> 0  THEN @SysCode1
				WHEN b.item_Type IN ('F', 'S', 'M', 'L', 'V', 'H', 'X', 'W', 'J' ) and Item_Amnt = 0  THEN @SysCode2
				ELSE @SysCode1
			END AS h_sysCode
			
		, CASE WHEN b.item_Type IN ( 'C', 'I', 'A', 'R', 'B', 'P', 'D', 'G', 'SVC' ) THEN @UsrCode1
				WHEN b.item_Type IN ('F', 'S', 'M', 'L', 'V', 'H', 'X', 'W', 'J' ) and Item_Amnt <> 0  THEN @UsrCode1
				WHEN b.item_Type IN ('F', 'S', 'M', 'L', 'V', 'H', 'X', 'W', 'J' ) and Item_Amnt = 0  THEN @UsrCode2
				ELSE @UsrCode1
			END AS h_usrCode

		--1. 후불결제 업체의 경우 정상주문건은 거래처가 후불결제 업체로 넘어가고 추가주문이나 옵션에 대한 것은 제휴코드로 넘어감
		, CASE	WHEN a.pg_shopid IN ( 'bhands_b' ) THEN '2011022'	--비핸즈사이트
				WHEN a.pg_shopid IN ( 'pbhands' ) THEN '1450073'	--스토리오브러브(시즌2)
				WHEN a.pg_shopid IN ( 'bhandscad1', 'bhandscas0', 'IESbhandsc' ) THEN '2014081'	--바른손카드(이니시스)
				WHEN a.pg_shopid IN ( 'mbarunsonc' ) THEN '2014242'	--M바른손(이니시스)
				WHEN a.pg_shopid IN ( 'mbhandscar' ) THEN '2014243'	--M비핸즈(이니시스)
				WHEN a.pg_shopid IN ( 'KCBRC0001m' ) THEN '2015272'	--바른손카드(카카오)
				WHEN a.pg_shopid IN ( 'KCBRC0002m' ) THEN '2015273'	--비핸즈(카카오)
				WHEN a.pg_shopid IN ( 'KCBRC0003m' ) THEN '2015274'	--프리미어(카카오)
				WHEN a.pg_shopid IN ( 'KCBRC0004m' ) THEN '2015275'	--제휴(카카오)
				WHEN a.pg_shopid IN ( 'KCBRC0005m' ) THEN '2016130'	--더카드(카카오)
				WHEN a.pg_shopid IN ( 'bhands_cm' ) THEN '2016204'	--M바른손(유플러스)
				WHEN a.pg_shopid IN ( 'bhands_bm' ) THEN '2016199'	--M비핸즈(유플러스)
				WHEN a.pg_shopid IN ( 'bhands_them' ) THEN '2016217'	--M더카드(유플러스)
				WHEN a.pg_shopid IN ( 'pbhands_m' ) THEN '2017080'	--M프리미어(유플러스)
				
				WHEN a.sales_gubun = 'B' Then 
					Case When c.company_seq in (232,1137,1243,1250,7157,2235, 2556, 5705) Then --디지털플라자, 워커힐, G마켓(1243,1250), 옥션(7157) (후불결제), 전자랜드
							Case When (b.item_type = 'F' and ISNULL(b.Item_Amnt, 0) > 0)
									or (a.up_order_seq is not null and ISNULL(a.settle_price, a.last_total_price) > 0) 
									or  ( b.item_type in ('SVC') and ISNULL(a.settle_price, a.last_total_price) > 0) Then '1489998'
									When c.company_seq IN ( 1243, 1250, 7157 ) Then '1400019'  --지마켓, 옥션
									When c.company_seq = 2235 Then '1510052'  --전자랜드
									When c.company_seq IN ( 2556, 5705) Then '1400113'  --현대카드	--20130904 이상민 추가 
									
								Else O.h_comcode End 
						Else O.h_comcode End				
				WHEN a.sales_gubun in ( 'C', 'H') Then 
					CASE WHEN c.COMPANY_SEQ = 5780 THEN '2012664'  --이지웰 
						 WHEN c.COMPANY_SEQ = 5787 THEN '2012692'  --SK베네피아 
					ELSE O.h_comcode END

			ELSE O.h_comcode END AS h_comcode		
			
		, CASE WHEN a.sales_gubun IN ( 'U', 'SG') THEN '10'
				WHEN  a.sales_gubun = 'B' Then
					Case
						When c.company_seq in (2235) Then '10'  --전자랜드 일반과세
						Else '22'
					End	
				ELSE '22' 
			END AS h_taxType

		--**************************************************************************************************************
		--* 헤더 결제금액
		--**************************************************************************************************************
		, Case When c.company_seq in (232, 1137, 1250, 2235) Then --디지털플라자, 워커힐, G마켓 (후불결제), 전자랜드
					Case When c.company_seq IN ( 1250) Then Round((a.Reduce_price * -1 ) / 1.1, 0)  --지마켓
						When (b.item_type = 'F' and ISNULL(b.Item_Amnt, 0) > 0) 
								or (a.up_order_seq is not null and ISNULL(a.settle_price, a.last_total_price) > 0) 
								or  ( b.item_type in ('SVC') and ISNULL(a.settle_price, a.last_total_price) > 0) Then Round(ISNULL(a.settle_price, a.last_total_price)/1.1,0)
					Else 75000
				End 
			Else Round(ISNULL(a.settle_price, a.last_total_price)/1.1, 0)
		End AS h_offerPrice
		
		, Case When c.company_seq in (232,1137, 1250,2235) Then   --디지털플라자, 워커힐, G마켓 (후불결제), 전자랜드
				Case When c.company_seq  IN ( 1250) Then ROUND((a.Reduce_price*-1)- (a.Reduce_price*-1)/1.1,0)  --지마켓
					When (b.item_type = 'F' and ISNULL(b.Item_Amnt, 0) > 0) 
							or (a.up_order_seq is not null and ISNULL(a.settle_price, a.last_total_price) > 0) 
							or ( b.item_type in ('SVC') and ISNULL(a.settle_price, a.last_total_price) > 0) Then ROUND(ISNULL(a.settle_price, a.last_total_price) - ROUND(ISNULL(a.settle_price, a.last_total_price)/1.1, 0), 0)
					Else 7500
				End
			Else ROUND(ISNULL(a.settle_price, a.last_total_price) - ROUND(ISNULL(a.settle_price, a.last_total_price)/1.1, 0), 0)
		End AS h_superTax	
		
		, Case When c.company_seq in (232,1137,1250,2235) Then   --디지털플라자, 워커힐, G마켓 (후불결제), 전자랜드 
				Case When c.company_seq  IN ( 1250)  Then a.Reduce_price * -1  --지마켓
						When (b.item_type = 'F' and ISNULL(b.Item_Amnt, 0) > 0) 
							or (a.up_order_seq is not null and ISNULL(a.settle_price, a.last_total_price) > 0) 
							or ( b.item_type in ('SVC') and ISNULL(a.settle_price, a.last_total_price) > 0) Then ISNULL(a.settle_price, a.last_total_price)
					
					Else 82500
				End
			Else ISNULL(a.settle_price, a.last_total_price)
		  End AS h_sumPrice 
		  	
		, 0 AS h_optionPrice
		, CASE WHEN ISNULL(O.h_comcode, '') = '1489998' THEN ISNULL(C.ERP_PartCode, ISNULL(O.h_partCode, '')) ELSE O.h_partCode  END  --1489998	BA_제휴사 일때만 C.ERP_PartCode 이걸루 수정 20111120 이상민
		, ISNULL(O.h_staffcode, '') 
		, '110' AS h_sonik

		, CASE WHEN ISNULL(C.ERP_PartCode, '') = '366' THEN '149' ELSE ISNULL(O.h_cost, '')  END AS h_cost --366	웨딩(비직영) 일때 149 웨딩제휴 로 수정 20150318 
		
		, CASE WHEN ISNULL(a.pg_tid, '') like 'bhand%' 
			THEN 'IC'+Cast(a.order_seq as nvarchar(50)) 
			ELSE 
				CASE WHEN ISNULL(LTRIM(RTRIM(a.pg_tid)), '') = '' 
					THEN  'IC'+Cast(a.order_seq as nvarchar(50)) 
					ELSE  ISNULL(a.pg_tid, 'IC'+Cast(a.order_seq as nvarchar(50))) END END AS h_orderid
		--, ISNULL(a.pg_tid, 'IC'+Cast(a.order_seq as nvarchar(50)) )  AS 	h_orderid

		, Case When a.sales_gubun = 'U' Then 'Inisis' 
				Else ISNULL(a.pg_tid, 'IC'+Cast(a.order_seq as nvarchar(50)) ) End AS h_memo2
		
	
		--**************************************************************************************************************
		--   * 아이템별 셋팅
		--**************************************************************************************************************
		, 'BK10'				AS b_biz
		, 'SO'					AS b_goodGubun
		, 1						AS b_seq
		, 'MF03'				AS b_storeCode
		, CONVERT(CHAR(8), a.src_send_date, 112) AS b_date
		, b.Card_ErpCode		AS b_goodCode	
		, 'EA'					AS b_goodUnit		
		, b.item_count			AS b_OrderNum

		--단가
		, CASE WHEN b.item_Type IN ('SVC')  THEN ISNULL(b.item_price, 0)  
			ELSE ISNULL(E.c_sobi, 0) END AS b_unitPrice

		--공급가액
		, CASE WHEN	b.item_Type IN ('SVC', 'F', 'S', 'M', 'L', 'V', 'H', 'X', 'W', 'J') AND ISNULL(b.Item_Amnt, 0) > 0		THEN ROUND( ISNULL(b.Item_Amnt, 0) / 1.1, 0)  
				WHEN b.item_Type IN ('SVC', 'F', 'S', 'M', 'L', 'V', 'H', 'X', 'W', 'J') AND ISNULL(b.Item_Amnt, 0) <= 0	THEN 0
			ELSE ROUND((ISNULL(E.c_sobi, 0) * ISNULL(b.item_count, 0)) / 1.1, 0) END AS b_offerPrice  

		--부가세
		, CASE WHEN	b.item_Type IN ('SVC', 'F', 'S', 'M', 'L', 'V', 'H', 'X', 'W', 'J') AND ISNULL(b.Item_Amnt, 0) > 0		THEN ROUND(ISNULL(b.Item_Amnt, 0), 0) - ROUND( ISNULL(b.Item_Amnt, 0) / 1.1, 0)  
				WHEN b.item_Type IN ('SVC', 'F', 'S', 'M', 'L', 'V', 'H', 'X', 'W', 'J') AND ISNULL(b.Item_Amnt, 0) <= 0	THEN 0
			ELSE ROUND(ISNULL(E.c_sobi, 0) * ISNULL(b.item_count, 0), 0) - ROUND((ISNULL(E.c_sobi, 0) * ISNULL(b.item_count, 0)) / 1.1, 0) END AS b_superTax  
			
		--합계금액
		, CASE WHEN	b.item_Type IN ('SVC', 'F', 'S', 'M', 'L', 'V', 'H', 'X', 'W', 'J') AND ISNULL(b.Item_Amnt, 0) > 0		THEN ROUND(ISNULL(b.Item_Amnt, 0), 0)
				WHEN b.item_Type IN ('SVC', 'F', 'S', 'M', 'L', 'V', 'H', 'X', 'W', 'J') AND ISNULL(b.Item_Amnt, 0) <= 0	THEN 0
			ELSE ROUND(ISNULL(E.c_sobi, 0) * ISNULL(b.item_count, 0), 0) END AS b_sumPrice  


		, NULL AS b_memo
		, GETDATE() AS reg_date

		--**************************************************************************************************************
		--   * PG수수료 (PG로 넘어가는 것은 수수료를 셋팅해 준다.)
		--   pgFee getPGFee 함수 호출 (pg아이디, 결제수단, 결제금액, 카드사정보)
		--**************************************************************************************************************
		, dbo.getPGFee_New (a.pg_shopid, a.settle_method, ISNULL(a.settle_price, a.last_total_price)) AS FeeAmnt	 --2009년 3월 16일 결제부터 새로운 PG수수료율 적용		
		, 'ITEM' AS ItemGubun
		, Case When a.sales_gubun = 'B' Then 
					Case When  c.company_seq in (232,1137,1243,1250,2235) Then   --디지털플라자, 워커힐, G마켓 (후불결제), 전자랜드 
								Case When (b.item_type = 'F' and ISNULL(b.item_price, 0) > 0) 
										or (a.up_order_seq is not null and ISNULL(a.settle_price, a.last_total_price) > 0) 
										or  ( b.item_type in ('SVC') and ISNULL(a.settle_price, a.last_total_price) > 0) Then 'Y'  -- 일반과세
										Else 'N'
									End	
							Else 'Y'
						End		
				ELSE O.PGCheck
			End AS PGCheck

		, 0 AS PayAmnt
		, 'N' AS SampleCheck
		, 'N' AS XartCheck	
		, NULL AS SettleDate
		, NULL AS PayDate
		, NULL AS PayCheck	
		, NULL AS b_memo_temp			
		, O.DeptGubun
		, a.inflow_route_settle
		, a.order_seq
		, a.order_g_seq
		, b.item_Type
FROM #custom_order a 
JOIN  #custom_order_item b ON a.order_seq = b.order_seq 
JOIN company c ON a.company_seq = c.company_seq
JOIN #CardMaster d ON b.card_seq = d.card_seq
LEFT JOIN #sales_gubunTemp O ON a.sales_gubun = O.sales_gubun 
LEFT JOIN [erpdb.bhandscard.com].XERP.DBO.itemSiteMaster E ON E.SiteCode = 'BK10' AND d.Card_ErpCode = E.ItemCode

WHERE a.status_Seq = 15 
	and a.pay_type <> '4' 
ORDER BY a.order_seq 




--**************************************************************************************************************
--2.샘플
--**************************************************************************************************************
	
--custom_sample_order 테이블에서 대상데이터를 임시테이블에 넣음. 20090805-이상민
SELECT *
INTO #custom_sample_order
FROM custom_sample_order A
WHERE CONVERT(CHAR(8), A.delivery_Date,112) BETWEEN @SDate AND @EDate
	AND A.STATUS_SEQ = 12
	and A.sales_gubun in ( 'W','T','J','B','S','G','SA', 'ST', 'SB', 'SW', 'SS', 'SP', 'SH', 'H', 'C', 'SG', 'P' ) 



	INSERT INTO #erp_salesReport 
	( 	h_biz, h_gubun, h_date, h_sysCode, h_usrCode, h_comcode, h_taxType, h_offerPrice, h_superTax, h_sumPrice
		, h_partCode, h_staffcode, h_sonik, h_cost, h_orderid, h_memo2
		, b_biz, b_goodGubun, b_seq, b_storeCode, b_date, b_goodCode, b_goodUnit, b_OrderNum, b_unitPrice, b_offerPrice, b_superTax, b_sumPrice
		, b_memo, reg_date, FeeAmnt, ItemGubun, PGCheck, PayAmnt, SampleCheck, XartCheck, SettleDate, PayDate, PayCheck, b_memo_temp, DeptGubun 
		, order_seq , order_g_seq 
	)

	SELECT 
		h_biz		= 'BK10',
		h_gubun		= 'SO',
		h_date		= Convert(char(8),a.delivery_Date,112),
		h_sysCode	= Case When b.Card_ErpCode = 'TBB' Then @SysCode3  Else @SysCode3 End,
		h_usrCode	= Case When b.Card_ErpCode = 'TBB' Then @UsrCode3  Else @UsrCode3 End,
		
		h_comcode	= CASE	WHEN a.PG_MERTID IN ( 'bhands_b' ) THEN '2011022'	--비핸즈사이트
							WHEN a.PG_MERTID IN ( 'pbhands' ) THEN '1450073'	--스토리오브러브(시즌2)
							WHEN a.PG_MERTID IN ( 'bhandscad1', 'bhandscas0', 'IESbhandsc' ) THEN '2014081'	--바른손카드(이니시스)
							WHEN a.PG_MERTID IN ( 'mbarunsonc' ) THEN '2014242'	--M바른손(이니시스)
							WHEN a.PG_MERTID IN ( 'mbhandscar' ) THEN '2014243'	--M비핸즈(이니시스)
							WHEN a.PG_MERTID IN ( 'KCBRC0001m' ) THEN '2015272'	--바른손카드(카카오)
							WHEN a.PG_MERTID IN ( 'KCBRC0002m' ) THEN '2015273'	--비핸즈(카카오)
							WHEN a.PG_MERTID IN ( 'KCBRC0003m' ) THEN '2015274'	--프리미어(카카오)
							WHEN a.PG_MERTID IN ( 'KCBRC0004m' ) THEN '2015275'	--제휴(카카오)
							WHEN a.PG_MERTID IN ( 'KCBRC0005m' ) THEN '2016130'	--더카드(카카오)
							WHEN a.PG_MERTID IN ( 'bhands_cm' ) THEN '2016204'	--M바른손(유플러스)
							WHEN a.PG_MERTID IN ( 'bhands_bm' ) THEN '2016199'	--M비핸즈(유플러스)
							WHEN a.PG_MERTID IN ( 'bhands_them' ) THEN '2016217'	--M더카드(유플러스)
							WHEN a.PG_MERTID IN ( 'pbhands_m' ) THEN '2017080'	--M프리미어(유플러스)

							WHEN a.sales_gubun in ( 'C', 'H') THEN 
								CASE WHEN c.COMPANY_SEQ = 5780 THEN '2012664'  --이지웰 
									WHEN c.COMPANY_SEQ = 5787 THEN '2012692'  --SK베네피아 
								ELSE O.h_comcode END
					
						ELSE O.h_comcode END , 		
						
		h_taxType = CASE WHEN a.sales_gubun = 'U' THEN '10' ELSE '22' END , 
		h_offerPrice	= Round(a.settle_price/1.1,0),	
		h_superTax		= Round(a.settle_price- a.settle_price/1.1,0),	
		h_sumPrice		= a.settle_price,
		CASE WHEN ISNULL(O.h_comcode, '') = '1489998' THEN ISNULL(C.ERP_PartCode, ISNULL(O.h_partCode, '')) ELSE O.h_partCode  END,  --1489998	BA_제휴사 일때만 C.ERP_PartCode 이걸루 수정 20111120 이상민
		CASE WHEN ISNULL(C.ERP_PartCode, '') = '366' THEN '090401' ELSE O.h_staffcode  END,  --366	웨딩(비직영) 일때 080401배민영으로 수정 20141120  (구: O.h_staffcode )
		h_sonik		= '110',
		CASE WHEN ISNULL(C.ERP_PartCode, '') = '366' THEN '149' ELSE O.h_cost  END,  --366	웨딩(비직영) 일때 149 웨딩제휴 로 수정 20141120  (구: O.h_cost )
		h_orderid	=  ISNULL(a.PG_TID, 'IS'+ Cast(a.sample_order_seq as varchar(50))),
		h_memo2		= Case When a.sales_gubun = 'U' Then 'Inisis' Else a.pg_tid End,
		b_biz		= 'BK10',
		b_goodGubun	= 'SO',
		b_seq		= 1,
		b_storeCode	= 'MF15',	--MF15:샘플전자상거래(제품)
		b_date		= Convert(char(8),a.delivery_Date,112),
		b_goodCode	= Case When b.Card_ErpCode = 'TBB' Then 'TBB' Else  d.Card_ErpCode End,
		b_goodUnit	= 'EA',
		b_OrderNum	= b.card_count,
		b_unitPrice	= Case When b.Card_ErpCode = 'TBB' Then a.settle_price			 --샘플은 금액 0원, 택배비에만 금액 부과
							Else 0 End ,
		b_offerPrice = Case When b.Card_ErpCode = 'TBB' Then Round(a.settle_price/1.1, 0)		
							Else 0 End ,
		b_superTax	= Case When b.Card_ErpCode = 'TBB' Then Round(a.settle_price - (a.settle_price/1.1) ,0)	
							Else 0 End ,
		b_sumPrice	= Case When b.Card_ErpCode = 'TBB' Then  a.settle_price
						Else 0 End ,
		b_memo		= null,
		reg_date	= getdate(),
		FeeAmnt		=  dbo.getPGFee_New (a.pg_mertid, a.settle_method, a.settle_price), --2009년 3월 16일 결제부터 새로운 PG수수료율 적용		
		ItemGubun	= 'item',
		O.PGCheck, 		
		PayAmnt		= 0,
		SampleCheck	= 'Y',
		XartCheck	= 'N',
		SettleDate	= null,
		PayDate		= null,
		PayCheck	= null,
		b_memo_temp	= null,
		O.DeptGubun , 
		a.sample_order_seq, 
		a.order_g_seq
		
		
	FROM #custom_sample_order a 
	JOIN (
				SELECT sample_order_seq, card_seq, Card_ErpCode, settle_price, card_count 
				FROM  (
						SELECT a.sample_order_seq,  b.card_seq,  'ITEM' as Card_ErpCode, settle_price, 1 as card_count  
						FROM #custom_sample_order a 
						JOIN custom_sample_order_item b ON a.sample_order_seq = b.sample_order_seq
						WHERE Convert(char(8),a.delivery_Date,112) between @SDate and @EDate 
					) c
					
				UNION
				-- 내지정보  
				SELECT a.sample_order_seq,d.card_seq as card_seq, 'ITEM' as Card_ErpCode,a.settle_price,count(*) as card_count  
				FROM #custom_sample_order a 
				JOIN custom_sample_order_item b ON a.sample_order_seq = b.sample_order_seq
				JOIN #CardMaster c ON b.card_seq = c.card_seq
				JOIN #CardMaster d ON c.cont_seq = d.card_seq
				WHERE Convert(char(8),a.delivery_Date,112) between @SDate and @EDate and c.cont_seq is not null and c.cont_seq <> '0'
				GROUP BY a.sample_order_seq, d.card_seq,a.settle_price
				
				UNION
				-- 악세사리1 정보 
				SELECT a.sample_order_seq, d.card_seq as card_seq, 'ITEM' as Card_ErpCode ,a.settle_price,count(*) as card_count 
				FROM #custom_sample_order a 
				JOIN custom_sample_order_item b ON a.sample_order_seq = b.sample_order_seq
				JOIN #CardMaster c	ON b.card_seq = c.card_seq
				JOIN #CardMaster d	ON c.acc_seq = d.card_seq
				WHERE Convert(char(8),a.delivery_Date,112) between @SDate and @EDate and c.acc_seq is not null and c.acc_seq <> '0'
				GROUP BY a.sample_order_seq, d.card_seq,a.settle_price

				UNION
				-- 악세사리2 정보 
				SELECT a.sample_order_seq,d.card_seq as card_seq, 'ITEM' as Card_ErpCode,a.settle_price,count(*) as card_count 
				FROM #custom_sample_order a 
				JOIN custom_sample_order_item b ON a.sample_order_seq = b.sample_order_seq
				JOIN #CardMaster c	ON b.card_seq = c.card_seq
				JOIN #CardMaster d 	ON c.acc_seq2 = d.card_seq
				WHERE Convert(char(8),a.delivery_Date,112) between @SDate and @EDate and c.acc_seq2 is not null and c.acc_seq2 <> '0'
				GROUP BY a.sample_order_seq, d.card_seq,a.settle_price

				UNION
				-- 약도카드
				SELECT a.sample_order_seq,d.card_seq as card_seq, 'ITEM' as Card_ErpCode,a.settle_price,count(*) as card_count 
				FROM #custom_sample_order a 
				JOIN custom_sample_order_item b ON a.sample_order_seq = b.sample_order_seq
				JOIN #CardMaster c	ON b.card_seq = c.card_seq
				JOIN #CardMaster d 	ON c.MapCard_Seq = d.card_seq
				WHERE Convert(char(8),a.delivery_Date,112) between @SDate and @EDate 
					and c.MapCard_Seq is not null and c.MapCard_Seq <> 0
				GROUP BY a.sample_order_seq, d.card_seq,a.settle_price
						
				UNION
				SELECT  sample_order_seq, 1, 'TBB' as Card_ErpCode, settle_price, 1 as card_count
				FROM #custom_sample_order 
				WHERE Convert(char(8),delivery_Date,112) between @SDate and @EDate 
				
			)  b ON a.sample_order_seq = b.sample_order_seq

	JOIN company c ON a.company_seq = c.company_seq
	JOIN #CardMaster d ON b.card_seq = d.card_seq
	LEFT JOIN #sales_gubunTemp O ON a.sales_gubun = O.sales_gubun
	WHERE a.status_seq = 12 

	ORDER BY a.sample_order_seq 




--**************************************************************************************************************
 --3. 미니청첩장 및 식권 등 옵션 상품 따로 주문시 
--**************************************************************************************************************


--custom_etc_order 테이블에서 대상데이터를 임시테이블에 넣음. 20090805-이상민
SELECT *
INTO #custom_etc_order
FROM custom_etc_order A
WHERE CONVERT(CHAR(8), A.delivery_Date,112) BETWEEN @SDate AND @EDate
	and A.status_seq >= 12 
	and A.sales_gubun in ( 'W','T','J','B','S','G','SA', 'ST', 'SB', 'SW', 'SS', 'SP', 'SH', 'H', 'C', 'SG', 'P' ) --비핸즈, 더카드

	
	INSERT INTO #erp_salesReport 
	( 	h_biz, h_gubun, h_date, h_sysCode, h_usrCode, h_comcode, h_taxType, h_offerPrice, h_superTax, h_sumPrice
		, h_partCode, h_staffcode, h_sonik, h_cost, h_orderid, h_memo2
		, b_biz, b_goodGubun, b_seq, b_storeCode, b_date, b_goodCode, b_goodUnit, b_OrderNum, b_unitPrice, b_offerPrice, b_superTax, b_sumPrice
		, b_memo, reg_date, FeeAmnt, ItemGubun, PGCheck, PayAmnt, SampleCheck, XartCheck, SettleDate, PayDate, PayCheck, b_memo_temp, DeptGubun 
		, order_seq, order_g_seq, item_type
	)
	
	SELECT 
		h_biz		= 'BK10',
		h_gubun		= 'SO',
		h_date		= Convert(char(8),a.delivery_date,112),
		h_sysCode	= @SysCode1,
		h_usrCode	= @UsrCode1, 	
		h_comcode	= CASE	WHEN a.sales_gubun in ( 'C', 'H') AND c.COMPANY_SEQ = 5780 Then '2012664'  --이지웰 
							WHEN a.sales_gubun in ( 'C', 'H') AND c.COMPANY_SEQ = 5787 Then '2012692'  --SK베네피아 

							WHEN a.pg_shopid IN ( 'bhands_b' ) THEN '2011022'	--비핸즈사이트
							WHEN a.pg_shopid IN ( 'pbhands' ) THEN '1450073'	--스토리오브러브(시즌2)
							WHEN a.pg_shopid IN ( 'bhandscad1', 'bhandscas0', 'IESbhandsc' ) THEN '2014081'	--바른손카드(이니시스)
							WHEN a.pg_shopid IN ( 'mbarunsonc' ) THEN '2014242'	--M바른손(이니시스)
							WHEN a.pg_shopid IN ( 'mbhandscar' ) THEN '2014243'	--M비핸즈(이니시스)
							WHEN a.pg_shopid IN ( 'KCBRC0001m' ) THEN '2015272'	--바른손카드(카카오)
							WHEN a.pg_shopid IN ( 'KCBRC0002m' ) THEN '2015273'	--비핸즈(카카오)
							WHEN a.pg_shopid IN ( 'KCBRC0003m' ) THEN '2015274'	--프리미어(카카오)
							WHEN a.pg_shopid IN ( 'KCBRC0004m' ) THEN '2015275'	--제휴(카카오)
							WHEN a.pg_shopid IN ( 'KCBRC0005m' ) THEN '2016130'	--더카드(카카오)
							WHEN a.pg_shopid IN ( 'bhands_cm' ) THEN '2016204'	--M바른손(유플러스)
							WHEN a.pg_shopid IN ( 'bhands_bm' ) THEN '2016199'	--M비핸즈(유플러스)
							WHEN a.pg_shopid IN ( 'bhands_them' ) THEN '2016217'	--M더카드(유플러스)
							WHEN a.pg_shopid IN ( 'pbhands_m' ) THEN '2017080'	--M프리미어(유플러스)	
							
						ELSE O.h_comcode END,				
						
		h_taxType = CASE WHEN a.sales_gubun = 'U' THEN '10' ELSE '22' END , 
		h_offerPrice	= Round(a.settle_price/1.1,0),				
		h_superTax		= Round(a.settle_price- a.settle_price/1.1,0),	
		h_sumPrice		= a.settle_price,	
		
		h_partCode = CASE WHEN ISNULL(O.h_comcode, '') = '1489998' THEN ISNULL(C.ERP_PartCode, ISNULL(O.h_partCode, '')) ELSE O.h_partCode  END,  --1489998	BA_제휴사 일때만 C.ERP_PartCode 이걸루

		h_staffcode = O.h_staffcode, 
		h_sonik		= '110',
		h_cost		= O.h_cost, 
		h_orderid	= Case When a.pg_shopid = '2ucard0001'	Then 'ET'+Cast(a.order_seq as nvarchar(20))  Else ISNULL(a.pg_tid, 'ET'+Cast(a.order_seq as nvarchar(20)) )  End,	
		h_memo2		= Case When a.sales_gubun = 'U' Then 'Inisis' Else a.pg_tid End,
		
		b_biz		= 'BK10',
		b_goodGubun	= 'SO',
		b_seq		= 1,
		b_storeCode	= 'MF03',
		b_date		= Convert(char(8),a.delivery_date,112),
		b_goodCode	= b.Card_ErpCode, --b.item_type
		b_goodUnit	= 'EA',
		b_OrderNum	=  Case  When b.Card_ErpCode = 'BSI010' Then (b.order_count/50)*6  
							When b.Card_ErpCode IN ( 'BSI050', 'BSI051', 'BSI052', 'BSI053' ) AND b.order_count < 50 Then b.order_count * 25  --스티커 'BSI050', 'BSI051', 'BSI052', 'BSI053' 1판에25장으로 계산해서 입력(정광수차장요청)
							When b.Card_ErpCode IN ( 'BSI032' ) AND b.order_count < 100 Then b.order_count * 50  --스티커 'BSI032' 1장에 50장으로 계산해서 입력
							When b.Card_ErpCode IN ( 'BSI075' ) AND b.order_count < 40 Then b.order_count * 20  --스티커 'BSI075' 1장에 20장으로 계산해서 입력 
						Else b.order_count End,	
		
		--**************************************************************************************************************
		--   * 아이템별 금액 셋팅
		--**************************************************************************************************************
		b_unitPrice	 =  Case When b.Card_ErpCode = 'TBB' Then ISNULL(b.item_price, 0)	Else e.c_sobi End,
		b_offerPrice =  Case When b.Card_ErpCode = 'TBB' Then Round(ISNULL(b.item_price, 0)/1.1,0)	Else Round(e.c_sobi*b.order_count/1.1,0) End,	
		b_superTax	 =  Case When b.Card_ErpCode = 'TBB' Then ISNULL(b.item_price, 0) - Round(ISNULL(b.item_price, 0)/1.1,0)	Else (e.c_sobi*b.order_count) - Round(e.c_sobi*b.order_count/1.1,0) End,	
		b_sumPrice	 =  Case When b.Card_ErpCode = 'TBB' Then ISNULL(b.item_price, 0)	Else e.c_sobi*b.order_count End,	
		b_memo		= null,
		reg_date	= getdate(),		
		FeeAmnt		=  dbo.getPGFee_New (a.pg_shopid, a.settle_method, a.settle_price), --2009년 3월 16일 결제부터 새로운 PG수수료율 적용			
		ItemGubun	= 'ITEM',
		O.PGCheck, 
		PayAmnt		= 0,
		SampleCheck	= 'N',
		XartCheck	= 'N',
		SettleDate	= null,
		PayDate		= null,
		PayCheck	= null,
		b_memo_temp	= null,
		O.DeptGubun,
		a.order_seq, 
		a.order_g_seq,
		b.Item_Type
		
	FROM #custom_etc_order a 
	JOIN (
			--기본 주문정보
			SELECT a.order_seq, b.card_seq, c.Card_ErpCode, b.order_count, b.card_sale_price as item_price , '' AS Item_Type
			FROM #custom_etc_order a 
			JOIN custom_etc_order_item b ON a.order_seq = b.order_seq
			JOIN #CardMaster c ON b.card_seq = c.card_seq
			WHERE  b.order_count > 0
			AND a.order_type NOT IN ('AA','BB','CC','DD','EE') --답례품 제외

			--#6003 ERP 답례품 매출 코드분리 요청 :  ERP
			UNION ALL--답례품
			SELECT a.order_seq, b.card_seq, b.card_erp_code Card_ErpCode, b.order_count, b.card_sale_price as item_price , '' AS Item_Type
			FROM #custom_etc_order a 
			JOIN custom_etc_order_gift_item b ON a.order_seq = b.order_seq
			--JOIN #CardMaster c ON b.card_erp_code = c.Card_ErpCode
			WHERE  b.order_count > 0
		    AND a.order_type IN ('AA','BB','CC','DD','EE') -- 답례품만 
			AND b.Use_Yn = 'Y' -- Y/N (Y:결제요청 완료시, N:주문데이터 insert시) 

			UNION ALL --택배비
			SELECT order_seq, 123,  'TBB' as Card_ErpCode, 1 as order_count , delivery_price as item_price, 'SVC' AS Item_Type
			FROM #custom_etc_order  
			WHERE delivery_price > 0

		) b ON a.order_seq = b.order_seq
	JOIN company c ON a.company_seq = c.company_seq
	LEFT JOIN #sales_gubunTemp O ON a.sales_gubun = O.sales_gubun
	LEFT JOIN [erpdb.bhandscard.com].XERP.DBO.ItemSiteMaster E ON E.SiteCode = 'BK10' AND b.Card_ErpCode = E.ItemCode

	WHERE 1=1		
	ORDER BY a.order_seq 



--**************************************************************************************************************
--   * 할인율에 맞추어 각 아이템 금액 재계산  	
--**************************************************************************************************************
	UPDATE #erp_salesReport 
	SET h_optionPrice = a.option_sumPrice ,
		DiscountRate  = a.discountRate,	 
		b_sumPrice    =	Case 
							When item_type IN ( 'F', 'L', 'H', 'SVC', 'X', 'W', 'J' ) Then b.b_sumPrice
							Else ROUND( ((b.b_sumPrice * (100-a.DiscountRate)/100)/1.1) 
								+ (b.b_sumPrice * (100-a.DiscountRate)/100) - ((b.b_sumPrice * (100-a.DiscountRate)/100)/1.1), 0)
						End,
 		b_offerPrice    = CASE 
							When item_type IN ( 'F', 'L', 'H', 'SVC', 'X', 'W', 'J' ) Then Round(b.b_sumPrice/1.1, 0)
							ELSE  Round( ( ((b.b_sumPrice * (100-a.DiscountRate)/100)/1.1) 
								+ (b.b_sumPrice * (100-a.DiscountRate)/100) - ((b.b_sumPrice * (100-a.DiscountRate)/100)/1.1) ) / 1.1, 0)
						
						End,
 		b_superTax    = CASE 
							When b.item_type IN ( 'F', 'L', 'H', 'SVC', 'X', 'W', 'J' ) Then Round(b.b_sumPrice - b.b_sumPrice/1.1,0)
							ELSE ROUND( 
										((b.b_sumPrice * (100-a.DiscountRate)/100)/1.1) + (b.b_sumPrice * (100-a.DiscountRate)/100) - ((b.b_sumPrice * (100-a.DiscountRate)/100)/1.1)
									, 0)
								- ROUND( 
										(((b.b_sumPrice * (100-a.DiscountRate)/100)/1.1) + (b.b_sumPrice * (100-a.DiscountRate)/100) - ((b.b_sumPrice * (100-a.DiscountRate)/100)/1.1) ) / 1.1
									, 0)
						End
							
	FROM #erp_salesReport  b 
	JOIN (		
				SELECT a.h_orderid
					, c.option_sumprice
					, b.b_sumprice
					, a.h_sumPrice				
					
					, CASE WHEN ISNULL(c.option_sumprice, 0) = 0 
						THEN CASE WHEN ISNULL(b.b_sumprice, 0) = 0 
								THEN 0 
								ELSE ((ISNULL(b.b_sumprice, 0) - ISNULL(a.h_sumprice, 0))*100 )/ b.b_sumprice 
								END
						ELSE CASE WHEN (ISNULL(b.b_sumprice, 0)- ISNULL(c.option_sumprice, 0)) = 0 
								THEN 0 
								ELSE (((ISNULL(b.b_sumprice, 0)-ISNULL(c.option_sumprice, 0)) - (ISNULL(a.h_sumprice, 0)-ISNULL(c.option_sumprice, 0)))*100) / (ISNULL(b.b_sumprice, 0)- ISNULL(c.option_sumprice, 0)) 
								END
						END AS DiscountRate
				FROM #erp_salesReport  a 
				JOIN (	
						--아이템 합계 금액 
						 SELECT h_orderid
							, SUM(ISNULL(b_offerprice, 0)) as b_offerPrice
							, SUM(ISNULL(b_superTax, 0)) as b_superTax
							, SUM(ISNULL(b_sumprice, 0)) as b_sumPrice 
						 FROM #erp_salesReport 
						 GROUP BY h_orderid
					) b ON a.h_orderid = b.h_orderid	
				LEFT JOIN (
							--옵션비용  합계 금액
							SELECT h_orderid
								,  SUM(ISNULL(b_sumprice, 0)) AS option_sumPrice 
							FROM #erp_salesReport
							WHERE item_type IN ( 'F', 'L', 'H', 'SVC', 'X', 'W', 'J' )
							GROUP BY h_orderid
					) c ON a.h_orderid = c.h_orderid		
				WHERE 1=1
						
		) a  ON a.h_orderid = b.h_orderid	
	WHERE b.SampleCheck = 'N'


--**************************************************************************************************************
--b_seq를 생성해 내기 위한 Temp 테이블 생성
--**************************************************************************************************************
	SELECT  IDENTITY(int, 1, 1) AS seq, h_OrderID, b_goodCode, b_sumPrice,h_sysCode
	INTO #TempSEQ
	FROM #erp_salesReport   
	ORDER BY h_Orderid ASC, b_sumPrice DESC, b_goodCode

								
																
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
		  



	--BH5193A ERP연동시 수량조정.. 1SET = 5EA (정광수차장 요청) 20151014
	UPDATE #erp_salesReport
	SET b_OrderNum = ISNULL(b_OrderNum, 0)/5.0
	WHERE b_goodCode = 'BH5193A' AND ISNULL(b_OrderNum, 0) > 0
	
	--BH4021_I 내지는 수량이 반만 출고가 되도록 진행 (정광수차장 요청) 20141230	
	UPDATE #erp_salesReport
	SET b_OrderNum = ISNULL(b_OrderNum, 0)/2.0
	WHERE b_goodCode = 'BH4021_I' AND ISNULL(b_OrderNum, 0) > 0
		
	UPDATE #erp_salesReport
	SET b_unitPrice = ROUND(b_sumPrice/b_OrderNum, 0)
	WHERE b_sumPrice > 0 AND b_OrderNum > 0


	

	--BH8211A ERP연동시 수량조정.. 
	--SET 단위로 연동시 EA단위로 변환 1SET=50EA. 20200812
	UPDATE #erp_salesReport
	SET b_OrderNum = ISNULL(b_OrderNum, 0) * 50
	WHERE b_goodCode = 'BH8211A' 
		AND ISNULL(b_OrderNum, 0) BETWEEN 1 AND 49 
		 AND ( h_sysCode <> '300' OR h_usrCode <> '308')  --샘플주문건 제외조건.


	
	--제휴사안내카드(7932) 사이트 주문건은 타계정대체(샘플-판매촉진비) 출고유형으로 나가도록 수정.20200310
	--타계정대체(샘플-판매촉진비)(300,308)
	UPDATE #erp_salesReport
	SET h_sysCode = '300'
		, h_usrCode = '308'
	WHERE order_seq in ( select order_seq from #custom_order where company_seq = 7932 )


	--답례품 상품매출이 있을 경우 MF24(셀레모창고)로 연동되도록 지정(정소연요청)
	UPDATE #erp_salesReport
	SET b_storeCode = 'MF24'    --셀레모(답례품)창고코드
		, h_partCode = '205'	--부서코드
		, h_cost = '205'		--CcCode
		, h_StaffCode = '130503' 	--담당자코드
	WHERE h_orderId IN ( 
				SELECT h_orderid 
				FROM #erp_salesReport A
				JOIN OPENQUERY([erpdb.bhandscard.com], 'SELECT ItemCode FROM XERP.DBO.ItemSiteMaster WHERE SiteCode = ''BK10'' AND ItemGroup = ''G1751''')  B ON A.b_goodCode = B.ItemCode	
			)
	



	--20100324
	SELECT  IDENTITY(int, 1, 1) AS ItemSerNo, *
	INTO #ERP_SalesDataTemp
	FROM #erp_salesReport
	ORDER BY h_Orderid ASC, b_sumPrice DESC, b_goodCode 
	

	--select * from #ERP_SalesDataTemp where h_Orderid like '%2458873%'

--**************************************************************************************************************
--Erp_salesData에 Insert
--**************************************************************************************************************


	
	SELECT  a.h_biz, a.h_gubun, a.h_date, a.h_sysCode, a.h_usrCode, a.h_comcode, a.h_taxType, a.h_offerPrice, a.h_superTax, a.h_sumPrice
		, a.h_partCode, a.h_staffcode, a.h_sonik, a.h_cost, a.h_orderid, a.h_memo2
		, a.b_biz, a.b_goodGubun, b.b_seq, a.b_storeCode, a.b_date, a.b_goodCode, a.b_goodUnit, a.b_OrderNum, a.b_unitPrice, a.b_offerPrice, a.b_superTax, a.b_sumPrice
		, a.b_memo, a.reg_date, a.FeeAmnt, a.ItemGubun, a.PGCheck, a.PayAmnt, a.SampleCheck, a.XartCheck, a.SettleDate, a.PayDate, a.PayCheck, a.b_memo_temp, a.DeptGubun
		, a.order_seq, a.order_g_seq, G.pg_tid, a.inflow_route_settle
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
	
	LEFT JOIN Custom_order_Group G ON A.order_g_seq = G.order_g_seq
	
	WHERE c.h_orderid is null

GO
