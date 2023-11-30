IF OBJECT_ID (N'dbo.sp_ERP_Transfer', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_ERP_Transfer
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






--exec sp_ERP_TRANSFER '20080425','20080425'


CREATE                 procedure [dbo].[sp_ERP_Transfer]
 @SDate as char(8),
 @EDate as char(8)
as

set nocount on


--자료 Reporting을 위한 임시 테이블 생성      
Declare @Report  Table  (      
	 pg_tid     nvarchar(100)  NOT NULL ,      
	 company_name     nvarchar(50)  NULL ,      
	 sales_gubun  char(2) NULL,      
	 h_comcode  nchar(50) NULL,      	
	 erp_partCode  nchar(50) NULL,      
	 erp_staffCode  nchar(50) NULL,      
	 erp_costCode  nchar(50) NULL,      	
	 erp_TaxType nvarchar(50) NULL,      
	 src_send_date smalldatetime NULL,      
	 settle_price  numeric(28,8) NULL,      
	 pg_fee     nvarchar(50)  NULL ,      
	 ERP_pgcheck     nvarchar(50)  NULL ,      
	 item_type     nvarchar(50)  NULL ,      
	 syscode     nvarchar(50)  NULL ,      --SysCase
	 usrCode     nvarchar(50)  NULL ,      --CaseCode
	 item_count     int  NULL ,      
	 item_Price      numeric(28,8)  NULL ,      
	 item_sale_price    numeric(28,8)  NULL ,      
	 discount_rate     numeric(28,8)  NULL ,      
	 card_price      numeric(28,8)  NULL ,      
	 card_src_price     numeric(28,8)  NULL ,      
	 card_branch_price      numeric(28,8)  NULL ,      
	 card_online_branch_price      numeric(28,8)  NULL ,      
	 itemCode     nvarchar(50)  NULL ,       
	 itemName  nvarchar(100) null,  
	 erp_daeri nvarchar(50) null,  
	 erp_sobi numeric(28,8) null, 
	erp_chool  numeric(28,8)  null,
	order_total_price  numeric(28,8) null, 
	option_total_price numeric(28,8) null, 
	prod_price  numeric(28,8) null, 
	dis_rate  numeric(28,8) null, 
	xartcheck nvarchar(50) null,
	ERP_Price  numeric(28,8) null   	
	 )    


INSERT INTO @Report ( pg_tid, company_name, sales_gubun,erp_partCode, erp_staffCode,erp_costCode, h_comcode , erp_TaxType,src_send_date, settle_price, pg_fee, ERP_pgcheck, item_type,  
	 syscode, usrCode,      
	 item_count,  item_Price, item_sale_price, discount_rate, card_price, card_src_price, card_branch_price, card_online_branch_price, itemCode ,       
	 itemName, erp_daeri , erp_sobi,erp_chool, order_total_price, option_total_price,	prod_price,dis_rate, xartcheck)
SELECT 
	
	--주문번호
	pg_tid = Case  
		   When b.company_seq in (232,1137,1250) Then --디지털플라자, 워커힐, G마켓 (후불결제)
			Case 
				When (c.item_Type ='F'  and item_sale_price > 0 )         --후불결제 업체라도 식권, 엠보인쇄 등 옵션이나 추가주문건은 PG를 타서 결제함 (주문번호 앞에 'IC' 붙힘)
					or (a.up_order_seq is not null and a.settle_price > 0) 
					or ( item_type in ('TBB','PANBI','JAEBON','EMBO','EnvInsert','QICKDELIVERY') 
					and a.settle_price > 0) Then 'IC'+Cast(a.order_seq as nvarchar(50))
				Else 'D'+Cast(a.order_seq as nvarchar(50))  --후불건에 대해서는 주문번호 앞에 'D' 붙힘
			End
		     Else
		              'IC'+Cast(a.order_seq as nvarchar(50))
		End,
	--매출처명
	h_company_name = Case  
				   When b.company_seq in (232,1137,1250) Then --디지털플라자, 워커힐, G마켓 (후불결제)
					Case
						When (c.item_Type ='F'  and item_sale_price > 0 ) 
							or (a.up_order_seq is not null and a.settle_price > 0) 
							or ( item_type in ('TBB','PANBI','JAEBON','EMBO','EnvInsert','QICKDELIVERY') 
							and a.settle_price > 0) Then 'BA_제휴사(' +company_name+ ')'  --BA_제휴
						Else company_name
					End
				     Else
					Case 
						When a.sales_gubun = 'B' Then  -- 김성동 제휴
							Case
								When (a.company_seq = 3) or (a.company_seq = 724)  Then b.erp_code  --엘지이샵하고 뷰티클래스는 해당 업체 코드를 가져온다.
								Else  'BA_제휴사(' +company_name+ ')'  --BA_제휴
							End					
						Else company_name
					End 		             
	
			   End,
	sales_gubun = b.sales_gubun,		


	-- 매출부서 코드
	erp_partCode = b.erp_partCode,


	-- 매출 책임자 코드
	erp_staffCode = b.erp_staffCode,

	-- 코스트 센터 코드	
	erp_costCode = b.erp_CostCode,

	--매출처 ERP 코드
	h_comcode = 	Case  
			   When b.company_seq in (232,1137,1250) Then --디지털플라자, 워커힐, G마켓 (후불결제)
				Case
					When (c.item_Type ='F'  and item_sale_price > 0 ) 
						or (a.up_order_seq is not null and a.settle_price > 0) 
						or ( item_type in ('TBB','PANBI','JAEBON','EMBO','EnvInsert','QICKDELIVERY') 
						and a.settle_price > 0) Then '1489998'  --BA_제휴
					Else b.erp_code	
				End
			     Else
				Case 
					When a.sales_gubun = 'B' Then  -- 김성동 제휴
						Case
							When (a.company_seq = 3) or (a.company_seq = 724)  Then b.erp_code  --엘지이샵하고 뷰티클래스는 해당 업체 코드를 가져온다.
							Else '1489998' --BA_제휴
						End					
					Else b.erp_code		
				End 		             
			End,


	--과세유형
	erp_TaxType = Case  
			   When b.company_seq in (232,1137,1250) Then  --디지털플라자, 워커힐, G마켓 (후불결제)
				Case
					When (c.item_Type ='F'  and item_sale_price > 0 ) 
						or (a.up_order_seq is not null and a.settle_price > 0) 
						or ( item_type in ('TBB','PANBI','JAEBON','EMBO','EnvInsert','QICKDELIVERY') 
						and a.settle_price > 0) Then '22'  --후불결제 업체라도 식권, 엠보인쇄 등 옵션이나 추가주문건은 PG를 타서 과세유형이 매출영수증임					Else  b.erp_TaxType	
					Else '22'					
				End
			     Else
			               b.erp_TaxType	
			End,


	a.src_send_date, 
	settle_price  = 	Case  
			   When b.company_seq in (232,1137,1250) Then
				Case
					When (c.item_Type ='F'  and item_sale_price > 0 ) or (a.up_order_seq is not null and a.settle_price > 0) or ( item_type in ('TBB','PANBI','JAEBON','EMBO','EnvInsert','QICKDELIVERY') and a.settle_price > 0) Then  a.settle_price
					Else a.order_total_price
				End
			     Else
			              a.last_total_price
			End,




	-- pgFee getPGFee 함수 호출 (pg아이디, 결제수단, 결제금액, 카드사정보)
	pgfee = 	dbo.getPGFee (a.pg_shopid, a.settle_method, a.settle_price,  Case
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
									             End		
				),
		
	  /*	
	       erp_pgCheck 는 기본적으로 Company에 erp_pgcheck라고 셋팅된 값을 가져오게 되어 있다. (업체별로 pgCheck여부 셋팅됨)
	       하지만 pgCheck가 'N'으로 된 업체의 경우도 추가주문 or 옵션 주문이 pg결제 처리 되어 pgCheck가 'Y'로 셋팅되어야할 건들이 있다.
                     그걸 여기서 update시켜줌  	 
              */
	ERP_Pgcheck =  Case  
			   When b.company_seq in (232,1137,1250) Then  --디지털플라자, 워커힐, G마켓 (후불결제)
				Case
					When (c.item_Type ='F'  and item_sale_price > 0 ) 
						or (a.up_order_seq is not null and a.settle_price > 0) 
						or ( item_type in ('TBB','PANBI','JAEBON','EMBO','EnvInsert','QICKDELIVERY') 
						and a.settle_price > 0) Then 'Y'  --후불결제 업체라도 식권, 엠보인쇄 등 옵션이나 추가주문건은 PG를 타서 pgchek가 'Y'				
					Else  b.ERP_Pgcheck
				End
			     Else
			            b.ERP_Pgcheck
			End,
	c.item_type, 
	syscode = Case 
			When c.item_Type ='C'                                           Then '270'    --카드는 정상출고
			When c.item_Type ='E'                                           Then '270'    --봉투도 정상출고
			When c.item_Type ='I'                                            Then '270'    --봉투도 정상출고
			When c.item_Type ='A'                                           Then '270'    --악세사리도 정상출고
			When c.item_Type ='F'  and item_sale_price > 0    Then '270'     -- 식권은 매출 금액이 있으면 정상출고(270), 무료이면 무료제공품(300),
			When c.item_Type ='F'  and item_sale_price <= 0  Then '300'     -- 식권은 매출 금액이 있으면 정상출고(270), 무료이면 무료제공품(300),
			When c.item_Type ='S'  and item_sale_price > 0   Then '270'    --유료스티커
			When c.item_Type ='S'  and item_sale_price <= 0  Then '300'    --무료스티커
			When c.item_Type ='L'        		        Then '300'    --사은품
			When c.item_Type ='M'  and item_sale_price > 0   Then '270'   --유료미니청첩장
			When c.item_Type ='M'  and item_sale_price <= 0  Then '300'   --무료미니청첩장
			When c.item_type = 'TBB'     		         Then '270'  --서비스매출품목군 (출고없음)
			When c.item_type = 'JAEBON'                                 Then '270'  --서비스매출품목군 (출고없음)
			When c.item_type = 'PANBI'                                    Then '270'
			--When c.item_type = 'STICKER'                                Then '270' --스티커는 item_sale_item에 들어감
			When c.item_type = 'EMBO'                                    Then '270'
			When c.item_type = 'ENVINSERT'                            Then '270'
			When c.item_type = 'QICKDELIVERY'		         Then '270'	
		   End,
	usrCode = Case 
			When c.item_Type ='C'                                          Then '270'   --카드는 정상출고
			When c.item_Type ='E'                                          Then '270'   --봉투도 정상출고
			When c.item_Type ='I'                                           Then '270'    --봉투도 정상출고
			When c.item_Type ='A'                                          Then '270'   --악세사리도 정상출고
			When c.item_Type ='F'  and item_sale_price > 0   Then '270'     -- 식권은 매출 금액이 있으면 정상출고(270), 무료이면 무료제공품(300),
			When c.item_Type ='F'  and item_sale_price <= 0 Then '302'   -- 식권은 매출 금액이 있으면 정상출고(270), 무료이면 무료제공품(300),
			When c.item_Type ='S'  and item_sale_price > 0   Then '270'    --유료스티커
			When c.item_Type ='S'  and item_sale_price <= 0  Then '302'    --무료스티커
			When c.item_Type ='L'        		        Then '302'  --사은품
			When c.item_Type ='M'  and item_sale_price > 0   Then '270'   --유료미니청첩장
			When c.item_Type ='M'  and item_sale_price <= 0  Then '302'   --무료미니청첩장
			When c.item_type = 'TBB'     		         Then '270'
			When c.item_type = 'JAEBON'                                 Then '270'
			When c.item_type = 'PANBI'                                    Then '270'
			--When c.item_type = 'STICKER'                               Then '270'
			When c.item_type = 'EMBO'                                    Then '270'
			When c.item_type = 'ENVINSERT'                            Then '270'
			When c.item_type = 'QICKDELIVERY'		         Then '270'	
		   End, 	
	c.item_count, c.item_price, c.item_sale_price, c.discount_rate,
	d.card_price,d.card_src_price, d.card_branch_price, d.card_online_branch_price  , 
	itemCode = Case
			When c.item_type = 'TBB'             	   Then 'TBB'
			When c.item_type = 'JAEBON'       	   Then 'JAEBON'
			When c.item_type = 'PANBI'          	   Then 'PANBI'
			When c.item_type = 'STICKER'      	   Then 'STICKER'
			When c.item_type = 'EMBO'          	   Then 'EMBO'
			When c.item_type = 'ENVINSERT'  	   Then 'ENVINSERT'
			When c.item_type = 'MINI'             	   Then 'MINI'
			When c.item_type = 'QICKDELIVERY'   Then 'QICKDELIVERY'	
			Else e.itemCode
		    End	,
	--e.itemCode,
	e.itemName,e.erp_daeri, 
	erp_sobi = Case 
			When c.item_type = 'TBB'             	  Then   IsNull(item_price,0)
			When c.item_type = 'JAEBON'         	  Then IsNull(item_price,0)
			When c.item_type = 'PANBI'          	  Then   IsNull(item_price,0)
			When c.item_type = 'EMBO'          	  Then   IsNull(item_price,0)
			When c.item_type = 'ENVINSERT'  	  Then   IsNull(item_price,0)
			When c.item_type = 'QICKDELIVERY'  Then   IsNull(30000,0)     -- 빠른배송 3만원
			Else IsNull(erp_sobi,0)
	      	  End 	
	, e.erp_chool ,
	order_total_price  = 	Case  
				   When b.company_seq in (232,1137,1250) Then
					Case
						When  (a.up_order_seq is not null and a.settle_price > 0) or ( item_type in ('TBB','PANBI','JAEBON','EMBO','EnvInsert', 'ENVINSERT') and a.settle_price > 0) Then  a.settle_price
						When (c.item_Type ='F'  and item_sale_price > 0 ) Then erp_sobi * item_count
						Else f.order_total_price
					End
				     Else
				              f.order_total_price
				End,



	--f.order_total_price,  -- = 제품의 총합
	f.option_total_price, -- = 옵션의 총합

	prod_price = Case
 			When  b.company_seq in (232,1137,1250) Then a.order_total_price 
			Else (a.settle_price - f.option_total_price)  -- = (결제금액 - 옵션의 총합) 
  		       End, 							
			                   
	--할인율 
 	disRate = Case 
 			When f.order_total_price = '0' Then  '0'
 			--Else (100-Round(100-((a.settle_price - f.option_total_price)/IsNull(f.order_total_price- f.option_total_price,1))*100,3))/100
			Else 
			    Case 
			           When  b.company_seq in (232,1137,1250) Then (100-Round(100-((a.order_total_price - f.option_total_price)/IsNull(f.order_total_price,1))*100,3))/100	
			            Else  (100-Round(100-((a.settle_price - f.option_total_price)/IsNull(f.order_total_price,1))*100,3))/100	
                                               End
 		  End, 	

	XartCheck = Case
		       	When a.company_seq = '224' Then 'Y'
			Else 'N'
		       End
FROM 
Custom_Order A JOIN Company B 
ON a.Company_seq = b.Company_seq

-- 택배비, 제본비, 추가판비, 엠보, 봉투삽입 등의 옵션을 JOIN하기 위해서..
-- 옵션수량은 1로 넘겨도 됨 (재고 관리를 안하기 때문에.. 이부장님 말씀.. 2008
JOIN      (select order_seq, card_seq, item_type, item_count, item_price, item_sale_price, discount_rate
	from 
		(select b.order_seq, b.card_seq,b.item_type,b.item_count, b.item_price, b.item_sale_price, b.discount_rate  
		from custom_order a join  custom_order_item b 
		on a.order_seq = b.order_seq
		where Convert(char(8),a.src_send_date,112) between @SDate and @EDate) C
	union   
		--택배비
		(select order_seq, card_seq, 'TBB', 1, 3500,delivery_price,0
		from Custom_Order 
		where Convert(char(8),src_send_date,112) between @SDate and @EDate and  delivery_price > 0)  

	union   
		--제본
		(select order_seq, card_seq, 'JAEBON',  order_count, 50,JEBON_price,0
		from Custom_Order 
		where Convert(char(8),src_send_date,112) between @SDate and @EDate and  JEBON_price > 0)  

	union
		--추가판비   
		(select order_seq, card_seq, 'PANBI', 1, 5000,option_price,0
		from Custom_Order 
		where Convert(char(8),src_send_date,112) between @SDate and @EDate and  option_price > 0)  

	union
		--엠보   
		(select order_seq, card_seq, 'EMBO',order_count, 60, embo_price,0
		from Custom_Order 
		where Convert(char(8),src_send_date,112) between @SDate and @EDate and  embo_price > 0)  
	union   
		--봉투삽입
		(select order_seq, card_seq, 'ENVINSERT',order_count, 80, envInsert_price,0
		from Custom_Order 
		where Convert(char(8),src_send_date,112) between @SDate and @EDate and  envInsert_price > 0)  
	
	union
		--초특급 배송(custom_order.isSpecial='1' 그리고, custom_order.delivery_price=30000)
		(select order_seq, card_seq, 'QICKDELIVERY',order_count, 30000, delivery_price,0
		from Custom_Order 
		where Convert(char(8),src_send_date,112) between @SDate and @EDate and  isSpecial='1')  		
	) C

ON a.order_seq  = c.order_seq

Join Card D
ON c.card_seq = d.Card_seq


Join erp_price E   -- 주기적으로 업데이트 시켜야 하는 테이블 (ERP에 있는 정보 update)
ON d.Card_code = E.itemCode 


Join (
        
        select  a.order_seq, order_total_price = IsNull(Sum(  --무료 미니청첩장의 경우 제품의 합계금액에 포함시키지 않는다.
					Case
	           				      When  item_sale_price <= 0  Then
						0
					       Else
						item_count*erp_sobi	
                       		                              End	
					),0),
	Case
		When isSpecial ='1' Then
			  (IsNull(delivery_price,0)  -- 배송비
			+ IsNull(jebon_price,0)  --제본비
			+ IsNull(option_price,0)  --제본비
			+ IsNull(embo_price,0)       --엠보인쇄
			+ IsNull(envinsert_price,0) --봉투삽입
			+ 30000)
		Else 
			  (IsNull(delivery_price,0)  -- 배송비
			+ IsNull(jebon_price,0)  --제본비
			+ IsNull(option_price,0)  --제본비
			+ IsNull(embo_price,0)       --엠보인쇄
			+ IsNull(envinsert_price,0)) --봉투삽입
	End
	as option_total_price	  

         from custom_order a Join custom_order_item b 
         on a.order_seq = b.order_seq 
         Join card c on b.card_seq = c.card_seq
         Join erp_price d on c.card_code = d.itemCode

         where a.status_seq = 15 
		and Convert(char(8),a.src_send_date,112) between  @SDate and  @EDate
		and pay_type <> '4'  
		--and settle_price > 0
         group by a.order_seq,a.settle_price,delivery_price, jebon_price, option_price, embo_price, envinsert_price,isSpecial



       ) F

ON a.order_seq = f.order_seq


WHERE a.status_seq = 15   --결제상태가 배송완료인것
and Convert(char(8),a.src_send_date,112) between @SDate and @EDate 
and a.pay_type <> '4'  --pay_type가 4는 결제 취소
and (b.erp_dept = '2' or (b.company_Seq = 237 and a.sales_gubun ='D' and d.company = 8))    --erp_dept 가 2는 영업 2본부, 참카드에서 판매 되는 해피카드는 영업2본부 매출로 올림
--and a.src_erp_date is null 
ORDER BY a.order_seq 




--########################################################################################
--기초데이터에서 필요한 데이터 Update
--########################################################################################
UPDATE @Report
	SET  ERP_Price =  Case   --ERP로 넘기는 매출 금액
			  When SysCode = 300 Then
				0 
	           	                Else
				Case  --옵션은 기본 금액 그대로 넘기고
				     When  ItemCode ='PANBI'           Then Item_Sale_Price
				     When  ItemCode ='TBB'              Then Item_Sale_Price   	
				     When  ItemCode ='EMBO'           Then Item_Sale_Price
				     When  ItemCode ='JAEBON'        Then Item_Sale_Price
				     When  ItemCode ='ENVINSERT'   Then Item_Sale_Price	
				     When  ItemCode ='QICKDELIVERY'   Then 30000		
				     Else
					Case
					     When dis_Rate = 0 Then Round((Item_Count*erp_sobi) ,2)
					     Else Round((Item_Count*erp_sobi) * dis_Rate,2) -- 옵션 제외한 제품은 할인율을 적용하여 금액을 올림
		          	   		     End
				  End 
			  End,
	         order_total_price = up_order_total_price,
	        /*	
	       erp_pgCheck 는 기본적으로 Company에 erp_pgcheck라고 셋팅된 값을 가져오게 되어 있다. (업체별로 pgCheck여부 셋팅됨)
	       하지만 pgCheck가 'N'으로 된 업체의 경우도 추가주문 or 옵션 주문이 pg결제 처리 되어 pgCheck가 'Y'로 셋팅되어야할 건들이 있다.
                     그걸 여기서 update시켜줌  	 
                     */
-- 	         ERP_pgCheck = Case
-- 				When Left(a.pg_tid,1) = 'D' Then 'N'
-- 				Else 'Y'
-- 	                                   End,	
	         pg_fee  =  Case
		      	    When Left(a.pg_tid,1) = 'D' Then 0
			    When ERP_Pgcheck  = 'N' Then 0
			    Else Round(pg_fee,0)
	                          End

FROM @Report a Join (Select pg_tid, sum(
					Case
	           				      When  item_sale_price <= 0  Then
						0
					       Else
						item_count*erp_sobi	
                       		                              End	
				        ) as up_order_total_price From @Report Group By pg_tid) b 
on a.pg_tid = b.pg_tid




--########################################################################################
--중간테이블로 넘기기 위한 정보 Report
--########################################################################################
select *, 
	Dis_Rate2 =   Case 
		           When  h_comcode in ('1489999','1100373','1400019')  Then (100-Round(100-((prod_price)/IsNull(order_total_price,1))*100,3))/100	
		            Else  dis_Rate
                                  End,
	erp_price = Case
		            When  h_comcode in ('1489999','1100373','1400019')  Then 
				Case 
					When  SysCode = 300 Then  0 
					Else Round((Item_Count*erp_sobi) * (100-Round(100-((prod_price)/IsNull(order_total_price,1))*100,3))/100,2)
				End
		            Else  erp_price		
		     End,
	(settle_price-total_erp_price) as diff
	from @Report a Join (select pg_tid, total_erp_price =  Sum(Case 
							     	When  h_comcode in ('1489999','1100373','1400019')  Then  
									Case 
										When  SysCode = 300 Then  0 
										Else Round((Item_Count*erp_sobi) * (100-Round(100-((prod_price)/IsNull(order_total_price,1))*100,3))/100,2)
									End
							     	Else erp_price
						             	        End)  	
			       from @Report group by pg_tid) b 

on a.pg_tid = b.pg_tid








GO
