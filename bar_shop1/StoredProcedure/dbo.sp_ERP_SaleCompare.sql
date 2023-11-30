IF OBJECT_ID (N'dbo.sp_ERP_SaleCompare', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_ERP_SaleCompare
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE     procedure [dbo].[sp_ERP_SaleCompare]
--exec [sp_ERP_SaleCompare] 'M','20081001','20081031'
 @Gubun as char(1),	 --'M': 매출기준, 'S': 수금기준
 @SDate as char(8),
 @EDate as char(8)
as

--IF @Gubun = 'M'  --매출일 기준 검색

	--########################################################################################
	--빠른손 매출 데이터 취합
	--########################################################################################
	Declare @ShopData  Table  (  
		h_partCode		nvarchar(10)	 NULL,   
		h_gubun			nvarchar(10)	 NOT NULL,   
		h_orderid		nvarchar(20) 	 NOT NULL,
		h_sumPrice		numeric(28, 8) 	 NULL,
		h_date			char(8)			 NOT NULL
	)

	INSERT INTO @ShopData (h_partCode,h_gubun,h_orderid, h_sumPrice,h_date)

		--초대장
		SELECT  a.sales_gubun,'초대장',a.order_seq, a.settle_price, Convert(char(8),a.src_send_date,112)
		FROM CUSTOM_ORDER a Inner Join COMPANY b on a.company_seq = b.company_seq 
		WHERE a.status_seq = 15 
			and Convert(char(8),a.src_send_date,112) between @SDate and @EDate
			and pay_type <> '4' 
			--and a.sales_gubun in ('W','T','U','A','J','B','S','X') 
			and a.sales_gubun in ('W','T','U','A','J','B','S','X') 
			and (not A.company_seq in (224,232,1137,1250,2235) or (A.company_seq in (232,1137,1250,2235) and reduce_price = 0 and settle_price > 0)) 

				
		UNION 
		
		--디지털플라자 (후불결제업체)
		SELECT a.sales_gubun,'지마켓', a.order_seq, a.Reduce_price*-1, Convert(char(8),a.src_send_date,112)
		FROM CUSTOM_ORDER A inner join Company B on A.company_Seq = B.company_seq 
		WHERE A.status_seq = 15 
			and Convert(char(8),a.src_send_date,112) between @SDate and @EDate
			and A.company_seq in (232,1137,1250,2235) and reduce_price < -60000 
			and a.up_order_seq is null 
			and pay_type<>'4' 
			
		UNION
		
		--x-art
		SELECT a.sales_gubun,'X-ART', a.order_seq, a.settle_price, Convert(char(8),a.src_send_date,112)
		FROM CUSTOM_ORDER A 
		WHERE A.status_seq = 15 
		and A.company_seq =224 
		and Convert(char(8),a.src_send_date,112) between @SDate and @EDate

		
		UNION
		
		--샘플 (티아라 카드는 출고가 20% 할인하여 매출 등록)
		SELECT sales_gubun,'샘플',sample_order_seq, settle_price, Convert(char(8),delivery_date,112) 
		FROM custom_sample_order 
		WHERE status_Seq= 12 
			and sales_gubun in ('W','T','U','B','S','A') 
			and Convert(char(8),delivery_date,112) between @SDate and @EDate
					
		UNION
		
		--식권
		SELECT sales_gubun,'식권', order_seq, settle_price,  Convert(char(8),delivery_date,112) 
		FROM custom_etc_order 
		WHERE 
			status_seq=12 and order_Type in ('F','P') 
			and sales_gubun <> 'D' 
			and Convert(char(8),delivery_date,112) between @SDate and @EDate 
			

		UNION
		
		--e청첩장
		SELECT sales_gubun,'e청첩장', order_id,settle_price, Convert(char(8),settle_date,112)
		FROM the_ewed_order 
		WHERE AC_STATE='P' and settle_Status=2 
			and status_Seq=2 
			and order_result in ('3','4') 
			and Convert(char(8),settle_date,112) between @SDate and @EDate
			and sales_gubun in ('U','T','W','J','B') 
			
		UNION

		--시판시즌 샘플
		SELECT sales_gubun,'시판', order_seq, settle_price,  Convert(char(8),delivery_date,112) 
		FROM custom_etc_order 
		WHERE status_seq=12 
			and order_Type in ('C','S')  
			and Convert(char(8),delivery_date,112) between @SDate and @EDate
			
		UNION
		
		--참카드 해피카드매출
		SELECT sales_gubun,'참카드',a.order_seq, a.settle_price, Convert(char(8),a.src_send_date,112)
		FROM CUSTOM_ORDER a JOIN custom_order_item b ON a.order_seq = b.order_seq 
		JOIN Card c ON b.card_seq = c.Card_seq
		WHERE Convert(char(8),a.src_send_date,112) between @SDate and @EDate 
		and a.status_seq = 15
		and a.pay_type <> '4' 
		and a.sales_gubun ='D' 
		and a.src_printer_seq <= 2 
		and a.company_seq  = 237 
		and c.company = 8

		
		
	--########################################################################################
	--ERP 데이터 취합
	--########################################################################################
	Declare @ErpData  Table  (      
		h_partCode			nvarchar(20) 	 NULL,
		h_oldid				nvarchar(20) 	 NOT NULL,  --원주문번호 
		h_orderid			nvarchar(20) 	 NOT NULL,	--주문번호 (앞에 IC, IS등 제거)
		h_sumPrice			numeric(28, 8) 	 NULL,		--중간테이블 금액
		h_date				char(8)			 NULL,		--매출일
		h_BillNo			nvarchar(20) 	 NULL,		--매출전표번호
		h_BillPrice			numeric(28, 8) 	 NULL,		--매출금액
		h_diffPrice			numeric(28, 8) 	 NULL,		--수금 차액
		h_shopID			nvarchar(20) 	 NULL,		--PG ID
		h_JumunNO			nvarchar(20) 	 NULL,		--PG주문번호 
		h_DealAmnt			numeric(28, 8) 	 NULL,		--수금액
		h_PayDate			char(8)			 NULL,		--수금일
		h_DocNo				nvarchar(20) 	 NULL		--수금전표번호
	)




	INSERT INTO @ErpData (h_partCode,h_oldid,h_orderid, h_sumPrice, 
						  h_date,h_BillNo,h_BillPrice, h_diffPrice, h_shopID,h_JumunNo, h_DealAmnt,h_payDate, h_DocNo)


	--Dacom 수금연동(바른손,더카드,스토리 등)	
	SELECT a.h_partCode,a.h_orderid
		, h_orderid  =   Case 
							When h_orderid like 'ICS%' Then Replace(h_orderid,'ICS','') 
							When h_orderid like 'IC%' Then  Replace(h_orderid,'IC','') 
							When h_orderid like 'IS%' Then  Replace(h_orderid,'IS','') 
							When h_orderid like 'EW%' Then  Replace(h_orderid,'EW','') 
							When h_orderid like 'D%'  Then  Replace(h_orderid,'D','') 
							When h_orderid like 'ET%' Then  Replace(h_orderid,'ET','') 
							When h_orderid like 'SC%' Then  Replace(h_orderid,'SC','') 
							When h_orderid like 'IE%' Then  Replace(h_orderid,'IE','') 
							Else h_orderid
						End 
			, a.h_sumPrice, a.h_date 
			, b.BillNo ,b.MoneySumAmnt  --ERP 매출정보
			,(Isnull(c.DealAmnt, 0) - ISNULL(a.h_SumPrice, 0)) as diffPrice
			,c.Shop_id, c.JumunNo, c.DealAmnt,c.payDate  --데이콤 수금 정보
			,e.DocNo    --ERP 수금정보
			
	FROM	[211.172.242.78].XERP.DBO.erp_salesData a FULL OUTER JOIN [211.172.242.78].XERP.DBO.rpBillHeader b 
			ON a.h_orderid = b.C_JumunNo
			LEFT JOIN [211.172.242.78].XERP.DBO.DacomItem c 
			ON a.h_orderid = c.JumunNo    
			LEFT JOIN [211.172.242.78].XERP.DBO.rpExpectMoneyAlloc d 
			ON a.b_memo = d.OriginNo and d.AllocSerNo = 1 AND d.SiteCode = N'BK10'
			LEFT JOIN [211.172.242.78].XERP.DBO.rpExpectMoneyAlloc e 
			ON d.DocNo = e.OriginNo AND e.SiteCode = N'BK10'
	WHERE a.h_date BETWEEN @SDate and @EDate
		  and a.b_seq = 1	
		  and a.h_partCode in ('380','390','395','450','510') 
		  and b.BillDate BETWEEN @SDate and @EDate

	UNION

	--Dacom 수금 미연동(티아라,투유)
	SELECT a.h_partCode,a.h_orderid
		, h_orderid  =   Case 
							When h_orderid like 'ICS%' Then Replace(h_orderid,'ICS','') 
							When h_orderid like 'IC%' Then  Replace(h_orderid,'IC','') 
							When h_orderid like 'IS%' Then  Replace(h_orderid,'IS','') 
							When h_orderid like 'EW%' Then  Replace(h_orderid,'EW','') 
							When h_orderid like 'D%'  Then  Replace(h_orderid,'D','') 
							When h_orderid like 'ET%' Then  Replace(h_orderid,'ET','') 
							When h_orderid like 'SC%' Then  Replace(h_orderid,'SC','') 
							When h_orderid like 'IE%' Then  Replace(h_orderid,'IE','') 
							Else h_orderid
						End 
			, a.h_sumPrice, a.h_date 
			, b.BillNo ,b.MoneySumAmnt  --ERP 매출정보
			,null
			,null, null, null, null  --데이콤 수금 정보
			,d.DocNo    --ERP 수금정보
			
	FROM	[211.172.242.78].XERP.DBO.erp_salesData a FULL OUTER JOIN [211.172.242.78].XERP.DBO.rpBillHeader b 
			ON a.h_orderid = b.C_JumunNo
			LEFT JOIN [211.172.242.78].XERP.DBO.rpExpectMoneyAlloc d 
			ON a.b_memo = d.OriginNo and d.AllocSerNo = 1 AND d.SiteCode = N'BK10'
	WHERE a.h_date BETWEEN @SDate and @EDate
		  and a.b_seq = 1	
		  and a.h_partCode IN ('550','870') 
		  and b.BillDate BETWEEN @SDate and @EDate  
		  
		  
		

	--########################################################################################
	--통합 데이터 (빠른손 + ERP) 
	--########################################################################################
	Declare @TotalData  Table  (   
		h_partCode		nvarchar(20) 	 NULL,   
		h_orderid		nvarchar(20) 	 NOT NULL,
		h_sumPrice		numeric(28, 8) 	 NULL,
		h_date			char(8)			 NULL
	)

	INSERT INTO @TotalData (h_partCode,h_orderid, h_sumPrice, h_date)
		SELECT	h_partCode = Case
								When h_partCode = 'W' Then '바른손카드'
								When h_partCode = 'T' Then '더카드'
								When h_partCode = 'U' Then '투유카드'
								When h_partCode = 'A' Then '티아라카드'
								When h_partCode = 'J' Then '제휴'	
								When h_partCode = 'S' Then '스토리'	
								When h_partCode = 'X' Then '연말'
								When h_partCode = 'D' Then '더카드'	
								When h_partCode = 'B' Then '제휴'	
														
							 End,
				h_orderid, h_sumPrice, h_date 
		FROM @ShopData 

		UNION

		SELECT h_partCode = Case
								When h_partCode = '510' Then '바른손카드'
								When h_partCode = '380' Then '더카드'
								When h_partCode = '550' Then '투유카드'
								When h_partCode = '870' Then '티아라카드'
								When h_partCode = '390' Then '제휴'	
								When h_partCode = '450' Then '스토리'	
								When h_partCode = '395' Then '연말'
							 End,
		
				h_orderid, h_sumPrice, h_date 
		FROM @ErpData 


	--########################################################################################
	--매출 수금 비교
	--########################################################################################
	SELECT  a.h_partCode,b.h_gubun,a.h_orderid, --a.h_sumPrice, 
			a.h_date, 
			b.h_orderid as '빠른손 orderid', b.h_sumPrice as '빠른손 settlePrice', -- b.h_date, 
			c.h_orderid as 'ERP orderid', c.h_sumPrice as 'ERP settlePrice' --, c.h_date
			,c.h_BillNo as '매출전표' ,c.h_BillPrice as  '매출금액' 
			,c.h_ShopID as 'PG ID', c.h_JumunNo as 'PG 주문번호', c.h_DealAmnt as 'PG결제금액'  --데이콤 수금 정보
			,c.h_payDate as '입금일',c.h_diffPrice as '수금차액'
			,c.h_DocNo as '수금전표'   --ERP 수금정보
	FROM (SELECT distinct h_partCode,h_orderid, h_sumprice, h_date FROM @TotalData) a LEFT JOIN @ShopData b
		ON a.h_orderid = b.h_orderid 
		LEFT JOIN @ErpData c
		ON a.h_orderid = c.h_orderid			
	WHERE b.h_orderid is null 
	--	  OR 
	--	  c.h_orderid is null
	--	  OR
	--	  c.h_BillNo is null
		  OR
		  c.h_DocNo is null

	ORDER BY a.h_date , a.h_orderid


--ELSE
	

	
	

GO
