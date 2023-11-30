USE [bar_shop1]
GO
-- 디얼디어 청첩장 주문 미등록건 복구 (주문번호로)
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_ERP_TRANSFER_SHOP_BD_ORDER_SEQ]
	@OrderSeq As Int

AS
SET NOCOUNT ON

-- EXEC SP_ERP_TRANSFER_SHOP_BD_ORDER_SEQ 4307474


--정상출고 (270,270)
DECLARE @Syscode1 as char(3),@UsrCode1 as char(3) 
Set @SysCode1 = '270'
Set @UsrCode1 = '270'

--예외출고(판매촉진비)  (300, 322)
DECLARE @Syscode2 as char(3),@UsrCode2 as char(3) 
Set @SysCode2 = '300'
Set @UsrCode2 = '322'


--예외출고(샘플-판매촉진비)(300,308) 
DECLARE @Syscode3 as char(3),@UsrCode3 as char(3) 
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
			order_g_seq     int  NULL
			
		 )    
     

----**************************************************************************************************************
----1.청첩장
----**************************************************************************************************************

--custom_order 테이블에서 대상데이터를 임시테이블에 넣음. 20090805-이상민
SELECT * 
INTO #custom_order
FROM custom_order A
WHERE A.status_Seq = 15  -- 배송완료
	And A.Order_Seq = @OrderSeq
	and A.sales_gubun in ( 'SD' ) --디얼디어

		
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
	h_cost	nvarchar(8)			NOT NULL,
	PGCheck	nvarchar(1)		NOT NULL,  
	DeptGubun	nvarchar(2)		NOT NULL,  
	Company_seq	nvarchar(4)		NOT NULL,  
) 
			
--기준정보 셋팅
INSERT INTO #sales_gubunTemp 

--전자상거래
SELECT 'SD' AS sales_gubun, '2018052' AS h_comcode, '210' AS h_partCode, '150602' AS h_staffcode, 'C210' AS h_cost, 'Y' AS PGCheck, 'SD' AS DeptGubun , '7717' AS Company_seq 

--150602  	임헌재


	
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
		and A.Order_Seq = @OrderSeq
		and A.sales_gubun in ( 'SD' ) --디얼디어
	ORDER BY a.order_seq, b.card_seq
	
	

	--기본 아이템 정보 (무료식권, 무료 미니청첩장)
	SELECT order_seq,card_seq, Card_ErpCode,item_type, item_count, item_price
	INTO #custom_order_item
	FROM #custom_order_item_Temp
	WHERE item_count > 0 
			AND item_type not in ('F','M') --C:카드,E:봉투,I:내지,S:스티커,M:미니청첩장,F:식권,A:부속품 ,B:라벨지,R: 리본
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
	-- 식권
	--##################################################################################################################
	UNION
	--1.무료식권 주문시 (fticket_price가 0원일 경우)
	SELECT order_seq, card_seq, Card_ErpCode, item_type, item_count, item_price
	FROM #custom_order_item_Temp
	WHERE item_type = 'F' and fticket_price = 0
		and item_count > 0
		
	UNION 
	--2. 유료식권 주문시 (fticket_price가 있을 경우)
	--2.1 무료식권 추가일 경우 (청첩장 주문 수량을 초과하는 금액에 대하여 30원 과금)
	--2.1.1 무료수량
	SELECT  a.order_seq, a.card_seq, a.Card_ErpCode, a.item_type
		, Round(a.item_count * a1.disRate, 0) as item_count
		, 0 as item_price
	FROM #custom_order_item_Temp a
	JOIN (
			  SELECT a.order_seq, a.order_count, sum(b.item_count) as sum_count
					,((order_count*100)/sum(item_count))/100.0 as disRate
			  FROM #custom_order a 
			  JOIN custom_order_item b ON a.order_seq = b.order_seq
			  WHERE b.item_type ='F' and b.item_count > 0	
			  GROUP BY a.order_seq, a.order_count			
			  
		 ) a1 ON a.order_seq = a1.order_seq
	WHERE a.item_type = 'F' and a.fticket_price > 0 and a.item_count > 0		
		and a.Card_ErpCode in ('FSB01','FSB02','FSU01','FSU02','FST01','FST02','YC01','YC02') --무료식권

	
	UNION
	--2.1.2 유료수량
	SELECT  a.order_seq, a.card_seq, a.Card_ErpCode, a.item_type
		, a.item_count- Round(a.item_count * a1.disRate,0) as item_count
		, Round((a.fticket_price/(a1.sum_count*1.00))*item_count,0)  as item_price
	FROM #custom_order_item_Temp a
	JOIN (
			  SELECT a.order_seq, a.order_count, sum(b.item_count) as sum_count
					,((order_count*100)/sum(item_count))/100.0 as disRate
			  FROM #custom_order a 
			  JOIN custom_order_item b ON a.order_seq = b.order_seq
			  WHERE b.item_type ='F' and b.item_count > 0	
			  GROUP BY a.order_seq, a.order_count			 	
	
		 ) a1 ON a.order_seq = a1.order_seq
	WHERE a.item_type = 'F' and a.fticket_price > 0 and a.item_count > 0		
		and a.Card_ErpCode in ('FSB01','FSB02','FSU01','FSU02','FST01','FST02','YC01','YC02') --무료식권
		
	UNION
	--2.2 유료식권일 경우 (청첩장 주문 수량만큼 20원, 초과하는 금액에 대하여 50원 과금)
	SELECT  a.order_seq, a.card_seq, a.Card_ErpCode, a.item_type
		, a.item_count as item_count 
		, Round((a.fticket_price/(a1.sum_count*1.00))*item_count,0)  as item_price
	FROM #custom_order_item_Temp a
	JOIN (
			  SELECT a.order_seq, a.order_count, sum(b.item_count) as sum_count
					,((order_count*100)/sum(item_count))/100.0 as disRate
			  FROM #custom_order a 
			  JOIN custom_order_item b ON a.order_seq = b.order_seq
			  WHERE b.item_type ='F' and b.item_count > 0	
			  GROUP BY a.order_seq, a.order_count			 	
		 ) a1 ON a.order_seq = a1.order_seq
	WHERE a.item_type = 'F' and a.fticket_price > 0 and a.item_count > 0	
		--and a.Card_ErpCode in ('FS03','FS04','FS07','FS08','FSU03','FSU04') --유료식권

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
	SELECT order_seq, card_seq,  'QICKDELIVERY', 'QICKDELIVERY', 1, 35000 AS delivery_price
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
	, order_seq, order_g_seq )

SELECT 'BHC2' AS h_biz, 'SO' AS h_gubun, Convert(char(8),a.src_send_date,112) AS h_date
	--, '270', '270'
		, CASE WHEN b.item_Type IN ( 'C', 'I', 'A', 'R', 'B', 'P', 'TBB', 'JAEBON', 'PANBI', 'EMBO', 'ENVINSERT', 'QICKDELIVERY', 'DONATION', 'D', 'G', 'TMAP'  ) THEN @SysCode1
				WHEN b.item_Type = 'E'  and b.Card_ErpCode <> 'BE029' THEN @SysCode1
				WHEN b.item_Type = 'E'  and b.Card_ErpCode = 'BE029' THEN @SysCode2
				WHEN b.item_Type IN ('F', 'S', 'M', 'L', 'V', 'H', 'X', 'W' ) and item_price <> 0  THEN @SysCode1
				WHEN b.item_Type IN ('F', 'S', 'M', 'L', 'V', 'H', 'X', 'W' ) and item_price = 0  THEN @SysCode2
				--WHEN b.item_Type IN ('L', 'V' )	THEN @SysCode2
				ELSE @SysCode1
			END AS h_sysCode
			
		, CASE WHEN b.item_Type IN ( 'C', 'I', 'A', 'R', 'B', 'P', 'TBB', 'JAEBON', 'PANBI', 'EMBO', 'ENVINSERT', 'QICKDELIVERY', 'DONATION', 'D', 'G' , 'TMAP' ) THEN @UsrCode1
				WHEN b.item_Type = 'E'  and b.Card_ErpCode <> 'BE029' THEN @UsrCode1
				WHEN b.item_Type = 'E'  and b.Card_ErpCode = 'BE029' THEN @UsrCode2
				WHEN b.item_Type IN ('F', 'S', 'M', 'L', 'V', 'H', 'X', 'W' ) and item_price <> 0  THEN @UsrCode1
				WHEN b.item_Type IN ('F', 'S', 'M', 'L', 'V', 'H', 'X', 'W' ) and item_price = 0  THEN @UsrCode2
				--WHEN b.item_Type IN ('L', 'V' )	THEN @UsrCode2
				ELSE @UsrCode1
			END AS h_usrCode


		,  O.h_comcode 		
			
		, '22' AS h_taxType

		--**************************************************************************************************************
		--* 헤더 결제금액
		--**************************************************************************************************************
		, Case When c.company_seq in (232, 1137, 1250, 2235) Then --디지털플라자, 워커힐, G마켓 (후불결제), 전자랜드
					Case When c.company_seq IN ( 1250) Then Round((a.Reduce_price * -1 ) / 1.1, 0)  --지마켓
						When (b.item_type = 'F' and b.item_price > 0) 
								or (a.up_order_seq is not null and a.settle_price > 0) 
								or  ( b.item_type in ('TBB','PANBI','JAEBON','EMBO','EnvInsert','QICKDELIVERY', 'DONATION', 'TMAP') and a.settle_price > 0) Then Round(a.settle_price/1.1,0)
					Else 75000
				End 
			Else Round(a.settle_price/1.1, 0)
		End AS h_offerPrice
		
		, Case When c.company_seq in (232,1137, 1250,2235) Then   --디지털플라자, 워커힐, G마켓 (후불결제), 전자랜드
				Case When c.company_seq  IN ( 1250) Then ROUND((a.Reduce_price*-1)- (a.Reduce_price*-1)/1.1,0)  --지마켓
					When (b.item_type = 'F' and b.item_price > 0) 
							or (a.up_order_seq is not null and a.settle_price > 0) 
							or ( b.item_type in ('TBB','PANBI','JAEBON','EMBO','EnvInsert','QICKDELIVERY', 'DONATION', 'TMAP') and a.settle_price > 0) Then ROUND(a.settle_price - ROUND(a.settle_price/1.1, 0), 0)
					Else 7500
				End
			Else ROUND(a.settle_price - ROUND(a.settle_price/1.1, 0), 0)
		End AS h_superTax	
		
		, Case When c.company_seq in (232,1137,1250,2235) Then   --디지털플라자, 워커힐, G마켓 (후불결제), 전자랜드 
				Case When c.company_seq  IN ( 1250)  Then a.Reduce_price * -1  --지마켓
						When (b.item_type = 'F' and b.item_price > 0) 
							or (a.up_order_seq is not null and a.settle_price > 0) 
							or ( b.item_type in ('TBB','PANBI','JAEBON','EMBO','EnvInsert','QICKDELIVERY', 'DONATION', 'TMAP') and a.settle_price > 0) Then a.settle_price
					
					Else 82500
				End
			Else a.settle_price		
		  End AS h_sumPrice 
		  	
		, 0 AS h_optionPrice
		, CASE WHEN ISNULL(O.h_comcode, '') = '1489998' THEN ISNULL(C.ERP_PartCode, ISNULL(O.h_partCode, '')) ELSE O.h_partCode  END  --1489998	BA_제휴사 일때만 C.ERP_PartCode 이걸루 수정 20111120 이상민
		, ISNULL(O.h_staffcode, '') 
		, 'PC01' AS h_sonik

		, CASE WHEN ISNULL(C.ERP_PartCode, '') = '366' THEN '149' ELSE ISNULL(O.h_cost, '')  END AS h_cost --366	웨딩(비직영) 일때 149 웨딩제휴 로 수정 20150318 

		
		, CASE WHEN ISNULL(a.pg_tid, '') like 'bhand%' THEN 'IC'+Cast(a.order_seq as nvarchar(50)) ELSE CASE WHEN ISNULL(LTRIM(RTRIM(a.pg_tid)), '') = '' THEN  'IC'+Cast(a.order_seq as nvarchar(50)) ELSE  ISNULL(a.pg_tid, 'IC'+Cast(a.order_seq as nvarchar(50))


 ) END END AS h_orderid
		--, ISNULL(a.pg_tid, 'IC'+Cast(a.order_seq as nvarchar(50)) )  AS 	h_orderid
		, Case When a.sales_gubun = 'U' Then 'Inisis' 
				Else ISNULL(a.pg_tid, 'IC'+Cast(a.order_seq as nvarchar(50)) ) End AS h_memo2
	

		, 'BHC2'				AS b_biz
		, 'SO'					AS b_goodGubun
		, 1						AS b_seq
		, 'DF03'				AS b_storeCode
		, CONVERT(CHAR(8),a.src_send_date,112) AS b_date
		, b.Card_ErpCode		AS b_goodCode	
		, 'EA'					AS b_goodUnit
		, Case When b.Card_ErpCode = 'BSI010' Then (b.item_count/50)*6 
				Else b.item_count 
			End					AS b_OrderNum

		, Case When b.item_Type in ('TBB','JAEBON','PANBI','EMBO','ENVINSERT','QICKDELIVERY', 'DONATION', 'TMAP')  Then b.item_Price				
				Else IsNull(e.c_sobi, 0)
			End					AS b_unitPrice

		, Case When b.item_Type  in ('TBB','JAEBON','PANBI','EMBO','ENVINSERT','QICKDELIVERY', 'DONATION', 'TMAP')  Then ROUND(b.item_Price/1.1, 0)	
				When b.item_Type = 'F' and b.item_Price <> 0									 Then ROUND(b.item_price/1.1, 0)
				When b.item_Type = 'F' and b.item_Price = 0										 Then	0
				When b.item_Type IN ('L', 'V') and b.item_Price = 0								 Then	0  --이상민추가 20100220
				When b.item_Type  = 'E'	and b.Card_ErpCode = 'BE029'							 Then	0  --미니청첩장 봉투는 무료로 넘김
				When b.item_Type  in ('S','M', 'X', 'W')  and b.item_price > 0							 Then 	Round((b.item_price*b.item_count)/1.1 , 0)
				When b.item_Type  in ('S','M', 'X', 'W')  and b.item_price <= 0							 Then 	0
				Else Round((IsNull(e.c_sobi, 0)*b.item_count)/1.1, 0)
			End AS b_offerPrice
			
	    , Case When b.item_Type in ('TBB','JAEBON','PANBI','EMBO','ENVINSERT','QICKDELIVERY', 'DONATION', 'TMAP')  Then b.item_Price - Round(b.item_Price/1.1, 0)	
				When b.item_Type = 'F' and b.item_Price <> 0									Then b.item_price - Round(b.item_price/1.1, 0)
				When b.item_Type = 'F' and b.item_Price = 0										Then 0
				When b.item_Type  = 'E'		and b.Card_ErpCode = 'BE029'						Then	0
				When b.item_Type IN ('L', 'V') and b.item_Price = 0								 Then	0  --이상민추가 20100220
				When b.item_Type  in ('S','M', 'X', 'W')  and b.item_price > 0							Then 	b.item_price*b.item_count - Round((b.item_price*b.item_count)/1.1 , 0)
				When b.item_Type  in ('S','M', 'X', 'W')  and b.item_price <= 0							Then 	0			
				Else ( IsNull(e.c_sobi, 0)*b.item_count) - Round(( IsNull(e.c_sobi, 0)*b.item_count)/1.1,0)
			End AS b_superTax
			
		, Case When b.item_Type in ('TBB','JAEBON','PANBI','EMBO','ENVINSERT','QICKDELIVERY', 'DONATION', 'TMAP')  Then b.item_Price	
				When b.item_Type = 'F' and b.item_Price <> 0									Then b.item_price
				When b.item_Type = 'F' and b.item_Price = 0										Then 0
				When b.item_Type IN ('L', 'V') and b.item_Price = 0								 Then	0  --이상민추가 20100220
				When b.item_Type  = 'E' and b.Card_ErpCode = 'BE029'								Then	0
				When b.item_Type  in ('S','M', 'X', 'W')  and b.item_price > 0							Then 	b.item_price*b.item_count
				When b.item_Type  in ('S','M', 'X', 'W')  and b.item_price <= 0							Then 	0			
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
								Case When (b.item_type = 'F' and b.item_price > 0) 
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

FROM #custom_order a 
JOIN  #custom_order_item b ON a.order_seq = b.order_seq 
JOIN company c ON a.company_seq = c.company_seq
JOIN #CardMaster d ON b.card_seq = d.card_seq
LEFT JOIN #sales_gubunTemp O ON a.sales_gubun = O.sales_gubun 
LEFT JOIN [erpdb.bhandscard.com].BHC.DBO.ItemSiteMaster E ON E.SiteCode = 'BHC2' AND d.Card_ErpCode = E.ItemCode

WHERE a.status_Seq = 15 
	and a.order_seq = @OrderSeq
	and a.pay_type <> '4' 
	and A.sales_gubun in ( 'SD' ) --디얼디어
ORDER BY a.order_seq 


--**************************************************************************************************************
--   * 할인율에 맞추어 각 아이템 금액 재계산  	
--**************************************************************************************************************
--rollback
--select * from #erp_salesReport where order_seq = 2736311


--begin tran 
	UPDATE #erp_salesReport 
	SET h_optionPrice = a.option_sumPrice ,
		DiscountRate  = a.discountRate,	 
		b_sumPrice    =	Case 
							When b.b_goodCode in ('TBB','JAEBON','PANBI','EMBO','ENVINSERT','QICKDELIVERY', 'DONATION', 'TMAP') Then b.b_sumPrice
							Else Round( ((b.b_sumPrice * (100-a.DiscountRate)/100)/1.1) 
								+ (b.b_sumPrice * (100-a.DiscountRate)/100) - ((b.b_sumPrice * (100-a.DiscountRate)/100)/1.1), 0)
						End,
 		b_offerPrice    = Case 
							When b.b_goodCode in ('TBB','JAEBON','PANBI','EMBO','ENVINSERT','QICKDELIVERY', 'DONATION', 'TMAP') Then Round(b.b_sumPrice/1.1, 0)
							--Else Round( (b.b_sumPrice * (100-a.DiscountRate)/100)/1.1, 0)
							ELSE  Round( ( ((b.b_sumPrice * (100-a.DiscountRate)/100)/1.1) 
								+ (b.b_sumPrice * (100-a.DiscountRate)/100) - ((b.b_sumPrice * (100-a.DiscountRate)/100)/1.1) ) / 1.1, 0)
						
						End,
 		b_superTax    = Case 
							When b.b_goodCode in ('TBB','JAEBON','PANBI','EMBO','ENVINSERT','QICKDELIVERY', 'DONATION', 'TMAP') Then Round(b.b_sumPrice - b.b_sumPrice/1.1,0)
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
										 Else CASE WHEN (ISNULL(b.b_sumprice, 0)- ISNULL(c.option_sumprice, 0)) = 0 THEN 0 ELSE  (((ISNULL(b.b_sumprice, 0)-ISNULL(c.option_sumprice, 0)) - (ISNULL(a.h_sumprice, 0)-ISNULL(c.option_sumprice, 0)))*100) / (ISNULL(b.b_sumprice, 0)- ISNULL(c
.option_sumprice, 0)) END
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

	--#5744 스티커 'DDS001','DDS002','DDS003' 1판에 105장으로 계산해서 입력 / 해당상품은 부가상품으로만 주문가능.
	UPDATE #erp_salesReport 
	SET b_OrderNum = ISNULL(b_OrderNum, 0) * 105
	WHERE b_goodCode IN ( 'DDS001', 'DDS002', 'DDS003')  AND ISNULL(b_OrderNum, 0) < 100 -- 화면상 최대 19판		


	--20100324
	SELECT  IDENTITY(int, 1, 1) AS ItemSerNo, *
	INTO #ERP_SalesDataTemp
	FROM #erp_salesReport
	ORDER BY h_Orderid ASC, b_sumPrice DESC, b_goodCode 
	

	--select * from #ERP_SalesDataTemp where h_Orderid like '%2458873%'

--**************************************************************************************************************
--Erp_salesData에 Insert
--**************************************************************************************************************

	INSERT INTO  [erpdb.bhandscard.com].BHC.DBO.erp_salesData 
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
   	LEFT JOIN OPENQUERY([erpdb.bhandscard.com], 'SELECT DISTINCT h_orderid FROM BHC.DBO.erp_salesData ')  c ON a.h_orderid = c.h_orderid	   --Erp_SalesData에 중복 입력 오류 방지		
	--LEFT JOIN [erpdb.bhandscard.com].XERP.DBO.erp_salesData c ON a.h_orderid = c.h_orderid
	
	LEFT JOIN Custom_order_Group G ON A.order_g_seq = G.order_g_seq
	
	WHERE c.h_orderid is null
GO


