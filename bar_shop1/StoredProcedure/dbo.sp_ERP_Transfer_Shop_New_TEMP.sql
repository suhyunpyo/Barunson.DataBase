IF OBJECT_ID (N'dbo.sp_ERP_Transfer_Shop_New_TEMP', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_ERP_Transfer_Shop_New_TEMP
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ##########################################################################################################      
-- 영업2본부 매출 연동
-- 업데이트내역
   -- 1. 2009.06.03
   --==> 샘플 출고시 내지정보와 악세사리 정보도 함께 출력되도록 적용 
-- ########################################################################################################## 


--SP_LOCK
-- EXEC sp_ERP_Transfer_Shop_New '20180529','20180529'
-- select * from custom_etc_order where order_type = 'H' and status_seq = 12

CREATE PROCEDURE [dbo].[sp_ERP_Transfer_Shop_New_TEMP]
 @SDate as char(8)
 , @EDate as char(8)

AS
SET NOCOUNT ON



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
	and convert(char(8), A.Order_date,112) >= '20130101'
	and A.sales_gubun in ( 'W','T','J','B','S','G','SA', 'ST', 'SB', 'SW', 'SS', 'SP', 'SH', 'H', 'C', 'SG', 'P' ) --비핸즈, 더카드

		
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
SELECT 'SB' AS sales_gubun, '1450071' AS h_comcode, 'N110' AS h_partCode, '030603' AS h_staffcode, '511' AS h_cost, 'Y' AS PGCheck, 'SB' AS DeptGubun , '5001' AS Company_seq UNION ALL		--바른손카드
SELECT 'SA' AS sales_gubun, '2011022' AS h_comcode, 'N230' AS h_partCode, '171001' AS h_staffcode, '523' AS h_cost, 'Y' AS PGCheck, 'SA' AS DeptGubun , '5006' AS Company_seq UNION ALL		--비핸즈카드
SELECT 'SS' AS sales_gubun, '1450073' AS h_comcode, 'N130' AS h_partCode, '171001' AS h_staffcode, '513' AS h_cost, 'Y' AS PGCheck, 'SS' AS DeptGubun , '5003' AS Company_seq UNION ALL		--프리미어페이퍼
SELECT 'ST' AS sales_gubun, '2011021' AS h_comcode, 'N140' AS h_partCode, '030603' AS h_staffcode, '514' AS h_cost, 'Y' AS PGCheck, 'ST' AS DeptGubun , '5007' AS Company_seq UNION ALL		--더카드
SELECT 'C' AS sales_gubun,  '2012664' AS h_comcode, 'N230' AS h_partCode, '030603' AS h_staffcode, '523' AS h_cost, 'N' AS PGCheck, 'SA' AS DeptGubun , '5780' AS Company_seq UNION ALL		--이지웰	

--제휴영업
SELECT 'B' AS sales_gubun,  '1489998' AS h_comcode, '390'  AS h_partCode, '090401' AS h_staffcode, '148' AS h_cost, 'Y' AS PGCheck, 'BR' AS DeptGubun , '' AS Company_seq UNION ALL
SELECT 'H' AS sales_gubun,  '1489998' AS h_comcode, '390'  AS h_partCode, '090401' AS h_staffcode, '148' AS h_cost, 'Y' AS PGCheck, 'BR' AS DeptGubun , '' AS Company_seq UNION ALL

--글로벌사업팀
SELECT 'SG' AS sales_gubun, '2012563' AS h_comcode, '405'  AS h_partCode, '150602' AS h_staffcode, '405' AS h_cost, 'N' AS PGCheck, 'SG' AS DeptGubun , '' AS Company_seq UNION ALL

--O/B영업
SELECT 'P' AS sales_gubun, '1490020' AS h_comcode, '340-1'  AS h_partCode, '060404' AS h_staffcode, '112' AS h_cost, 'Y' AS PGCheck, 'OB' AS DeptGubun , '' AS Company_seq 


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
	SELECT a.order_seq, a.order_type, a.order_count,  a.mini_price, a.fticket_price, b.card_seq, c.Card_ErpCode, b.item_type, b.item_count as item_count, IsNUll(b.item_sale_price,0) as item_price
	INTO #custom_order_item_Temp
	FROM #custom_order a 
	JOIN custom_order_item b ON  a.order_seq = b.order_seq
	JOIN #CardMaster c ON b.card_seq = c.card_seq
	WHERE a.status_Seq = 15  -- 배송완료
		and convert(char(8),a.src_send_date,112) between @SDate AND @EDate
		and A.sales_gubun in ( 'W','T','J','B','S','G','SA', 'ST', 'SB', 'SW', 'SS', 'SP', 'SH', 'H', 'C', 'SG', 'P' ) --비핸즈, 더카드
	ORDER BY a.order_seq, b.card_seq


	
	----기본 아이템 정보
	--SELECT a.order_seq, a.order_type, a.order_count,  a.mini_price, a.fticket_price, b.card_seq, c.Card_ErpCode, b.item_type, b.item_count as item_count
	--	, IsNUll(b.item_sale_price,0) as item_price
	--INTO #custom_order_item_Temp
	--FROM custom_order a 
	--JOIN custom_order_item b ON  a.order_seq = b.order_seq
	--JOIN S2_Card c ON b.card_seq = c.card_seq
	--WHERE a.status_Seq = 15  -- 배송완료
	--	and a.order_seq = 2748752
	--	--and convert(char(8),a.src_send_date,112) between @SDate AND @EDate
	--	and A.sales_gubun in ( 'W','T','J','B','S','G','SA', 'ST', 'SB', 'SW', 'SS', 'SP', 'SH', 'H', 'C', 'SG', 'P' ) --비핸즈, 더카드
	--ORDER BY a.order_seq, b.card_seq
	


	--기본 아이템 정보 (무료식권, 무료 미니청첩장)
	SELECT order_seq,card_seq, Card_ErpCode,item_type, item_count, item_price
	INTO #custom_order_item
	FROM #custom_order_item_Temp
	WHERE item_count > 0 
			AND item_type not in ('F', 'M', 'L') --C:카드,E:봉투,I:내지,S:스티커,M:미니청첩장,F:식권,A:부속품 ,B:라벨지,R: 리본, L:방명록
			AND Card_ErpCode <> 'BPC001'

	--##################################################################################################################
	-- 미니청첩장
	--##################################################################################################################
	UNION 
	-- 1. 미니청첩장 독립주문 (스티커, 봉투 추가되어 나감)
	SELECT order_seq,card_seq, Card_ErpCode,item_type, item_count, item_price
	FROM #custom_order_item_Temp
	WHERE item_count > 0 and order_type = '5'
	
	UNION	
	-- 2. 무료제공 미니청첩장 (청첩장 400장 이상 주문한 경우 50장까지 무료)
	SELECT order_seq,card_seq, Card_ErpCode,item_type, item_count, item_price
	FROM #custom_order_item_Temp
	WHERE item_type = 'M' AND order_type <> '5'  and mini_price = 0
	
	UNION 
	-- 3. 유료제공 미니청첩장 (청첩장 400장 이상 주문한 경우 50장까지 무료 초과시 장당 200원 )
	-- 3.1 무료제공 수량 (400장 이상 주문시 50장 무료제공)
	SELECT order_seq,card_seq, Card_ErpCode,item_type, item_count, item_price
	FROM #custom_order_item_Temp
	WHERE item_type = 'M' AND order_type <> '5' -- order_type 주문타입(1:청첩장,2:감사장,3:초대장, 5:미니청첩장)
			and order_count >= 400 --400장 이상 주문한 경우 50장까지 무료제공 
			and mini_price <> 0	and item_count = 50	
	
	UNION
	-- 3.3 유료제공 수량 (주문수량 초과 수량)
	SELECT order_seq,card_seq, Card_ErpCode,item_type, item_count, item_price
	FROM #custom_order_item_Temp
	WHERE item_type = 'M' AND order_type <> '5' -- order_type 주문타입(1:청첩장,2:감사장,3:초대장, 5:미니청첩장)
			and order_count >= 400 --400장 이상 주문한 경우 50장까지 무료제공 
			and mini_price <> 0	and item_count > 50	

	UNION 
	-- 3.4 유료제공 수량 (청첩장 400장 이하 주문자)
	SELECT order_seq,card_seq, Card_ErpCode,item_type, item_count, item_price
	FROM #custom_order_item_Temp
	WHERE item_type = 'M' AND order_type <> '5' -- order_type 주문타입(1:청첩장,2:감사장,3:초대장, 5:미니청첩장)
			and order_count < 400 --400장 이상 주문한 경우 50장까지 무료제공 
			and mini_price <> 0	
	
	UNION
	-- 3.5 미니청첩장 스티커	
	SELECT order_seq, 6320 AS card_seq, 'BSI010' AS Card_ErpCode, 'S' AS item_type, item_count, item_price
	FROM #custom_order_item_Temp
	WHERE item_type = 'M' AND order_type <> '5' -- order_type 주문타입(1:청첩장,2:감사장,3:초대장, 5:미니청첩장)
			
	UNION ALL	 
	-- 3.5 미니청첩장 봉투
	SELECT order_seq, 6319 AS card_seq, 'BE029' AS Card_ErpCode, 'E' AS item_type, item_count, item_price
	FROM #custom_order_item_Temp
	WHERE item_type = 'M' AND order_type <> '5' -- order_type 주문타입(1:청첩장,2:감사장,3:초대장, 5:미니청첩장)

	--##################################################################################################################
	--방명록
	--##################################################################################################################
	UNION
	--방명록
	SELECT  a.order_seq, a.card_seq, a.Card_ErpCode, a.item_type
		, ISNULL(a.item_count, 0) as item_count 
		, ISNULL(a.item_count, 0) * ISNULL(a.item_price, 0) AS item_price
	FROM #custom_order_item_Temp a
	WHERE a.item_type = 'L' and a.item_count > 0  and a.item_price > 0

	--##################################################################################################################
	-- 식권
	--##################################################################################################################
	UNION
	--1.무료식권 주문시 (fticket_price가 0원일 경우)
	SELECT order_seq, card_seq, Card_ErpCode, item_type, item_count, item_price
	FROM #custom_order_item_Temp
	WHERE item_type = 'F' and fticket_price = 0
		and item_count > 0
	
	UNION
	--2.2 유료식권일 경우
	SELECT  a.order_seq, a.card_seq, a.Card_ErpCode, a.item_type
		, ISNULL(a.item_count, 0) as item_count 
		, ISNULL(a.item_count, 0) * ISNULL(a.item_price, 0) AS item_price
	FROM #custom_order_item_Temp a
	WHERE a.item_type = 'F' and a.fticket_price > 0 
		and a.item_count > 0	

	----2.2 유료식권일 경우(기존 20190131)
	--SELECT  a.order_seq, a.card_seq, a.Card_ErpCode, a.item_type
	--	, a.item_count as item_count 
	--	, Round((a.fticket_price/(a1.sum_count*1.00))*item_count,0)  as item_price
	--FROM #custom_order_item_Temp a
	--JOIN (
	--		  SELECT a.order_seq, a.order_count, sum(b.item_count) as sum_count
	--				,((order_count*100)/sum(item_count))/100.0 as disRate
	--		  FROM #custom_order a 
	--		  JOIN custom_order_item b ON a.order_seq = b.order_seq
	--		  WHERE b.item_type ='F' and b.item_count > 0	
	--		  GROUP BY a.order_seq, a.order_count			 	
	--	 ) a1 ON a.order_seq = a1.order_seq
	--WHERE a.item_type = 'F' and a.fticket_price > 0 
	--	and a.item_count > 0	


	--UNION 
	----2. 유료식권 주문시 (fticket_price가 있을 경우)
	----2.1 무료식권 추가일 경우 (청첩장 주문 수량을 초과하는 금액에 대하여 30원 과금)
	----2.1.1 무료수량
	--SELECT  a.order_seq, a.card_seq, a.Card_ErpCode, a.item_type
	--	, Round(a.item_count * a1.disRate, 0) as item_count
	--	, 0 as item_price
	--FROM #custom_order_item_Temp a
	--JOIN (
	--		  SELECT a.order_seq, a.order_count, sum(b.item_count) as sum_count
	--				,((order_count*100)/sum(item_count))/100.0 as disRate
	--		  FROM #custom_order a 
	--		  JOIN custom_order_item b ON a.order_seq = b.order_seq
	--		  WHERE b.item_type ='F' and b.item_count > 0	
	--		  GROUP BY a.order_seq, a.order_count			
			  
	--	 ) a1 ON a.order_seq = a1.order_seq
	--WHERE a.item_type = 'F' and a.fticket_price > 0 and a.item_count > 0		
	--	and a.Card_ErpCode in ('FSB01','FSB02','FSU01','FSU02','FST01','FST02','YC01','YC02') --무료식권

	
	--UNION
	----2.1.2 유료수량
	--SELECT  a.order_seq, a.card_seq, a.Card_ErpCode, a.item_type
	--	, a.item_count- Round(a.item_count * a1.disRate,0) as item_count
	--	, Round((a.fticket_price/(a1.sum_count*1.00))*item_count,0)  as item_price
	--FROM #custom_order_item_Temp a
	--JOIN (
	--		  SELECT a.order_seq, a.order_count, sum(b.item_count) as sum_count
	--				,((order_count*100)/sum(item_count))/100.0 as disRate
	--		  FROM #custom_order a 
	--		  JOIN custom_order_item b ON a.order_seq = b.order_seq
	--		  WHERE b.item_type ='F' and b.item_count > 0	
	--		  GROUP BY a.order_seq, a.order_count			 	
	
	--	 ) a1 ON a.order_seq = a1.order_seq
	--WHERE a.item_type = 'F' and a.fticket_price > 0 and a.item_count > 0		
	--	and a.Card_ErpCode in ('FSB01','FSB02','FSU01','FSU02','FST01','FST02','YC01','YC02') --무료식권
		
	

	--택배비	
	UNION 
	SELECT order_seq, card_seq,  'TBB', 'TBB', 1, delivery_price
	FROM #custom_order WHERE pay_type <> '4' AND delivery_price > 0
	--제본	
	UNION 
	SELECT order_seq, card_seq,  'JAEBON', 'JAEBON', 1, jebon_price
	FROM #custom_order WHERE pay_type <> '4' AND jebon_price > 0 
	--추가판비	
	UNION
	SELECT order_seq, card_seq,  'PANBI', 'PANBI', 1, option_price
	FROM #custom_order WHERE pay_type <> '4' AND option_price > 0
	--엠보	
	UNION 
	SELECT order_seq, card_seq,  'EMBO', 'EMBO', 1, embo_price
	FROM #custom_order WHERE pay_type <> '4' AND embo_price > 0
	--봉투삽입	
	UNION 
	SELECT order_seq, card_seq,  'ENVINSERT', 'ENVINSERT', 1, envInsert_price
	FROM #custom_order WHERE pay_type <> '4' AND envInsert_price > 0
	
	--초특급 배송(custom_order.isSpecial='1' 그리고, custom_order.delivery_price=30000)
	UNION 
	SELECT order_seq, card_seq,  'QICKDELIVERY', 'QICKDELIVERY', 1, ISNULL(etc_price, 0) AS delivery_price
	FROM #custom_order WHERE pay_type <> '4' and isSpecial = '1'
		
	--유니세프 기부금아이템 정보추가  --20110404 이상민
	UNION 
	SELECT order_seq, card_seq,  'DONATION', 'DONATION', 1, ISNULL(unicef_price,0) AS unicef_price
	FROM #custom_order WHERE status_Seq = 15  -- 배송완료
		AND order_seq>=1000000 AND unicef_price > 0
	
	--T맵	--20131017 이상민추가
	UNION
	SELECT order_seq, card_seq,  'TMAP', 'TMAP', 1, ISNULL(tmap_price, 0)
	FROM #custom_order WHERE ISNULL(tmap_price, 0) > 0
	
	ORDER BY order_seq, card_seq, Card_ErpCode, item_count
	
	
	
	--주문 수량이 50매일 경우 업무 효율을 위해 100단위로 출고(정광수 차장 요청)
	--다시 빠른손 수량으로 출고가 되도록 아래쿼리 주석처리--20131106  이상민
	--UPDATE #custom_order_item
	--SET item_count = round(Item_count/100, 0)*100
	--where Card_ErpCode IN ( 'FS19', 'FS20', 'FS25', 'FS26', 'FS27', 'FS28', 'FS15', 'FS16', 'FS17', 'FS18', 'YC01', 'YC02' )
	
	
	

		
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

--** 결제금액이 있는것은 모든 아이템에 대하여 정상출고로 출고시킨다. 추후 ERP가 아이템별 출고 유형을 달리 할 수 있도록 수정하면 여기도 수정해 줘야 함


INSERT INTO #erp_salesReport 
( h_biz, h_gubun, h_date, h_sysCode, h_usrCode, h_comcode, h_taxType, h_offerPrice, h_superTax, h_sumPrice
	, h_optionPrice, h_partCode, h_staffcode, h_sonik, h_cost, h_orderid, h_memo2

	, b_biz, b_goodGubun, b_seq, b_storeCode, b_date, b_goodCode, b_goodUnit, b_OrderNum, b_unitPrice, b_offerPrice
	, b_superTax, b_sumPrice, b_memo, reg_date, FeeAmnt, ItemGubun, PGCheck, PayAmnt, SampleCheck, XartCheck
	, SettleDate, PayDate, PayCheck, b_memo_temp, DeptGubun, inflow_route_settle
	, order_seq, order_g_seq, item_type )

SELECT 'BK10' AS h_biz, 'SO' AS h_gubun, Convert(char(8),a.src_send_date,112) AS h_date
	--, '270', '270'
		, CASE WHEN b.item_Type IN ( 'C', 'I', 'A', 'R', 'B', 'P', 'TBB', 'JAEBON', 'PANBI', 'EMBO', 'ENVINSERT', 'QICKDELIVERY', 'DONATION', 'D', 'G', 'TMAP'  ) THEN @SysCode1
				WHEN b.item_Type = 'E'  and b.Card_ErpCode <> 'BE029' THEN @SysCode1
				WHEN b.item_Type = 'E'  and b.Card_ErpCode = 'BE029' THEN @SysCode2
				WHEN b.item_Type IN ('F', 'S', 'M', 'L', 'V', 'H' ) and item_price <> 0  THEN @SysCode1
				WHEN b.item_Type IN ('F', 'S', 'M', 'L', 'V', 'H' ) and item_price = 0  THEN @SysCode2
				--WHEN b.item_Type IN ('L', 'V' )	THEN @SysCode2
				ELSE @SysCode1
			END AS h_sysCode
			
		, CASE WHEN b.item_Type IN ( 'C', 'I', 'A', 'R', 'B', 'P', 'TBB', 'JAEBON', 'PANBI', 'EMBO', 'ENVINSERT', 'QICKDELIVERY', 'DONATION', 'D', 'G' , 'TMAP' ) THEN @UsrCode1
				WHEN b.item_Type = 'E'  and b.Card_ErpCode <> 'BE029' THEN @UsrCode1
				WHEN b.item_Type = 'E'  and b.Card_ErpCode = 'BE029' THEN @UsrCode2
				WHEN b.item_Type IN ('F', 'S', 'M', 'L', 'V', 'H' ) and item_price <> 0  THEN @UsrCode1
				WHEN b.item_Type IN ('F', 'S', 'M', 'L', 'V', 'H' ) and item_price = 0  THEN @UsrCode2
				--WHEN b.item_Type IN ('L', 'V' )	THEN @UsrCode2
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
							Case When (b.item_type = 'F' and ISNULL(b.item_price, 0) > 0)
									or (a.up_order_seq is not null and a.settle_price > 0) 
									or  ( b.item_type in ('TBB','PANBI','JAEBON','EMBO','EnvInsert','QICKDELIVERY', 'DONATION', 'TMAP') and a.settle_price > 0) Then '1489998'
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
						When (b.item_type = 'F' and ISNULL(b.item_price, 0) > 0) 
								or (a.up_order_seq is not null and a.settle_price > 0) 
								or  ( b.item_type in ('TBB','PANBI','JAEBON','EMBO','EnvInsert','QICKDELIVERY', 'DONATION', 'TMAP') and a.settle_price > 0) Then Round(a.settle_price/1.1,0)
					Else 75000
				End 
			Else Round(a.settle_price/1.1, 0)
		End AS h_offerPrice
		
		, Case When c.company_seq in (232,1137, 1250,2235) Then   --디지털플라자, 워커힐, G마켓 (후불결제), 전자랜드
				Case When c.company_seq  IN ( 1250) Then ROUND((a.Reduce_price*-1)- (a.Reduce_price*-1)/1.1,0)  --지마켓
					When (b.item_type = 'F' and ISNULL(b.item_price, 0) > 0) 
							or (a.up_order_seq is not null and a.settle_price > 0) 
							or ( b.item_type in ('TBB','PANBI','JAEBON','EMBO','EnvInsert','QICKDELIVERY', 'DONATION', 'TMAP') and a.settle_price > 0) Then ROUND(a.settle_price - ROUND(a.settle_price/1.1, 0), 0)
					Else 7500
				End
			Else ROUND(a.settle_price - ROUND(a.settle_price/1.1, 0), 0)
		End AS h_superTax	
		
		, Case When c.company_seq in (232,1137,1250,2235) Then   --디지털플라자, 워커힐, G마켓 (후불결제), 전자랜드 
				Case When c.company_seq  IN ( 1250)  Then a.Reduce_price * -1  --지마켓
						When (b.item_type = 'F' and ISNULL(b.item_price, 0) > 0) 
							or (a.up_order_seq is not null and a.settle_price > 0) 
							or ( b.item_type in ('TBB','PANBI','JAEBON','EMBO','EnvInsert','QICKDELIVERY', 'DONATION', 'TMAP') and a.settle_price > 0) Then a.settle_price
					
					Else 82500
				End
			Else a.settle_price		
		  End AS h_sumPrice 
		  	
		, 0 AS h_optionPrice
		, CASE WHEN ISNULL(O.h_comcode, '') = '1489998' THEN ISNULL(C.ERP_PartCode, ISNULL(O.h_partCode, '')) ELSE O.h_partCode  END  --1489998	BA_제휴사 일때만 C.ERP_PartCode 이걸루 수정 20111120 이상민
		, ISNULL(O.h_staffcode, '') 
		--, CASE WHEN ISNULL(C.ERP_PartCode, '') = '366' THEN '080401' ELSE ISNULL(O.h_staffcode, '') END AS h_staffcode --366	웨딩(비직영) 일때 080401배민영으로 수정 20150318 
		--, CASE WHEN ISNULL(O.h_comcode, '') = '1489998' THEN ISNULL(C.ERP_StaffCode, ISNULL(O.h_staffcode, '')) ELSE O.h_staffcode  END AS h_staffcode  --1489998	BA_제휴사 일때만 C.ERP_StaffCode 이걸루 수정 20140725 이상민
		
		, '110' AS h_sonik

		, CASE WHEN ISNULL(C.ERP_PartCode, '') = '366' THEN '149' ELSE ISNULL(O.h_cost, '')  END AS h_cost --366	웨딩(비직영) 일때 149 웨딩제휴 로 수정 20150318 
		--, CASE WHEN ISNULL(O.h_comcode, '') = '1489998' THEN ISNULL(C.ERP_CostCode, ISNULL(O.h_cost, '')) ELSE O.h_cost  END AS h_cost  --1489998	BA_제휴사 일때만 C.ERP_CostCode 이걸루 수정 20140725 이상민

		--, Case  When c.company_seq in (232,1137,1250,2235) Then --디지털플라자, 워커힐, G마켓 (후불결제), 전자랜드
		--			Case When (b.item_Type ='F'  and ISNULL(b.item_price, 0) > 0 )         --후불결제 업체라도 식권, 엠보인쇄 등 옵션이나 추가주문건은 PG를 타서 결제함 (주문번호 앞에 'IC' 붙힘)
		--					or (a.up_order_seq is not null and a.settle_price > 0) 
		--					or ( b.item_type in ('TBB','PANBI','JAEBON','EMBO','EnvInsert','QICKDELIVERY', 'DONATION') and a.settle_price > 0) Then 'IC'+ Cast(a.order_seq as nvarchar(50))
		--				Else 'D'+Cast(a.order_seq as nvarchar(50))  --후불건에 대해서는 주문번호 앞에 'D' 붙힘
		--			End
		--		Else 'IC'+Cast(a.order_seq as nvarchar(50))
		--	End AS 	h_orderid
		
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
		, CONVERT(CHAR(8),a.src_send_date,112) AS b_date
		, b.Card_ErpCode		AS b_goodCode	
		, 'EA'					AS b_goodUnit
		, Case When b.Card_ErpCode = 'BSI010' Then (b.item_count/50)*6 
				Else b.item_count 
			End					AS b_OrderNum

		, Case When b.item_Type in ('TBB','JAEBON','PANBI','EMBO','ENVINSERT','QICKDELIVERY', 'DONATION', 'TMAP')  Then ISNULL(b.item_price, 0)				
				Else ISNULL(e.c_sobi, 0)
			End		AS b_unitPrice

		, Case When b.item_Type  in ('TBB','JAEBON','PANBI','EMBO','ENVINSERT','QICKDELIVERY', 'DONATION', 'TMAP')  Then ROUND(ISNULL(b.item_price, 0)/1.1, 0)	
				When b.item_Type IN ('F', 'L') and ISNULL(b.item_price, 0) > 0			Then ROUND(ISNULL(b.item_price, 0)/1.1, 0)
				When b.item_Type in ('S','M')  and ISNULL(b.item_price, 0) > 0		Then 	Round((ISNULL(b.item_price, 0)*b.item_count)/1.1 , 0)
				When b.item_Type IN ('F', 'S', 'M', 'L', 'V', 'H' ) and ISNULL(b.item_price, 0) <= 0			 Then	0  --이상민추가 20100220
				When b.item_Type  = 'E'	and b.Card_ErpCode = 'BE029'							 Then	0  --미니청첩장 봉투는 무료로 넘김				
		    Else Round((IsNull(e.c_sobi, 0)*b.item_count)/1.1, 0)
			End AS b_offerPrice

	    , Case When b.item_Type in ('TBB','JAEBON','PANBI','EMBO','ENVINSERT','QICKDELIVERY', 'DONATION', 'TMAP')  Then ISNULL(b.item_price, 0) - Round(ISNULL(b.item_price, 0)/1.1, 0)	
				When b.item_Type IN ('F', 'L') and ISNULL(b.item_price, 0) > 0		Then ISNULL(b.item_price, 0) - Round(ISNULL(b.item_price, 0)/1.1, 0)
				When b.item_Type IN ('S', 'M') and ISNULL(b.item_price, 0) > 0		Then ISNULL(b.item_price, 0)*b.item_count - Round((ISNULL(b.item_price, 0)*b.item_count)/1.1 , 0)
				When b.item_Type IN ('F', 'S', 'M', 'L', 'V', 'H' ) and ISNULL(b.item_price, 0) <= 0	 Then	0  --이상민추가 20100220
				When b.item_Type = 'E' and b.Card_ErpCode = 'BE029'			Then	0
			  Else ( ISNULL(e.c_sobi, 0)*b.item_count) - Round(( ISNULL(e.c_sobi, 0)*b.item_count)/1.1,0)
			End AS b_superTax
			
		, Case When b.item_Type in ('TBB','JAEBON','PANBI','EMBO','ENVINSERT','QICKDELIVERY', 'DONATION', 'TMAP')  Then ISNULL(b.item_price, 0)	
				When b.item_Type IN ('F', 'L') and ISNULL(b.item_price, 0) > 0		Then ISNULL(b.item_price, 0)
				When b.item_Type IN ('S', 'M') and ISNULL(b.item_price, 0) > 0		Then ISNULL(b.item_price, 0)*b.item_count
				When b.item_Type IN ('F', 'S', 'M', 'L', 'V', 'H' ) and ISNULL(b.item_price, 0) <= 0			 Then	0  --이상민추가 20100220
				When b.item_Type  = 'E' and b.Card_ErpCode = 'BE029'		Then	0
			Else  IsNull(e.c_sobi, 0)*b.item_count
		   End AS b_sumPrice
		------------------------------------------------------------------------------------------------------------------
		
		, null AS b_memo
		, getdate() AS reg_date

		--**************************************************************************************************************
		--   * PG수수료 (PG로 넘어가는 것은 수수료를 셋팅해 준다.)
		--   pgFee getPGFee 함수 호출 (pg아이디, 결제수단, 결제금액, 카드사정보)
		--**************************************************************************************************************
		, dbo.getPGFee_New (a.pg_shopid, a.settle_method, a.settle_price) AS FeeAmnt	 --2009년 3월 16일 결제부터 새로운 PG수수료율 적용		
		, 'ITEM' AS ItemGubun
		, Case When a.sales_gubun = 'B' Then 
					Case When  c.company_seq in (232,1137,1243,1250,2235) Then   --디지털플라자, 워커힐, G마켓 (후불결제), 전자랜드 
								Case When (b.item_type = 'F' and ISNULL(b.item_price, 0) > 0) 
										or (a.up_order_seq is not null and a.settle_price > 0) 
										or  ( b.item_type in ('TBB','PANBI','JAEBON','EMBO','EnvInsert','QICKDELIVERY', 'DONATION', 'TMAP') and a.settle_price > 0) Then 'Y'  -- 일반과세
										Else 'N'
									End	
							Else 'Y'
						End		
				ELSE O.PGCheck
			End AS PGCheck

		, 0 AS PayAmnt
		, 'N' AS SampleCheck
		, 'N' AS XartCheck	
		, null AS SettleDate
		, null AS PayDate
		, null AS PayCheck	
		, null AS b_memo_temp			
		, O.DeptGubun
		, a.inflow_route_settle
		, a.order_seq
		, a.order_g_seq
		, b.item_Type
FROM #custom_order a 
JOIN  #custom_order_item b ON a.order_seq = b.order_seq AND b.Card_ErpCode <> '코리아나'
JOIN company c ON a.company_seq = c.company_seq
JOIN #CardMaster d ON b.card_seq = d.card_seq
LEFT JOIN #sales_gubunTemp O ON a.sales_gubun = O.sales_gubun 
LEFT JOIN [erpdb.bhandscard.com].XERP.DBO.itemSiteMaster E ON E.SiteCode = 'BK10' AND d.Card_ErpCode = E.ItemCode

WHERE a.status_Seq = 15 
	and convert(char(8),src_send_date,112) between  @SDate AND @EDate
	and a.pay_type <> '4' 
	and A.sales_gubun in ( 'W','T','J','B','S','G','SA', 'ST', 'SB', 'SW', 'SS', 'SP', 'SH', 'H', 'C', 'SG', 'P' ) --비핸즈, 더카드
ORDER BY a.order_seq 




--**************************************************************************************************************
--2.샘플
--**************************************************************************************************************
	
--custom_sample_order 테이블에서 대상데이터를 임시테이블에 넣음. 20090805-이상민
SELECT *
INTO #custom_sample_order
FROM custom_sample_order a 
WHERE Convert(char(8),a.delivery_Date,112) BETWEEN @SDate AND @EDate

--select top 100 * from custom_sample_order
--order by sample_order_seq desc

-- 샘플 매출은 자사카드는 출고가 기준 10% 할인율 적용해서 올림
--      "  "         타사카드는 매입가 기준으로 올림
-- 배송비는 안올림
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
		and Convert(char(8),a.delivery_Date,112) between @SDate and @EDate
		and A.sales_gubun in ( 'W','T','J','B','S','G','SA', 'ST', 'SB', 'SW', 'SS', 'SP', 'SH', 'H', 'C', 'SG', 'P' ) --비핸즈, 더카드
		--and A.sales_gubun in ( 'SA', 'ST', 'SB', 'SW', 'SS', 'SH', 'SP' ) --비핸즈, 더카드
		--and a.sales_gubun in ('W','T','U','J','B','S','X','G', 'SB', 'SW', 'SS', 'SH', 'SP')
		and ISNULL(a.pg_mertid, '') <> 'tiaracard1' 
		and ISNULL(a.sales_gubun, '') <> 'A' 
	ORDER BY a.sample_order_seq 



--select * from #erp_salesReport where order_seq =2458873

--**************************************************************************************************************
 --3. 미니청첩장 및 식권 등 옵션 상품 따로 주문시 
--**************************************************************************************************************

--select * from custom_etc_order where order_seq = 3154829
--select * from custom_etc_order where order_type = 'H'

--custom_etc_order 테이블에서 대상데이터를 임시테이블에 넣음. 20090805-이상민
SELECT *
INTO #custom_etc_order
FROM custom_etc_order a 
WHERE Convert(char(8), a.delivery_Date,112) BETWEEN @SDate AND @EDate

	
	INSERT INTO #erp_salesReport 
	( 	h_biz, h_gubun, h_date, h_sysCode, h_usrCode, h_comcode, h_taxType, h_offerPrice, h_superTax, h_sumPrice
		, h_partCode, h_staffcode, h_sonik, h_cost, h_orderid, h_memo2
		, b_biz, b_goodGubun, b_seq, b_storeCode, b_date, b_goodCode, b_goodUnit, b_OrderNum, b_unitPrice, b_offerPrice, b_superTax, b_sumPrice
		, b_memo, reg_date, FeeAmnt, ItemGubun, PGCheck, PayAmnt, SampleCheck, XartCheck, SettleDate, PayDate, PayCheck, b_memo_temp, DeptGubun 
		, order_seq, order_g_seq
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
		
		CASE WHEN ISNULL(O.h_comcode, '') = '1489998' THEN ISNULL(C.ERP_PartCode, ISNULL(O.h_partCode, '')) ELSE O.h_partCode  END,  --1489998	BA_제휴사 일때만 C.ERP_PartCode 이걸루
		--ISNULL(C.ERP_PartCode, ISNULL(O.h_partCode, '')),		--O.h_partCode, 	
		O.h_staffcode, 
		h_sonik		= '110',
		O.h_cost, 						
		h_orderid	= Case When a.pg_shopid = '2ucard0001'	Then Cast(a.order_seq as nvarchar(20))  Else a.pg_tid  End,	
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
		a.order_g_seq
		
	FROM #custom_etc_order a 
	JOIN (
			SELECT order_seq, card_seq, Card_ErpCode, order_count, item_price 
			FROM (
					--기본 주문정보
					SELECT a.order_seq, b.card_seq, c.Card_ErpCode, b.order_count, b.card_sale_price as item_price 
					FROM #custom_etc_order a 
					JOIN custom_etc_order_item b ON a.order_seq = b.order_seq
					JOIN #CardMaster c ON b.card_seq = c.card_seq
					WHERE  Convert(char(8),delivery_date,112) between @SDate AND @EDate
						and a.status_seq >= 12 
						and a.order_type in ('F','P', 'C', 'G', 'S', 'D','K', 'B', 'R', 'Q', 'J', 'H', 'N', 'E','T','O','B','M', 'X', 'U')--송월타월'T',손보자기'O',비스트디자인'B',셀레모기획전'M' 비핸즈 답례품 추가20171013 유우종  --속지봉투:E 추가 20161102 이상민
						and ISNULL(a.sales_gubun, '') <> 'D' 
						and b.order_count >0
			) z
				
			UNION ALL
			--택배비
			SELECT order_seq,123,  'TBB' as Card_ErpCode ,1 as order_count ,delivery_price as item_price
			FROM #custom_etc_order  
			WHERE Convert(char(8),delivery_date,112) between @SDate AND @EDate
				and delivery_price > 0
				and status_seq >= 12 
				and order_type in ('F','P', 'C', 'G', 'S', 'D','K', 'B', 'R', 'Q', 'J', 'H', 'N', 'E','T','O','B','M', 'X', 'U')--송월타월'T',손보자기'O',비스트디자인'B',셀레모기획전'M' 비핸즈 답례품 추가20171013 유우종
				and ISNULL(sales_gubun, '') <> 'D'  
				and ISNULL(sales_gubun, '') <> 'O' 
		
		) b ON a.order_seq = b.order_seq
		JOIN company c ON a.company_seq = c.company_seq
		--JOIN #CardMaster d ON b.card_seq = d.card_seq
		LEFT JOIN #sales_gubunTemp O ON a.sales_gubun = O.sales_gubun
		LEFT JOIN [erpdb.bhandscard.com].XERP.DBO.itemSiteMaster E ON E.SiteCode = 'BK10' AND b.Card_ErpCode = E.ItemCode

	WHERE Convert(char(8),a.delivery_date,112) between @SDate AND @EDate
		and a.status_seq >= 12 
		and a.order_type in ('F','P', 'C', 'G', 'S', 'D','K', 'B', 'R', 'Q', 'J', 'H', 'N', 'E','T','O','B','M', 'X', 'U')--송월타월'T',손보자기'O',비스트디자인'B',셀레모기획전'M' 비핸즈 답례품 추가20171013 유우종
		and ISNULL(a.sales_gubun, '') NOT IN ( 'D' , 'X')	--20111219 이상민 'X' 추가  시즌카드 연동화면 이용함.
		and A.sales_gubun in ( 'W','T','J','B','S','G','SA', 'ST', 'SB', 'SW', 'SS', 'SP', 'SH', 'H', 'C', 'SG', 'P' ) --비핸즈, 더카드
		and ISNULL(a.pg_shopid, '') <> 'tiaracard1' 
		--and a.src_erp_date is null  
	ORDER BY a.order_seq 


--select * from CUSTOM_ETC_ORDER where order_seq = '3154961'
--select * from CUSTOM_ETC_ORDER where order_type = 'J' and status_seq = 12

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
		h_comcode	= CASE	WHEN a.pg_shopid IN ( 'bhands_b' ) THEN '2011022'	--비핸즈사이트
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

							WHEN a.sales_gubun IN ( 'C', 'H') Then 
								CASE WHEN a.COMPANY_SEQ = 5780 THEN '2012664'  --이지웰 
									WHEN a.COMPANY_SEQ = 5787 THEN '2012692'  --SK베네피아 
								ELSE O.h_comcode END
						ELSE O.h_comcode END,
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
		and A.sales_gubun in ( 'W','T','J','B','S','G','SA', 'ST', 'SB', 'SW', 'SS', 'SP', 'SH', 'H', 'C', 'SG', 'P' ) --비핸즈, 더카드


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
		h_comcode	= CASE WHEN a.sales_gubun IN ( 'C', 'H') Then 
								CASE WHEN a.COMPANY_SEQ = 5780 THEN '2012664'  --이지웰 
									WHEN a.COMPANY_SEQ = 5787 THEN '2012692'  --SK베네피아 
								ELSE O.h_comcode END
						ELSE O.h_comcode END,
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
		and a.Company_seq in ('5001', '5002', '5003', '5004', '5005', '5006','5007') 
		


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
							When b.b_goodCode in ('TBB','JAEBON','PANBI','EMBO','ENVINSERT','QICKDELIVERY', 'DONATION', 'TMAP') OR item_type IN ( 'F', 'L' ) Then b.b_sumPrice
							Else Round( ((b.b_sumPrice * (100-a.DiscountRate)/100)/1.1) 
								+ (b.b_sumPrice * (100-a.DiscountRate)/100) - ((b.b_sumPrice * (100-a.DiscountRate)/100)/1.1), 0)
						End,
 		b_offerPrice    = Case 
							When b.b_goodCode in ('TBB','JAEBON','PANBI','EMBO','ENVINSERT','QICKDELIVERY', 'DONATION', 'TMAP') OR item_type IN ( 'F', 'L' ) Then Round(b.b_sumPrice/1.1, 0)
							--Else Round( (b.b_sumPrice * (100-a.DiscountRate)/100)/1.1, 0)
							ELSE  Round( ( ((b.b_sumPrice * (100-a.DiscountRate)/100)/1.1) 
								+ (b.b_sumPrice * (100-a.DiscountRate)/100) - ((b.b_sumPrice * (100-a.DiscountRate)/100)/1.1) ) / 1.1, 0)
						
						End,
 		b_superTax    = Case 
							When b.b_goodCode in ('TBB','JAEBON','PANBI','EMBO','ENVINSERT','QICKDELIVERY', 'DONATION', 'TMAP') OR item_type IN ( 'F', 'L' ) Then Round(b.b_sumPrice - b.b_sumPrice/1.1,0)
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
							WHERE b_goodCode  in ('TBB','JAEBON','PANBI','EMBO','ENVINSERT','QICKDELIVERY', 'DONATION', 'TMAP') 
								OR item_type IN ( 'F', 'L' )
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




		  
	--BSI029 Wpaper용 (핑크 2종)  ERP는 Sht 단위이므로 수량조정.. 1Sht = 50EA
	--UPDATE #custom_order_item
	--SET item_count = item_count/50
	--WHERE Card_ErpCode IN ( 'BSI029', 'YM15')


	----BH5193A ERP연동시 수량조정.. 1SET = 5EA (정광수차장 요청) 20151014
	--UPDATE #custom_order_item
	--SET item_count = item_count/5
	--WHERE Card_ErpCode IN ( 'BH5193A')

	
	--select * from s2_card where card_erpcode = 'BH6704'
	--select * from S2_CardDetail where card_seq in ( select card_seq from s2_card where card_erpcode = 'BH6704' ) 
	--select * from S2_CardKind where card_seq in ( select card_seq from s2_card where card_erpcode = 'BH6704' ) 



	----디지털카드 샘플출고에서 제외할것 정광수, 김진영 요청 20160909  
	----다시 디지털카드 샘플출고 처리할것 ( 김진영, 강구완 요청 20170510 )
	--DELETE FROM  #erp_salesReport
	--WHERE b_storeCode	= 'MF15'	--MF15:샘플전자상거래(제품)
	--	AND b_goodCode IN ( 
	--			SELECT Card_ERPCode
	--			FROM s2_card A
	--			WHERE Card_Seq IN ( SELECT card_seq from S2_CardKind WHERE CardKind_Seq = 14 )
	--			UNION ALL
	--			SELECT 'BH7727_I' AS Card_ERPCode	--BH7727과 같이 샘플출고에서 임시로 제외 --20170406 이평렬
	--		)



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


--**************************************************************************************************************
--헤더 금액 update (아이템 금액의 합계로 Update)
--**************************************************************************************************************
--UPDATE #erp_salesReport 
--SET h_offerprice = b.b_offerPrice, h_superTax = b.b_superTax
--FROM #erp_salesReport  a 
--JOIN (SELECT h_orderid, sum(b_offerprice) as b_offerPrice,sum(b_superTax) as b_superTax,sum(b_sumprice) as b_sumPrice FROM #erp_salesReport GROUP BY h_orderid) b
--ON a.h_orderid = b.h_orderid	
--WHERE a.SampleCheck = 'N'



--**************************************************************************************************************
--금액차이나는것 확인 쿼리
--**************************************************************************************************************
-- SELECT a.h_orderid,a.b_goodCode,a.h_offerPrice,a.h_superTax, a.h_sumPrice, a.h_optionPrice, a.b_offerPrice, a.b_superTax, a.b_sumPrice,  a.DiscountRate,
-- 	diff =  CASE
-- 		When	a.h_sumPrice = b.b_sumPrice Then 0
-- 		Else a.h_sumPrice - b.b_sumPrice	
-- 	         END	  
-- FROM #erp_salesReport  a 
-- JOIN 	(	SELECT h_orderid,sum(b_sumPrice) as b_sumPrice FROM #erp_salesReport
-- 		GROUP BY h_orderid
-- 	) b ON a.h_orderid = b.h_orderid



	--20100324
	SELECT  IDENTITY(int, 1, 1) AS ItemSerNo, *
	INTO #ERP_SalesDataTemp
	FROM #erp_salesReport
	ORDER BY h_Orderid ASC, b_sumPrice DESC, b_goodCode 
	

	--select * from #ERP_SalesDataTemp where h_Orderid like '%2458873%'

--**************************************************************************************************************
--Erp_salesData에 Insert
--**************************************************************************************************************

	INSERT INTO  [erpdb.bhandscard.com].XERP.DBO.erp_salesData 
	( h_biz, h_gubun, h_date, h_sysCode, h_usrCode, h_comcode, h_taxType, h_offerPrice, h_superTax, h_sumPrice
		, h_partCode, h_staffcode, h_sonik, h_cost, h_orderid, h_memo2
		, b_biz, b_goodGubun, b_seq, b_storeCode, b_date, b_goodCode, b_goodUnit, b_OrderNum, b_unitPrice, b_offerPrice, b_superTax, b_sumPrice
		, b_memo, reg_date, FeeAmnt, ItemGubun, PGCheck, PayAmnt, SampleCheck, XartCheck, SettleDate, PayDate, PayCheck, b_memo_temp, DeptGubun 
		, order_seq, order_g_seq, C_ShopGroupNo, inflow_route_settle
	)
	
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


----통합주문번호 UPdate
--UPDATE [erpdb.bhandscard.com].XERP.DBO.erp_salesData
--SET C_ShopGroupNo = G.pg_tid
--FROM [erpdb.bhandscard.com].XERP.DBO.erp_salesData A
--JOIN Custom_order_Group G ON A.order_g_seq = G.order_g_seq
--WHERE A.h_date = @SDate
--	AND A.b_memo IS NULL
--	AND A.order_g_seq IS NOT NULL
	 

	 
----통합주문번호 UPdate
--UPDATE [erpdb.bhandscard.com].XERP.DBO.erp_salesData
--SET C_ShopGroupNo = G.pg_tid
--FROM [erpdb.bhandscard.com].XERP.DBO.erp_salesData A
--JOIN #ERP_SalesDataTemp B ON A.order_seq = B.order_seq
--JOIN Custom_order_Group G ON B.order_g_seq = G.order_g_seq
--WHERE A.h_date = @SDate


/*
	
	--e청첩장		
	UPDATE the_ewed_order 
	SET src_erp_date = Convert(char(10),getdate(),120)
	WHERE 
		AC_STATE='P' and settle_Status=2 and status_Seq=2 and order_result in ('3','4') 
		and Convert(char(8), settle_date, 112) BETWEEN @SDate and @EDate
		and src_erp_date is null 
		and sales_gubun in ('W','T','U','J','B','S','X','G', 'SB', 'SW', 'SS', 'SH', 'SP')
		
*/
GO
