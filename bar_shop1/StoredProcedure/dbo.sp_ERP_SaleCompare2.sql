IF OBJECT_ID (N'dbo.sp_ERP_SaleCompare2', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_ERP_SaleCompare2
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
	
	
CREATE     procedure [dbo].[sp_ERP_SaleCompare2]
--exec [sp_ERP_SaleCompare2] '20081001','20081031'
 --@Gubun as char(1),	 --'M': 매출기준, 'S': 수금기준
 @SDate as char(8),
 @EDate as char(8)
as
	
	
	
	
	--########################################################################################
	--ERP 데이터 취합
	--########################################################################################
	Declare @ErpData  Table  (      
		h_partCode			nvarchar(20) 	 NULL,
		h_oldid				nvarchar(20) 	 NULL,  --원주문번호 
		h_orderid			nvarchar(20) 	 NULL,	--주문번호 (앞에 IC, IS등 제거)
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




	INSERT INTO @ErpData (h_orderid, h_BillNo,h_BillPrice, h_shopID,h_JumunNo, h_DealAmnt,h_payDate, h_DocNo)

	
	--Dacom 수금연동(바른손,더카드,스토리 등)	
	SELECT h_orderid  =   Case 
							When JumunNo like 'ICS%' Then Replace(JumunNo,'ICS','') 
							When JumunNo like 'IC%' Then  Replace(JumunNo, 'IC','') 
							When JumunNo like 'IS%' Then  Replace(JumunNo,'IS','') 
							When JumunNo like 'EW%' Then  Replace(JumunNo, 'EW','') 
							When JumunNo like 'D%'  Then  Replace(JumunNo,'D','') 
							When JumunNo like 'ET%' Then  Replace(JumunNo,'ET','') 
							When JumunNo like 'SC%' Then  Replace(JumunNo, 'SC','') 
							When JumunNo like 'IE%' Then  Replace(JumunNo,'IE','') 
							Else JumunNo
						End 
			, b.BillNo ,b.MoneySumAmnt  --ERP 매출정보
			--,(Isnull(c.DealAmnt, 0) - ISNULL(a.h_SumPrice, 0)) as diffPrice
			,a.Shop_id, a.JumunNo, a.DealAmnt,a.payDate  --데이콤 수금 정보
			,c.DocNo    --ERP 수금정보
			
	FROM	DacomItem a LEFT JOIN rpBillHeader b 
			ON a.JumunNo = b.C_JumunNo
			LEFT JOIN rpExpectMoneyAlloc c 
			ON b.BillNo = c.OriginNo and c.AllocSerNo = 1 AND c.SiteCode = N'BK10'
			LEFT JOIN rpExpectMoneyAlloc d 
			ON c.DocNo = d.OriginNo AND d.SiteCode = N'BK10'
			
	WHERE a.PayDate BETWEEN '20081001' and '20081031'
		  and a.shop_id in 
		  (
			'barunson1',   
			'barunson2',   
			'barunson3',   
			'barunson4',   
			'barunsonb2b', 
			'season',      
			'storyoflove', 
			'thecard1',    
			'thecard2',    
			'thecard3',    
			'zzico'       
		  ) 
	
		
		
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
			and a.sales_gubun in ('W','T','A','J','B','S','X') 
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
			and sales_gubun in ('W','T','B','S','A') 
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
			and sales_gubun in ('T','W','J','B') 
			
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

	
	
	
	SELECT * FROM @ErpData a LEFT JOIN @ShopData b 
	ON a.h_orderid = b.h_orderid 
GO
