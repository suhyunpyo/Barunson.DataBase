IF OBJECT_ID (N'dbo.sp_ERP_Transfer_wedding_@', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_ERP_Transfer_wedding_@
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO



-- ##########################################################################################################      
-- 온라인 웨딩 (웨딩 사이트 및 결사모, 마이e웨딩, 삼성카드 등 포함, ecSupport하고 제일모직은 일단 제외)
-- ########################################################################################################## 
--EXEC sp_ERP_Transfer_wedding '20090326','20090327'


CREATE                       procedure [dbo].[sp_ERP_Transfer_wedding_@]
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
	b_memo_temp	char(16) 	NULL,
	DeptGubun	char(2) 		NOT NULL,
	DiscountRate	numeric(28, 8) 	NULL
	 )    
     




--**************************************************************************************************************
--1.청첩장
--**************************************************************************************************************
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
	h_biz		= 'BK10',
	h_gubun		= 'SO',
	h_date		= Convert(char(8),a.src_send_date,112),

	h_sysCode	= Case 
				When b.item_Type ='C'                                           	Then '270'    --카드는 정상출고
				When b.item_Type ='E'                                           	Then '270'    --봉투도 정상출고
				When b.item_Type ='I'                                            	Then '270'    --봉투도 정상출고
				When b.item_Type ='A'                                           	Then '270'    --악세사리도 정상출고
				When b.item_Type ='F'  and item_price > 0    		Then '270'     -- 식권은 매출 금액이 있으면 정상출고(270), 무료이면 무료제공품(300),
				When b.item_Type ='F'  and item_price <= 0  		Then '270'     -- 식권은 매출 금액이 있으면 정상출고(270), 무료이면 무료제공품(300),
				When b.item_Type ='S'  and item_price > 0   		Then '270'    --유료스티커
				When b.item_Type ='S'  and item_price <= 0  	Then '270'    --무료스티커
				When b.item_Type ='L'        		        	Then '270'    --사은품
				When b.item_Type ='M'  and item_price > 0   		Then '270'   --유료미니청첩장
				When b.item_Type ='M'  and item_price <= 0  	Then '270'   --무료미니청첩장
				When b.item_Type = 'TBB'     		         	Then '270'  --서비스매출품목군 (출고없음)
				When b.item_Type = 'JAEBON'                                 	Then '270'  --서비스매출품목군 (출고없음)
				When b.item_Type = 'PANBI'                                    	Then '270'
				--When b.item_Type = 'STICKER'                                	Then '270' --스티커는 item_sale_item에 들어감
				When b.item_Type = 'EMBO'                                    	Then '270'
				When b.item_Type = 'ENVINSERT'                            	Then '270'
				When b.item_Type = 'QICKDELIVERY'		Then '270'	
			  End,
	
	h_usrCode	= Case 
				When b.item_Type ='C'                                       	Then '270'   --카드는 정상출고
				When b.item_Type ='E'                                          	Then '270'   --봉투도 정상출고
				When b.item_Type ='I'                                           	Then '270'    --봉투도 정상출고
				When b.item_Type ='A'                                          	Then '270'   --악세사리도 정상출고
				When b.item_Type ='F'  and item_price > 0   		Then '270'     -- 식권은 매출 금액이 있으면 정상출고(270), 무료이면 무료제공품(300),
				When b.item_Type ='F'  and item_price <= 0 		Then '270'   -- 식권은 매출 금액이 있으면 정상출고(270), 무료이면 무료제공품(300),
				When b.item_Type ='S'  and item_price > 0   		Then '270'    --유료스티커
				When b.item_Type ='S'  and item_price <= 0  	Then '270'    --무료스티커
				When b.item_Type ='L'        		        	Then '270'  --사은품
				When b.item_Type ='M'  and item_price > 0   		Then '270'   --유료미니청첩장
				When b.item_Type ='M'  and item_price <= 0  	Then '270'   --무료미니청첩장
				When b.item_Type = 'TBB'     		         	Then '270'
				When b.item_Type = 'JAEBON'                                 	Then '270'
				When b.item_Type = 'PANBI'                                    	Then '270'
				--When b.item_Type = 'STICKER'                               	Then '270'
				When b.item_Type = 'EMBO'                                    	Then '270'
				When b.item_Type = 'ENVINSERT'                            	Then '270'
				When b.item_Type = 'QICKDELIVERY'		         	Then '270'	
			   End, 	

	--**************************************************************************************************************
	--   * 거래처코드 (company_seq로 구분)
	--**************************************************************************************************************
	--          1. 웨딩사이트         (1272)
	--          2. 결사모                (587)
	--          3. 결혼도움방         (1186)
	--          4. 삼성카드 임직원  (532)
	--	5. 삼성카드 회원    (553)
	--	6. 마이e웨딩          (2107)
	--	7. Escupport
	-- 	company_seq in (532,553,587,1186,1272)  --삼성카드 임직원, 삼성카드회원,결사모,결혼도움방, 마이e웨딩
	h_comcode	=   Case  
				When a.company_seq =  532   			Then   	 '1305136'   -- 삼성카드     pgid : samsungcard
				When a.company_seq =  553   			Then   	 '1305136'   -- 삼성카드     pgid : samsungcard
				When a.company_seq =  587  			    Then   	 '1301516'   -- 결사모        pgid : pigwedding
				When a.company_seq =  1186  			Then  	 '1351590'   -- 결혼도움방  pgid :  pigwedding
				When a.company_seq =  2107  			Then  	 '2400121'   -- 마이e웨딩   pgid :studiomall -> dacom PG임 
				When a.company_seq =  2590				Then     '1351684'   --롯데백화점
				When a.sales_gubun = 'O' and c.jaehu_kind ='C'  	Then 	 '1490019'  -- 웨딩사이트  '1490019'   -- 웨딩사이트
				Else  c.erp_code	
			     End,
	------------------------------------------------------------------------------------------------------------------




	--**************************************************************************************************************
	--   * 과세유형
	--**************************************************************************************************************
	--         1. PG결제 업체중 LG 마이 e웨딩만 일반과세(10)고 나머진 매출 영수증(22)
	--         2. 후불결제 업체중 아래 4개 업체는 일반과세(10)고 나머진 매출 영수증(22) 
	--              	--팔방에프엔비          1300748
			--남산예술원              1495193
			--갤러리아웨딩홀식당 1495190
			--현대41컨벤션웨딩    1495184
			--마이e웨딩  2400121
              h_taxType	=  Case
				When   c.erp_code in ('1300748','1495193','1495190','1495184','2400121')  Then '10' 
				Else '22'
			    End,
	------------------------------------------------------------------------------------------------------------------

	



	--**************************************************************************************************************
	--* LG e웨딩의 경우 헤더금액을 결제금액의 90%로 조정함
	--**************************************************************************************************************
	h_offerPrice	=   Case
			     			When a.company_seq =  2107  Then floor((a.settle_price*0.9)/1.1) 
							Else Round(a.settle_price/1.1,0) 
						End,				
	h_superTax	=   Case
			     		When a.company_seq =  2107  Then floor(a.settle_price*0.9) - floor((a.settle_price*0.9)/1.1)  
						Else Round(a.settle_price- a.settle_price/1.1,0)
					End,	
	h_sumPrice	=   Case
			     		When a.company_seq =  2107  Then   floor(a.settle_price*0.9)
						Else a.settle_price
					End,	

	h_optionPrice      = 0,
	h_partCode	= '360',				
	h_staffcode	= '030801',    --원덕규				
	h_sonik		= '110',
	h_cost		= '129',
	h_orderid	= a.pg_tid,
	h_memo1	= null,
	h_memo2	= a.pg_tid,
	h_memo3	= null,
	b_biz		= 'BK10',
	b_goodGubun	= 'SO',
	b_seq		= 1,
	b_storeCode	= 'MF03',
	b_date		= Convert(char(8),a.src_send_date,112),
	b_goodCode	= b.card_code, --b.item_type
	b_goodUnit	= 'EA',
	b_OrderNum	= b.item_count,
	------------------------------------------------------------------------------------------------------------------




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


	--**************************************************************************************************************
	--   * PG체크
	--**************************************************************************************************************
	--         1. 마이 e웨딩을 제외한 PG결제 업체는 'Y' 나머진 'N'
	PGCheck	=  Case
				When a.company_seq in (532,553,587,1186,1272,2590)  Then 'Y'
				When a.sales_gubun = 'O' and c.jaehu_kind ='C'  Then 'Y'  -- 웨딩사이트
				Else 'N'	
			    End,
	------------------------------------------------------------------------------------------------------------------


	PayAmnt		= 0,
	SampleCheck	= 'N',
	XartCheck	= 'N',
	SettleDate	= null,
	PayDate		= null,
	PayCheck	= null,
	DealAmnt	= null,
	b_memo_temp	= null,
	DeptGubun	= 'WE'
FROM 
	custom_order a JOIN  (
				SELECT order_seq,card_seq, card_code,item_type, item_count, item_price
				FROM 
					(
					--기본 아이템 정보 
					SELECT  a.order_seq, b.card_seq,c.card_code, b.item_type,b.item_count as item_count ,  IsNUll(b.item_sale_price,0) as item_price
					FROM custom_order a JOIN  custom_order_item b ON  a.order_seq = b.order_seq
					JOIN card c ON b.card_seq = c.card_seq
					WHERE 
					Convert(char(8),a.src_send_date,112) between @SDate and @EDate
					and  a.status_seq = 15 
					and pay_type <> '4' 
					and (a.company_seq in (532,553,587,1186,2107,2590)  --삼성카드 임직원, 삼성카드회원,결사모,결혼도움방, 마이e웨딩
					         or	a.sales_gubun = 'O' and a.company_seq <> 15)  -- 웨딩 사이트, ecSupport
					) c
				UNION   
					--택배비
					(
					SELECT order_seq, card_seq,  'TBB', 'TBB', 1, delivery_price
					FROM Custom_Order 
					WHERE 
					Convert(char(8),src_send_date,112) between @SDate and @EDate
					and delivery_price > 0
					and  status_seq = 15 
					and pay_type <> '4' 
					and (company_seq in (532,553,587,1186,2107,2590)  
					         or	sales_gubun = 'O' and company_seq <> 15)  
					)  
			
				UNION   
					--제본
					(
					SELECT order_seq, card_seq, 'JAEBON','JAEBON',  order_count, JEBON_price
					FROM Custom_Order 
					WHERE 
					Convert(char(8),src_send_date,112) between @SDate and @EDate
					and jebon_price > 0
					and  status_seq = 15 
					and pay_type <> '4' 
					and (company_seq in (532,553,587,1186,2107,2590)  
					         or	sales_gubun = 'O' and company_seq <> 15)  
					)  
			
				UNION
					--추가판비   
					(
					SELECT order_seq, card_seq, 'PANBI','PANBI', 1, option_price
					FROM Custom_Order 
					WHERE 
					Convert(char(8),src_send_date,112) between @SDate and @EDate
					and option_price > 0
					and  status_seq = 15 
					and pay_type <> '4' 
					and (company_seq in (532,553,587,1186,2107,2590)  
					         or	sales_gubun = 'O' and company_seq <> 15)  
					)  
			
				UNION
					--엠보   
					(
					SELECT order_seq, card_seq,'EMBO', 'EMBO',order_count, embo_price
					FROM Custom_Order 
					WHERE 
					Convert(char(8),src_send_date,112) between @SDate and @EDate
					and embo_price > 0
					and  status_seq = 15 
					and pay_type <> '4' 
					and (company_seq in (532,553,587,1186,2107,2590)  
					         or	sales_gubun = 'O' and company_seq <> 15)  
					)  
				UNION   
					--봉투삽입
					(
					SELECT order_seq, card_seq,'ENVINSERT', 'ENVINSERT',order_count,  envInsert_price
					FROM Custom_Order 
					WHERE 
					Convert(char(8),src_send_date,112) between @SDate and @EDate
					and envinsert_price > 0
					and  status_seq = 15 
					and pay_type <> '4' 
					and (company_seq in (532,553,587,1186,2107,2590)  
					         or	sales_gubun = 'O' and company_seq <> 15)  
					)  
				
				UNION
					--초특급 배송(custom_order.isSpecial='1' 그리고, custom_order.delivery_price=30000)
					(
					SELECT order_seq, card_seq,'QICKDELIVERY', 'QICKDELIVERY',order_count, delivery_price = 30000
					FROM Custom_Order 
					WHERE 
					Convert(char(8),src_send_date,112) between @SDate and @EDate
					and isSpecial = '1'
					and status_seq = 15 
					and pay_type <> '4' 
					and (company_seq in (532,553,587,1186,2107,2590)  
					         or	sales_gubun = 'O' and company_seq <> 15)  
					)
				) b ON a.order_seq = b.order_seq

	JOIN company c ON a.company_seq = c.company_seq
	JOIN card d ON b.card_seq = d.card_seq
	
	LEFT JOIN  OPENQUERY([erpdb.bhandscard.com], 'SELECT  IsNull(stdPurprice,0) as stdPurprice, IsNull(c_sobi,0) as c_sobi,itemcode,itemgroup FROM XERP.DBO.itemSiteMaster ') e ON d.card_code = e.itemCode

WHERE 
Convert(char(8),a.src_send_date,112) between @SDate and @EDate
and  a.status_seq = 15 
and pay_type <> '4' 
and 
(
	c.company_seq = 2590  --삼성카드 임직원, 삼성카드회원,결사모,결혼도움방, 마이e웨딩
	--or
	--a.sales_gubun = 'O' and c.jaehu_kind ='C'  and c.company_seq <> 15 -- 일단 웨딩사이트만 올림, 후불결제(ecSupport)는 추후에..
	
	--*ecsupport
	--Select * from company where sales_gubun='O' and jaehu_kind='O' and status = 'S2' order by company_Seq desc 

	--*wedding
	--Select * from company where sales_gubun='O' and jaehu_kind='C' and status = 'S2' order by company_Seq desc

)
--and a.src_erp_date is null  
ORDER BY a.order_seq 





--**************************************************************************************************************
--2.샘플
--**************************************************************************************************************
-- 샘플 매출은 자사카드는 출고가 기준 10% 할인율 적용해서 올림
--      "  "         타사카드는 매입가 기준으로 올림
-- 배송비는 안올림

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
	h_biz		= 'BK10',
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

	h_comcode	= Case  
				When a.company_seq =  532   			Then   	 '1305136'   -- 삼성카드     pgid : samsungcard
				When a.company_seq =  553   			Then   	 '1305136'   -- 삼성카드     pgid : samsungcard
				When a.company_seq =  587  			Then   	 '1301516'   -- 결사모        pgid : pigwedding
				When a.company_seq =  1186  			Then  	 '1351590'   -- 결혼도움방  pgid :  pigwedding
				When a.company_seq =  2107  			Then  	 '2400121'   -- 마이e웨딩   pgid :studiomall -> dacom PG임 
				When a.company_seq =  2590				Then     '1351684'   --롯데백화점
				When a.sales_gubun = 'O' and c.jaehu_kind ='C'  	Then 	 '1490019'  -- 웨딩사이트  '1490019'   -- 웨딩사이트
				Else  c.erp_code	
			   End,
	h_taxType	=  Case
				When   c.erp_code in ('1300748','1495193','1495190','1495184','2400121')  Then '10' 
				Else '22'
			    End,
		

	h_offerPrice	=  Case
			     	When a.company_seq =  2107  Then Round(a.settle_price*0.9/1.1,0) 
				Else Round(a.settle_price/1.1,0) 
			    End,	

				
	h_superTax	=   Case
			     	When a.company_seq =  2107  Then Round((a.settle_price*0.9) - a.settle_price*0.9/1.1, 0)
				Else Round(a.settle_price- a.settle_price/1.1,0)
			     End,	
	h_sumPrice	=   Case
			     	When a.company_seq =  2107  Then Round(a.settle_price*0.9, 0)
				Else a.settle_price
			     End,	

	h_partCode	= '360',				
	h_staffcode	= '030801',				
	h_sonik		= '110',
	h_cost		= '129',
	h_orderid	= a.pg_tid,
	h_memo1	= null,
	h_memo2	= a.pg_tid,
	h_memo3	= null,
	b_biz		= 'BK10',
	b_goodGubun	= 'SO',
	b_seq		= 1,
	b_storeCode	= 'MF03',
	b_date		= Convert(char(8),a.delivery_Date,112),
	b_goodCode	= Case 
				When b.card_code = 'TBB' Then 'TBB'  --택배비
				Else  e.itemcode
			   End,



	b_goodUnit	= 'EA',
	b_OrderNum	= 1,
	b_unitPrice	= Case
				When b.card_code = 'TBB' Then 			 --택배비
					Case
						When  a.company_seq =  2107 Then a.settle_price*0.9
						Else a.settle_price
					End
				Else 0
			   End ,
	
	b_offerPrice	= Case
				When b.card_code = 'TBB' Then 
					Case 
						When  a.company_seq =  2107 Then  Round(a.settle_price*0.9/1.1, 0)	 
						Else  Round(a.settle_price/1.1, 0)		
					End
				Else 0
			   End ,
	b_superTax	= Case
				When b.card_code = 'TBB' Then 
					Case
						When a.company_seq =  2107 Then Round(a.settle_price*0.9 - (a.settle_price*0.9/1.1) ,0)	
						Else Round(a.settle_price - (a.settle_price/1.1) ,0)	
					End 
				Else 0
			   End ,
	b_sumPrice	= Case
				When b.card_code = 'TBB' Then 
					Case
						When a.company_seq =  2107 Then Round(a.settle_price*0.9,0)	
						Else  a.settle_price	
					End 

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
	PGCheck	=  Case
				When a.company_seq in (532,553,587,1186,1272,2590)  Then 'Y'
				When a.sales_gubun = 'O' and c.jaehu_kind ='C'  Then 'Y'  -- 웨딩사이트
				Else 'N'	
			    End,
	PayAmnt		= 0,
	SampleCheck	= 'Y',
	XartCheck	= 'N',
	SettleDate	= null,
	PayDate		= null,
	PayCheck	= null,
	DealAmnt	= null,
	b_memo_temp	= null,
	DeptGubun	= 'WE'
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
	JOIN company c ON a.company_seq = c.company_seq
	JOIN card d ON b.card_seq = d.card_seq
	LEFT JOIN  OPENQUERY([erpdb.bhandscard.com], 'SELECT  IsNull(stdPurprice,0) as stdPurprice, IsNull(c_sobi,0) as c_sobi,itemcode,itemgroup FROM XERP.DBO.itemSiteMaster ') e ON d.card_code = e.itemCode


WHERE 
a.status_seq = 12 
and  Convert(char(8),a.delivery_Date,112) between @SDate and @EDate
and 
(
	c.company_seq =2590--in (532,553,587,1186,2107,2590)  --삼성카드 임직원, 삼성카드회원,결사모,결혼도움방, 마이e웨딩
	--or
	--a.sales_gubun = 'O' and c.jaehu_kind ='C'  and c.company_seq <> 15 -- 일단 웨딩사이트만 올림, 후불결제(ecSupport)는 추후에..

)
--and a.src_erp_date is null  
ORDER BY a.sample_order_seq 



--**************************************************************************************************************
-- --3. 미니청첩장 및 식권 등 옵션 상품 따로 주문시 
--**************************************************************************************************************
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
	h_biz		= 'BK10',
	h_gubun		= 'SO',
	h_date		= Convert(char(8),a.delivery_date,112),
	h_sysCode	= '270',
	h_usrCode	= '270', 	

	--**************************************************************************************************************
	--   * 거래처코드 (company_seq로 구분)
	--**************************************************************************************************************
	--          1. 웨딩사이트         (1272)
	--          2. 결사모                (587)
	--          3. 결혼도움방         (1186)
	--          4. 삼성카드 임직원  (532)
	--	5. 삼성카드 회원    (553)
	--	6. 마이e웨딩          (2107)
	--	7. Escupport
	-- 	company_seq in (532,553,587,1186,1272)  --삼성카드 임직원, 삼성카드회원,결사모,결혼도움방, 마이e웨딩
	h_comcode	=   Case  
				When a.company_seq =  532   			Then   	 '1305136'   -- 삼성카드     pgid : samsungcard
				When a.company_seq =  553   			Then   	 '1305136'   -- 삼성카드     pgid : samsungcard
				When a.company_seq =  587  			Then   	 '1301516'   -- 결사모        pgid : pigwedding
				When a.company_seq =  1186  			Then  	 '1351590'   -- 결혼도움방  pgid :  pigwedding
				When a.company_seq =  2107  			Then  	 '2400121'   -- 마이e웨딩   pgid :studiomall -> dacom PG임 
				When a.company_seq =  2590				Then     '1351684'   --롯데백화점
				When a.sales_gubun = 'O' and c.jaehu_kind ='C'  	Then 	 '1490019'  -- 웨딩사이트  '1490019'   -- 웨딩사이트
				Else  c.erp_code	
			    End,
	------------------------------------------------------------------------------------------------------------------




	--**************************************************************************************************************
	--   * 과세유형
	--**************************************************************************************************************
	--         1. PG결제 업체중 LG 마이 e웨딩만 일반과세(10)고 나머진 매출 영수증(22)
	--         2. 후불결제 업체중 아래 4개 업체는 일반과세(10)고 나머진 매출 영수증(22) 
	--              	--팔방에프엔비          1300748
			--남산예술원              1495193
			--갤러리아웨딩홀식당 1495190
			--현대41컨벤션웨딩    1495184
			--마이e웨딩  2400121
              h_taxType	=  Case
				When   c.erp_code in ('1300748','1495193','1495190','1495184','2400121')  Then '10' 
				Else '22'
			    End,
	------------------------------------------------------------------------------------------------------------------

	



	--**************************************************************************************************************
	--* LG e웨딩의 경우 헤더금액을 결제금액의 90%로 조정함
	--**************************************************************************************************************
	h_offerPrice	=   Case
			     	When a.company_seq =  2107  Then Round(a.settle_price*0.9/1.1,0) 
				Else Round(a.settle_price/1.1,0) 
			     End,				
	h_superTax	=   Case
			     	When a.company_seq =  2107  Then Round((a.settle_price*0.9) - a.settle_price*0.9/1.1, 0)
				Else Round(a.settle_price- a.settle_price/1.1,0)
			     End,	
	h_sumPrice	=   Case
			     	When a.company_seq =  2107  Then Round(a.settle_price*0.9, 0)
				Else a.settle_price
			     End,	

	h_partCode	= '360',				
	h_staffcode	= '030801',    --원덕규				
	h_sonik		= '110',
	h_cost		= '129',
	h_orderid	= a.pg_tid,
	h_memo1	= null,
	h_memo2	= a.pg_tid,
	h_memo3	= null,
	b_biz		= 'BK10',
	b_goodGubun	= 'SO',
	b_seq		= 1,
	b_storeCode	= 'MF03',
	b_date		= Convert(char(8),a.delivery_date,112),
	b_goodCode	= d.card_code, --b.item_type
	b_goodUnit	= 'EA',
	b_OrderNum	= b.order_count,
	------------------------------------------------------------------------------------------------------------------


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


	--**************************************************************************************************************
	--   * PG체크
	--**************************************************************************************************************
	--         1. 마이 e웨딩을 제외한 PG결제 업체는 'Y' 나머진 'N'
	PGCheck	=  Case
				When a.company_seq in (532,553,587,1186,1272,2590)  Then 'Y'
				When a.sales_gubun = 'O' and c.jaehu_kind ='C'  Then 'Y'  -- 웨딩사이트
				Else 'N'	
			    End,
	------------------------------------------------------------------------------------------------------------------


	PayAmnt		= 0,
	SampleCheck	= 'N',
	XartCheck	= 'N',
	SettleDate	= null,
	PayDate		= null,
	PayCheck	= null,
	DealAmnt	= null,
	b_memo_temp	= null,
	DeptGubun	= 'WE'
FROM 
	custom_etc_order a JOIN custom_etc_order_item b ON a.order_seq = b.order_seq
	JOIN company c ON a.company_seq = c.company_seq
	JOIN card d ON b.card_seq = d.card_seq
	
	LEFT JOIN  OPENQUERY([erpdb.bhandscard.com], 'SELECT  IsNull(stdPurprice,0) as stdPurprice, IsNull(c_sobi,0) as c_sobi,itemcode,itemgroup FROM XERP.DBO.itemSiteMaster ') e ON d.card_code = e.itemCode

WHERE 
Convert(char(8),a.delivery_date,112) between @SDate and @EDate
and  a.status_seq = 12 
and a.order_type in ('F','P')
and 
(
	c.company_seq= 2590--in (532,553,587,1186,2107,2590)  --삼성카드 임직원, 삼성카드회원,결사모,결혼도움방, 마이e웨딩
	--or
	--a.sales_gubun = 'O' and c.jaehu_kind ='C'  and c.company_seq <> 15 -- 일단 웨딩사이트만 올림, 후불결제(ecSupport)는 추후에..
)
--and a.src_erp_date is null  
ORDER BY a.order_seq 





--**************************************************************************************************************
--   * 할인율에 맞추어 각 아이템 금액 재계산  	--LG e웨딩은 결제금액의 90%만 매출로 잡음
--**************************************************************************************************************
UPDATE @erp_salesReport 
SET 

	h_optionPrice = a.option_sumPrice ,
	DiscountRate  = a.discountRate,
 
	
	b_sumPrice    =	Case 
				When b.b_goodCode in ('TBB','JAEBON','PANBI','EMBO','ENVINSERT','QICKDELIVERY') Then b.b_sumPrice
				Else Round((b.b_sumPrice * (100-a.DiscountRate)/100)/1.1,0) + Round((b.b_sumPrice * (100-a.DiscountRate)/100)  - ((b.b_sumPrice * (100-a.DiscountRate)/100)/1.1),0)
				
			
			End,

 	b_offerPrice    = Case 
				When b.b_goodCode in ('TBB','JAEBON','PANBI','EMBO','ENVINSERT','QICKDELIVERY') Then Round(b.b_sumPrice/1.1,0)
				Else Round((b.b_sumPrice * (100-a.DiscountRate)/100)/1.1,0)
		            End,


 	b_superTax    = Case 
				When b.b_goodCode in ('TBB','JAEBON','PANBI','EMBO','ENVINSERT','QICKDELIVERY') Then Round(b.b_sumPrice - b.b_sumPrice/1.1,0)
				Else  Round((b.b_sumPrice * (100-a.DiscountRate)/100)  - ((b.b_sumPrice * (100-a.DiscountRate)/100)/1.1),0)
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
	JOIN 	(
		SELECT h_orderid, sum(b_offerprice) as b_offerPrice,sum(b_superTax) as b_superTax,sum(b_sumprice) as b_sumPrice 
		FROM @erp_salesReport 
		GROUP BY h_orderid
	              ) b --아이템 합계 금액 
		ON a.h_orderid = b.h_orderid	
	LEFT JOIN (
		SELECT h_orderid,  sum(b_sumprice)  as option_sumPrice 
		FROM @erp_salesReport
		WHERE b_goodCode  in ('TBB','JAEBON','PANBI','EMBO','ENVINSERT','QICKDELIVERY') 
		GROUP BY h_orderid
	              ) c --옵션비용  합계 금액
	 	ON a.h_orderid = c.h_orderid	
	
	) a  ON a.h_orderid = b.h_orderid	
WHERE b.SampleCheck = 'N'




--**************************************************************************************************************
--b_seq를 생성해 내기 위한 Temp 테이블 생성
--**************************************************************************************************************
SELECT  IDENTITY(int, 1, 1) AS seq, h_OrderID, b_goodCode,b_sumPrice
INTO #TempSEQ
FROM @erp_salesReport   
ORDER BY h_Orderid ASC, b_sumPrice DESC


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



--**************************************************************************************************************
--헤더 금액 update (아이템 금액의 합계로 Update)
--**************************************************************************************************************
--UPDATE @erp_salesReport 
--SET h_offerprice = b.b_offerPrice, h_superTax = b.b_superTax
--FROM @erp_salesReport  a 
--JOIN (SELECT h_orderid, sum(b_offerprice) as b_offerPrice,sum(b_superTax) as b_superTax,sum(b_sumprice) as b_sumPrice FROM @erp_salesReport GROUP BY h_orderid) b
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
-- FROM @erp_salesReport  a 
-- JOIN 	(	SELECT h_orderid,sum(b_sumPrice) as b_sumPrice FROM @erp_salesReport
-- 		GROUP BY h_orderid
-- 	) b ON a.h_orderid = b.h_orderid




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
					DeptGubun

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
	a.DeptGubun
FROM @erp_salesReport  a JOIN (
				SELECT  A.h_OrderID, A.b_goodCode  , A.seq - B.MinSeq + 1 AS b_seq
				FROM #TempSEQ  A JOIN (
							 SELECT h_OrderID, MIN(seq) AS MinSeq
							 FROM #TempSEQ
							 GROUP BY h_Orderid
							) B ON A.h_OrderID = B.h_OrderID
			         ) b ON a.h_orderid = b.h_orderid and a.b_goodCode = b.b_goodCode
			   --erp_SalesData에 중복 입력 오류 방지		
			     LEFT JOIN OPENQUERY([erpdb.bhandscard.com], 'SELECT DISTINCT h_orderid FROM XERP.DBO.erp_salesData ')  c ON a.h_orderid = c.h_orderid	
WHERE c.h_orderid is null




--**************************************************************************************************************
-- --ERP 업데이트 되었음을 표시함
--**************************************************************************************************************
--청청장 업데이트
UPDATE custom_order
SET src_erp_date = Convert(char(10),getdate(),120)
FROM custom_order a JOIN company c ON a.company_seq = c.company_seq
WHERE 	status_seq = 15 
	and  Convert(char(8),src_send_date,112) between @SDate and @EDate
	and pay_type <> '4' 
	and pg_shopid ='tiaracard1'
	and src_erp_date is null  
	and 
	(
	c.company_seq =2590--in (532,553,587,1186,2107,2590)  --삼성카드 임직원, 삼성카드회원,결사모,결혼도움방, 마이e웨딩
	--or
	--a.sales_gubun = 'O' and c.jaehu_kind ='C'  and c.company_seq <> 15 -- 일단 웨딩사이트만 올림, 후불결제(ecSupport)는 추후에..
	)



--샘플업데이트
UPDATE custom_sample_order
SET src_erp_date = Convert(char(10),getdate(),120)
FROM custom_sample_order a JOIN company c ON a.company_seq = c.company_seq
WHERE  status_seq = 12 
	and  Convert(char(8),delivery_Date,112) between @SDate and @EDate
	and src_erp_date is null  
	and 
	(
	c.company_seq =2590--in (532,553,587,1186,2107,2590)  --삼성카드 임직원, 삼성카드회원,결사모,결혼도움방, 마이e웨딩
	--or
	--a.sales_gubun = 'O' and c.jaehu_kind ='C'  and c.company_seq <> 15 -- 일단 웨딩사이트만 올림, 후불결제(ecSupport)는 추후에..
	)


--기타업데이트 
UPDATE custom_etc_order
SET src_erp_date = Convert(char(10),getdate(),120)
FROM custom_etc_order a JOIN company c ON a.company_seq = c.company_seq
WHERE 	Convert(char(8),a.delivery_date,112) between @SDate and @EDate
		and  a.status_seq = 12 
		and a.order_type in ('F','P')
		and 
		(
			c.company_seq =2590-- in (532,553,587,1186,2107,2590)  --삼성카드 임직원, 삼성카드회원,결사모,결혼도움방, 마이e웨딩
			--or
			--a.sales_gubun = 'O' and c.jaehu_kind ='C'  and c.company_seq <> 15 -- 일단 웨딩사이트만 올림, 후불결제(ecSupport)는 추후에..
		)
GO
