IF OBJECT_ID (N'dbo.sp_ERP_SaleCompare_dev', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_ERP_SaleCompare_dev
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE     procedure [dbo].[sp_ERP_SaleCompare_dev]
--exec [sp_ERP_SaleCompare_dev] 'M','20081001','20081031'
 @Gubun as char(1),	 --'M': 매출기준, 'S': 수금기준
 @SDate as char(8),
 @EDate as char(8)
as

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
			and sales_gubun in ('U','T','W','J','B','O') 
			
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
		JOIN Card c ON a.card_seq = c.Card_seq
		WHERE Convert(char(8),a.src_send_date,112) between @SDate and @EDate 
		and Convert(char(8),a.src_send_date,112) < '20081201' 
		and a.status_seq = 15
		and a.pay_type <> '4' 
		and a.sales_gubun ='D' 
		and a.src_printer_seq <= 2 
		and a.company_seq  = 237 
		and c.company = 8
	
		
	--########################################################################################
	--ERP rpBill 데이터 취합
	--########################################################################################
	Declare @ErprpBill  Table  (   
									h_date			char(8)			 NULL,
									h_partCode		nvarchar(20)	 NULL,
									h_BillNo		nvarchar(20)	 NULL,
									h_orderid		nvarchar(30)	 NULL,
									h_pgid			nvarchar(30)	 NULL,
									h_sumPrice		numeric(28, 8) 	 NULL,
									h_offerPrice	numeric(28, 8) 	 NULL,
									h_Tax			numeric(28, 8) 	 NULL,
									h_BillDesc		nvarchar(30)	 NULL,	
									h_InvoiceNo		nvarchar(30)	 NULL,
									h_CsCode		nvarchar(30)	 NULL,
									b_ItemCode		nvarchar(30)	 NULL,
									b_ItemQty		nvarchar(30)	 NULL,
									b_ItemAmnt		nvarchar(30)	 NULL,
									b_ItemVatAmnt	numeric(28, 8) 	 NULL,	
									b_ItemSumPrice	numeric(28, 8) 	 NULL,	
									b_InoutNo		nvarchar(30)	 NULL
								)
	INSERT 	INTO @ErprpBill (h_date, h_partcode,h_BillNo, h_orderid, h_pgid, h_sumPrice, h_offerPrice, h_Tax, h_BillDesc, h_InvoiceNo, h_Cscode,
						b_ItemCode, b_ItemQty, b_ItemAmnt, b_ItemVatAmnt, b_ItemSumPrice, b_InoutNo)						

	SELECT 
		a.BillDate,a.DeptCode, a.BillNo,C_JumunNo = Case	
														When a.C_JumunNo like 'ICS%' Then Replace(a.C_JumunNo,'ICS','') 
														When a.C_JumunNo like 'IC%' Then  Replace(a.C_JumunNo,'IC','') 
														When a.C_JumunNo like 'IS%' Then  Replace(a.C_JumunNo,'IS','') 
														When a.C_JumunNo like 'EW%' Then  Replace(a.C_JumunNo,'EW','') 
														When a.C_JumunNo like 'D%'  Then  Replace(a.C_JumunNo,'D','') 
														When a.C_JumunNo like 'ET%' Then  Replace(a.C_JumunNo,'ET','') 
														When a.C_JumunNo like 'SC%' Then  Replace(a.C_JumunNo,'SC','') 
														When a.C_JumunNo like 'IE%' Then  Replace(a.C_JumunNo,'IE','') 
														Else a.C_JumunNo
													  End
		,a.C_JumunNo,a.MoneySumAmnt, a.BillAmnt, a.vatAmnt, a.BillDescr, a.InvoiceNo, a.CsCode,
		b.ItemCode, b.ItemQty, b.ItemAmnt, b.ItemVatAmnt, b.PostedItemAmnt, b.InoutNo 		
	FROM [211.172.242.78].XERP.DBO.rpBillHeader a JOIN [211.172.242.78].XERP.DBO.rpBillItem b ON a.BillNo = b.BillNo 
	WHERE a.BillDate BETWEEN @SDate and @EDate
		and a.DeptCode in ('380','390','395','450','510','550','870')
		
	
	
	--########################################################################################
	--결과 Report
	--########################################################################################	
	SELECT Case
			When a.h_partCode = 'W' Then '바른손카드'
			When a.h_partCode = 'T' Then '더카드'
			When a.h_partCode = 'U' Then '투유카드'
			When a.h_partCode = 'A' Then '티아라카드'
			When a.h_partCode = 'J' Then '제휴'	
			When a.h_partCode = 'S' Then '스토리'	
			When a.h_partCode = 'X' Then '연말'
			When a.h_partCode = 'D' Then '더카드'	
			When a.h_partCode = 'B' Then '제휴'	
									
		  End,* 
  FROM @ShopData a FULL JOIN @ErprpBill b ON a.h_orderid = b.h_orderid	 
  WHERE a.h_orderid is Null 
		OR b.h_BillNo is Null 
		--OR b.h_InvoiceNo is null		  
		  
		  
		  
		  
GO
