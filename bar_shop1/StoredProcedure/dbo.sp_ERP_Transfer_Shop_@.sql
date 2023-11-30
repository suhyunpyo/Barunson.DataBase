IF OBJECT_ID (N'dbo.sp_ERP_Transfer_Shop_@', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_ERP_Transfer_Shop_@
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[sp_ERP_Transfer_Shop_@]
 @SDate as char(8),
 @EDate as char(8)

AS
SET NOCOUNT ON


DECLARE @Syscode1 as char(3),@UsrCode1 as char(3) --정상출고 (270,270)
	Set @SysCode1 = '270'
	Set @UsrCode1 = '270'

DECLARE @Syscode2 as char(3),@UsrCode2 as char(3) --예외출고 (300,300)
	Set @SysCode2 = '300'
	Set @UsrCode2 = '322'


DECLARE @Syscode3 as char(3),@UsrCode3 as char(3) --샘플출고 (300,308)
	Set @SysCode3 = '300'
	Set @UsrCode3 = '308'




--자료 Reporting을 위한 테이블 변수 생성      
Declare @erp_salesReport  Table  (      
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
									DeptGubun	char(2) 			NOT NULL,
									DiscountRate	numeric(28, 8) 	NULL
								 )    
     

----**************************************************************************************************************
----1.청첩장
----**************************************************************************************************************
	--INSERT INTO @erp_salesReport ( 	h_biz,
	--				h_gubun,
	--				h_date,
	--				h_sysCode,
	--				h_usrCode,
	--				h_comcode,
	--				h_taxType,
	--				h_offerPrice,
	--				h_superTax,
	--				h_sumPrice,
	--				h_optionPrice,
	--				h_partCode,
	--				h_staffcode,
	--				h_sonik,
	--				h_cost,
	--				h_orderid,
	--				h_memo1,
	--				h_memo2,
	--				h_memo3,
	--				b_biz,
	--				b_goodGubun,
	--				b_seq,
	--				b_storeCode,
	--				b_date,
	--				b_goodCode,
	--				b_goodUnit,
	--				b_OrderNum,
	--				b_unitPrice,
	--				b_offerPrice,
	--				b_superTax,
	--				b_sumPrice,
	--				b_memo,
	--				reg_date,
	--				FeeAmnt,
	--				ItemGubun,
	--				PGCheck,
	--				PayAmnt,
	--				SampleCheck,
	--				XartCheck,
	--				SettleDate,
	--				PayDate,
	--				PayCheck,
	--				DealAmnt,
	--				b_memo_temp,
	--				DeptGubun
	--			)
	SELECT 
		h_biz		= 'BK10',
		h_gubun		= 'SO',
		h_date		= Convert(char(8),a.src_send_date,112),

		--** 결제금액이 있는것은 모든 아이템에 대하여 정상출고로 출고시킨다. 추후 ERP가 아이템별 출고 유형을 달리 할 수 있도록 수정하면 여기도 수정해 줘야 함
		h_sysCode	= Case 
						When b.item_Type = 'C'                                           	Then @SysCode1     -- 카드는 정상출고
						When b.item_Type = 'E'  and b.card_code <> 'BE029'                 	Then @SysCode1     -- 일반봉투 정상출고
						When b.item_Type = 'E'  and b.card_code = 'BE029'                  	Then @SysCode2     -- 미니봉투 예외출고
						When b.item_Type = 'I'                                            	Then @SysCode1     -- 내지 정상출고
						When b.item_Type = 'A'                                           	Then @SysCode1     -- 악세사리 정상출고
						When b.item_Type = 'R'                                           	Then @SysCode1     -- 리본
						When b.item_Type = 'B'                                           	Then @SysCode1     -- 라벨지
						When b.item_Type = 'P'                                           	Then @SysCode1     -- 추가내지(내지 2장 있는 카드)
						When b.item_Type = 'F'  and item_price <> 0    						Then @SysCode1     -- 식권은 매출 금액이 있으면 정상출고(270), 무료이면 무료제공품(300),
						When b.item_Type = 'F'  and item_price = 0  						Then @SysCode2     -- 식권은 매출 금액이 있으면 정상출고(270), 무료이면 무료제공품(300),
						When b.item_Type = 'S'  and item_price <> 0   						Then @SysCode1     -- 유료스티커
						When b.item_Type = 'S'  and item_price = 0  						Then @SysCode2     -- 무료스티커
						When b.item_Type = 'L'        		        						Then @SysCode2     -- 스크랩북
						When b.item_Type = 'V'        		        						Then @SysCode2     -- 사은품
						When b.item_Type = 'M'  and item_price <> 0   						Then @SysCode1     -- 유료미니청첩장
						When b.item_Type = 'M'  and item_price = 0							Then @SysCode2     -- 무료미니청첩장
						When b.item_Type = 'TBB'     		         						Then @SysCode1     -- 서비스매출품목군 (출고없음)
						When b.item_Type = 'JAEBON'                                 		Then @SysCode1     -- 서비스매출품목군 (출고없음)
						When b.item_Type = 'PANBI'                                    		Then @SysCode1	   -- 서비스매출품목군 (출고없음)	
						When b.item_Type = 'EMBO'                                    		Then @SysCode1	   -- 서비스매출품목군 (출고없음)
						When b.item_Type = 'ENVINSERT'                            			Then @SysCode1	   -- 서비스매출품목군 (출고없음)	
						When b.item_Type = 'QICKDELIVERY'									Then @SysCode1	   -- 서비스매출품목군 (출고없음)
						Else b.item_Type 
					End,
		
		h_usrCode	= Case 
						When b.item_Type = 'C'                                       		Then @UsrCode1     -- 카드는 정상출고
						When b.item_Type = 'E' and b.card_code <> 'BE029'                  	Then @UsrCode1     -- 일반봉투 정상출고
						When b.item_Type = 'E' and b.card_code = 'BE029'                  	Then @UsrCode2     -- 미니봉투 예외출고
						When b.item_Type = 'I'                                           	Then @UsrCode1     -- 봉투도 정상출고
						When b.item_Type = 'A'                                          	Then @UsrCode1     -- 악세사리도 정상출고
						When b.item_Type = 'R'                                           	Then @UsrCode1     -- 리본
						When b.item_Type = 'B'                                           	Then @UsrCode1     -- 라벨지
						When b.item_Type = 'P'                                           	Then @UsrCode1     -- 추가내지(내지 2장 있는 카드)
						When b.item_Type = 'F'  and item_price <> 0   						Then @UsrCode1     -- 식권은 매출 금액이 있으면 정상출고(270), 무료이면 무료제공품(300),
						When b.item_Type = 'F'  and item_price = 0 							Then @UsrCode2     -- 식권은 매출 금액이 있으면 정상출고(270), 무료이면 무료제공품(300),
						When b.item_Type = 'S'  and item_price <> 0   						Then @UsrCode1     -- 유료스티커
						When b.item_Type = 'S'  and item_price = 0  						Then @UsrCode2     -- 무료스티커
						When b.item_Type = 'L'        		        						Then @UsrCode2     -- 사은품
						When b.item_Type = 'V'        		        						Then @UsrCode2     -- 사은품
						When b.item_Type = 'M'  and item_price <> 0   						Then @UsrCode1     -- 유료미니청첩장
						When b.item_Type = 'M'  and item_price = 0  						Then @UsrCode2     -- 무료미니청첩장
						When b.item_Type = 'TBB'     		         						Then @UsrCode1
						When b.item_Type = 'JAEBON'                                 		Then @UsrCode1
						When b.item_Type = 'PANBI'                                    		Then @UsrCode1
						When b.item_Type = 'EMBO'                                    		Then @UsrCode1
						When b.item_Type = 'ENVINSERT'                            			Then @UsrCode1
						When b.item_Type = 'QICKDELIVERY'		         					Then @UsrCode1
						Else b.item_Type
					 End, 	

		--**************************************************************************************************************
		--   * 거래처코드 (company_seq로 구분)
		--**************************************************************************************************************
		--1. 후불결제 업체의 경우 정상주문건은 거래처가 후불결제 업체로 넘어가고 추가주문이나 옵션에 대한 것은 제휴코드로 넘어감
		h_comcode	=   Case
							When a.sales_gubun = 'W' Then '1450002'
							When a.sales_gubun = 'T' Then '1450005'
							When a.sales_gubun = 'U' Then '17577'
							When a.sales_gubun = 'S' Then '1450065'
							When a.sales_gubun = 'X' Then '1450003'
							When a.sales_gubun = 'G' Then '1450066'
							When a.sales_gubun = 'B' Then 
								Case
									When c.company_seq in (232,1137,1250,2235) Then --디지털플라자, 워커힐, G마켓 (후불결제), 전자랜드
										Case
											When (b.item_type = 'F' and b.item_price > 0) or (a.up_order_seq is not null and a.settle_price > 0) or  ( b.item_type in ('TBB','PANBI','JAEBON','EMBO','EnvInsert','QICKDELIVERY') and a.settle_price > 0) Then '1489998'
											When c.company_seq = 1250 Then '1400019'  --지마켓
											When c.company_seq = 2235 Then '1510052'  --전자랜드
											Else '1489998'
										End 
									Else '1489998'	
								End			
						End, 	
		------------------------------------------------------------------------------------------------------------------




		--**************************************************************************************************************
		--   * 과세유형
		--**************************************************************************************************************
		  h_taxType	=	Case
							When a.sales_gubun = 'W' Then '22'
							When a.sales_gubun = 'T' Then '22'
							When a.sales_gubun = 'U' Then '10'
							When a.sales_gubun = 'S' Then '22'
							When a.sales_gubun = 'X' Then '22'
							When a.sales_gubun = 'G' Then '22'
							When a.sales_gubun = 'B' Then 
								Case
									When c.company_seq in (2235) Then '10'  --전자랜드 일반과세
									Else '22'
								End	
						End, 					
		------------------------------------------------------------------------------------------------------------------




		--**************************************************************************************************************
		--* 헤더 결제금액
		--**************************************************************************************************************
		h_offerPrice	= Case
								When c.company_seq in (232,1137,1250,2235) Then --디지털플라자, 워커힐, G마켓 (후불결제), 전자랜드
									Case
										When (b.item_type = 'F' and b.item_price > 0) or (a.up_order_seq is not null and a.settle_price > 0) or  ( b.item_type in ('TBB','PANBI','JAEBON','EMBO','EnvInsert','QICKDELIVERY') and a.settle_price > 0) Then Round(a.settle_price/1.1,0)
										When c.company_seq = '1250' Then Round((a.Reduce_price*-1)/1.1,0)  --지마켓
										Else 75000
									End 
								Else Round(a.settle_price/1.1,0)
							End,
							
		h_superTax     =  Case 
							When c.company_seq in (232,1137,1250,2235) Then   --디지털플라자, 워커힐, G마켓 (후불결제), 전자랜드
								Case
									When (b.item_type = 'F' and b.item_price > 0) or (a.up_order_seq is not null and a.settle_price > 0) or  ( b.item_type in ('TBB','PANBI','JAEBON','EMBO','EnvInsert','QICKDELIVERY') and a.settle_price > 0) Then Round((a.settle_price - a.settle_price/1.1),0)
									When c.company_seq = '1250' Then Round((a.Reduce_price*-1)- (a.Reduce_price*-1)/1.1,0)  --지마켓
									Else 7500
								End
							Else Round((a.settle_price - a.settle_price/1.1),0)		
						  End, 				   
		h_sumPrice    =   Case 
							When c.company_seq in (232,1137,1250,2235) Then   --디지털플라자, 워커힐, G마켓 (후불결제), 전자랜드 
								Case 
									When (b.item_type = 'F' and b.item_price > 0) or (a.up_order_seq is not null and a.settle_price > 0) or  ( b.item_type in ('TBB','PANBI','JAEBON','EMBO','EnvInsert','QICKDELIVERY') and a.settle_price > 0) Then a.settle_price
									When c.company_seq = '1250' Then a.Reduce_price*-1  --지마켓
									Else 82500
								End
							Else a.settle_price		
						  End,     
						   	 
		--h_superTax		=  Round(a.settle_price- a.settle_price/1.1,0),
		--h_sumPrice		=  a.settle_price,
		h_optionPrice   =  0,
		----------------------------------------------------------------------------------------------------------------
		
		
		--**************************************************************************************************************
		--담당자 정보 및 기타 헤더 정보
		--**************************************************************************************************************
		h_partCode	=	Case 
		
							When a.sales_gubun = 'W' Then	'510'	--바른손카드
							When a.sales_gubun = 'T' Then	'380'	--더카드
							When a.sales_gubun = 'U' Then	'550'	--투유
							When a.sales_gubun = 'J' Then	'390'	--제휴
							When a.sales_gubun = 'B' Then	'390'	--제휴 
							--When a.sales_gubun = 'A' Then	'870'	--티아라
							When a.sales_gubun = 'S' Then	'450'	--스토리러브
							When a.sales_gubun = 'X' Then	'395'	--시즌
							When a.sales_gubun = 'G' Then	'890'	--아가
						End	,				
		h_staffcode	= Case 
		
							When a.sales_gubun = 'W' Then	'030603'	--김성동
							When a.sales_gubun = 'T' Then	'090501'	--기형석
							When a.sales_gubun = 'U' Then	'090501'	--기형석
							When a.sales_gubun = 'J' Then	'030603'	--김성동
							When a.sales_gubun = 'B' Then	'030603'	--김성동 
							--When a.sales_gubun = 'A' Then	'030603'	--티아라
							When a.sales_gubun = 'S' Then	'090501'	--기형석
							When a.sales_gubun = 'X' Then	'030603'	--김성동
							When a.sales_gubun = 'G' Then	'080401'	--배민영
						End	,   			
		h_sonik		= '110',
		h_cost		= Case 
		
							When a.sales_gubun = 'W' Then	'117'	
							When a.sales_gubun = 'T' Then	'143'	
							When a.sales_gubun = 'U' Then	'149'	--기형석
							When a.sales_gubun = 'J' Then	'148'	--김성동
							When a.sales_gubun = 'B' Then	'148'	--김성동 
							--When a.sales_gubun = 'A' Then	'152'	--티아라
							When a.sales_gubun = 'S' Then	'163'	--기형석
							When a.sales_gubun = 'X' Then	'153'	--김성동
							When a.sales_gubun = 'G' Then	'155'	--배민영
						End	,   
			
		h_orderid	=  Case  
						   When c.company_seq in (232,1137,1250,2235) Then --디지털플라자, 워커힐, G마켓 (후불결제), 전자랜드
								Case 
									When (b.item_Type ='F'  and b.item_price > 0 )         --후불결제 업체라도 식권, 엠보인쇄 등 옵션이나 추가주문건은 PG를 타서 결제함 (주문번호 앞에 'IC' 붙힘)
										or (a.up_order_seq is not null and a.settle_price > 0) 
										or ( b.item_type in ('TBB','PANBI','JAEBON','EMBO','EnvInsert','QICKDELIVERY') 
										and a.settle_price > 0) Then 'IC'+ Cast(a.order_seq as nvarchar(50))
									Else 'D'+Cast(a.order_seq as nvarchar(50))  --후불건에 대해서는 주문번호 앞에 'D' 붙힘
								End
							Else
								'IC'+Cast(a.order_seq as nvarchar(50))
						End,
		h_memo1		= null,
		h_memo2		=	Case
							When a.sales_gubun = 'U' Then 'Inisis'
							Else a.pg_tid
						End,
						
		h_memo3		= null,
		
		b_biz		= 'BK10',
		b_goodGubun	= 'SO',
		b_seq		= 1,
		b_storeCode	= 'MF03',
		b_date		= Convert(char(8),a.src_send_date,112),
		b_goodCode	= b.card_code, --b.item_type
		b_goodUnit	= 'EA',
		b_OrderNum	= Case 
							When b.card_code = 'BSI010' Then (b.item_count/50)*6 
							Else b.item_count 
					  End,	
		------------------------------------------------------------------------------------------------------------------




		--**************************************************************************************************************
		--   * 아이템별 금액 셋팅
		--**************************************************************************************************************

		b_unitPrice	=   Case
							When b.item_Type in ('TBB','JAEBON','PANBI','EMBO','ENVINSERT','QICKDELIVERY')  Then b.item_Price				
							Else e.c_sobi
    					End,					

		b_offerPrice	=  Case
								When b.item_Type  in ('TBB','JAEBON','PANBI','EMBO','ENVINSERT','QICKDELIVERY')  Then Round(b.item_Price/1.1,0)	
								When b.item_Type = 'F' and b.item_Price <> 0									 Then Round(b.item_price/1.1,0)
								When b.item_Type = 'F' and b.item_Price = 0										 Then	0
								When b.item_Type  = 'E'	and b.card_code = 'BE029'							 Then	0  --미니청첩장 봉투는 무료로 넘김
								When b.item_Type  in ('S','M')  and b.item_price > 0							 Then 	Round(b.item_price*b.item_count/1.1 , 0)
								When b.item_Type  in ('S','M')  and b.item_price <= 0							 Then 	0
								Else Round(e.c_sobi*b.item_count/1.1,0)
	    					End,	


		b_superTax	=  Case
							When b.item_Type in ('TBB','JAEBON','PANBI','EMBO','ENVINSERT','QICKDELIVERY')  Then b.item_Price - Round(b.item_Price/1.1,0)	
							When b.item_Type = 'F' and b.item_Price <> 0									Then b.item_price - Round(b.item_price/1.1,0)
							When b.item_Type = 'F' and b.item_Price = 0										Then 0
							When b.item_Type  = 'E'		and b.card_code = 'BE029'						Then	0
							When b.item_Type  in ('S','M')  and b.item_price > 0							Then 	b.item_price*b.item_count - Round(b.item_price*b.item_count/1.1 , 0)
							When b.item_Type  in ('S','M')  and b.item_price <= 0							Then 	0			
							Else (e.c_sobi*b.item_count) - Round(e.c_sobi*b.item_count/1.1,0)
    					End,	


		b_sumPrice	=  Case
						When b.item_Type in ('TBB','JAEBON','PANBI','EMBO','ENVINSERT','QICKDELIVERY')  Then b.item_Price	
						When b.item_Type = 'F' and b.item_Price <> 0									Then b.item_price
						When b.item_Type = 'F' and b.item_Price = 0										Then 0
						When b.item_Type  = 'E' and b.card_code = 'BE029'								Then	0
						When b.item_Type  in ('S','M')  and b.item_price > 0							Then 	b.item_price*b.item_count
						When b.item_Type  in ('S','M')  and b.item_price <= 0							Then 	0			
						Else (e.c_sobi)*b.item_count
    				   End,	
		------------------------------------------------------------------------------------------------------------------


			
		b_memo		= null,
		reg_date	= getdate(),

		--**************************************************************************************************************
		--   * PG수수료 (PG로 넘어가는 것은 수수료를 셋팅해 준다.)
		--   pgFee getPGFee 함수 호출 (pg아이디, 결제수단, 결제금액, 카드사정보)
		--**************************************************************************************************************
		FeeAmnt		=  dbo.getPGFee_New (a.pg_shopid, a.settle_method, a.settle_price), --2009년 3월 16일 결제부터 새로운 PG수수료율 적용		
		
						--Case 
						--		--When Convert(char(8),a.settle_Date,112) <= '20090316' Then 
						--		--	dbo.getPGFee (a.pg_shopid, a.settle_method, a.settle_price,  
						--		--			Case
						--		--				When pg_resultinfo like '국민%'		Then '국민'	
						--		--				When pg_resultinfo like '씨티%'		Then '국민'		
						--		--				When pg_resultinfo like '농협%'		Then '국민'	
						--		--				When pg_resultinfo like '외환%'		Then '외환'		
						--		--				When pg_resultinfo like '산은%'		Then '외환'	
						--		--				When pg_resultinfo like '비씨%'		Then '비씨'
						--		--				When pg_resultinfo like '하나%'		Then '비씨'
						--		--				When pg_resultinfo like '구 LG%'	Then 'LG'
						--		--				When pg_resultinfo like '삼성%'		Then '삼성'
						--		--				When pg_resultinfo like '현대%'		Then '현대'
						--		--				When pg_resultinfo like '롯데%'		Then '롯데'
						--		--				When pg_resultinfo like '신한%'		Then '신한'			
						--		--				When pg_resultinfo like '수협%'		Then '신한'				
						--		--				When pg_resultinfo like '제주%'		Then '신한'						 
						--		--				When pg_resultinfo like '광주%'		Then '신한'				
						--		--				When pg_resultinfo like '전북%'		Then '신한'	
						--		--			End)
						--		--Else 
								
						--		dbo.getPGFee_New (a.pg_shopid, a.settle_method, a.settle_price) --2009년 3월 16일 결제부터 새로운 PG수수료율 적용			
						--End,

		------------------------------------------------------------------------------------------------------------------
		ItemGubun	= 'item',


		--**************************************************************************************************************
		--   * PG체크
		--**************************************************************************************************************
		
		PGCheck	=  Case
						When a.sales_gubun = 'W' Then 'Y'
						When a.sales_gubun = 'T' Then 'Y'
						When a.sales_gubun = 'U' Then 'N'
						When a.sales_gubun = 'S' Then 'Y'
						When a.sales_gubun = 'X' Then 'Y'
						When a.sales_gubun = 'G' Then 'Y'
						When a.sales_gubun = 'B' Then 
							Case 
								When  c.company_seq in (232,1137,1250,2235) Then   --디지털플라자, 워커힐, G마켓 (후불결제), 전자랜드 
									Case
										When (b.item_type = 'F' and b.item_price > 0) or (a.up_order_seq is not null and a.settle_price > 0) or  ( b.item_type in ('TBB','PANBI','JAEBON','EMBO','EnvInsert','QICKDELIVERY') and a.settle_price > 0) Then 'Y'  -- 일반과세
										Else 'N'
									End	
								Else 'Y'
							End		
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
		DeptGubun	=  Case 
		
							When a.sales_gubun = 'W' Then	'BA'	
							When a.sales_gubun = 'T' Then	'TH'	
							When a.sales_gubun = 'U' Then	'TU'	--기형석
							When a.sales_gubun = 'J' Then	'BR'	--김성동
							When a.sales_gubun = 'B' Then	'BR'	--김성동 
							--When a.sales_gubun = 'A' Then	'TI'	--티아라는 다른 SP에서 올라감
							When a.sales_gubun = 'S' Then	'SI'	--기형석
							When a.sales_gubun = 'X' Then	'TI'	--김성동
							When a.sales_gubun = 'G' Then	'AG'	--아가 배민영
						End	
	FROM 
		custom_order a JOIN  (
					SELECT order_seq,card_seq, card_code,item_type, item_count, item_price
					FROM 
						(
						--기본 아이템 정보 (무료식권, 무료 미니청첩장)
						SELECT  
							a.order_seq, b.card_seq,c.card_code, b.item_type,b.item_count as item_count , IsNUll(b.item_sale_price,0) as item_price
						FROM custom_order a JOIN  custom_order_item b ON  a.order_seq = b.order_seq
						JOIN card c ON b.card_seq = c.card_seq
						WHERE 
							a.status_Seq = 15  -- 배송완료
							and convert(char(8),a.src_send_date,112) between @SDate and @EDate
							and b.item_count > 0
							and a.sales_gubun in ('W','T','U','J','B','S','X','G')
							and b.item_type not in ('F','M') --C:카드,E:봉투,I:내지,S:스티커,M:미니청첩장,F:식권,A:부속품 ,B:라벨지,R: 리본
							and c.card_code <> 'BPC001'
						) c
					UNION
	  
 					--미니청첩장
 						(

 						-- 1. 미니청첩장 독립주문 (스티커, 봉투 추가되어 나감)
 						SELECT  
							a.order_seq, b.card_seq,c.card_code, b.item_type,b.item_count as item_count 
							, IsNUll(b.item_sale_price,0) * b.item_count as item_price
						FROM custom_order a JOIN  custom_order_item b ON  a.order_seq = b.order_seq
						JOIN card c ON b.card_seq = c.card_seq
						WHERE 
							a.status_Seq = 15  -- 배송완료
							and convert(char(8),a.src_send_date,112) between @SDate and @EDate
							and b.item_count > 0
							and a.sales_gubun in ('W','T','U','J','B','S','X','G')
							and a.order_type = '5'
 						UNION
				 		
 						-- 2. 무료제공 미니청첩장 (청첩장 400장 이상 주문한 경우 50장까지 무료)
 						SELECT
 							a.order_seq, b.card_seq,c.card_code, b.item_type,b.item_count as item_count 
							, 0 as item_price
 						FROM custom_order a JOIN custom_order_item b ON a.order_seq = b.order_seq
 						JOIN card c ON b.card_seq = c.card_seq
 						WHERE 
 							a.status_Seq = 15  -- 배송완료
							and convert(char(8),a.src_send_date,112) between @SDate and @EDate
							and a.sales_gubun in ('W','T','U','J','B','S','X','G')
							and a.order_type <> '5'   
							and b.item_type = 'M' 
							and a.mini_price = 0
				 		
				 		
						UNION
						
						-- 3. 유료제공 미니청첩장 (청첩장 400장 이상 주문한 경우 50장까지 무료 초과시 장당 200원 )
						-- 3.1 무료제공 수량 (400장 이상 주문시 50장 무료제공)
						SELECT
 							a.order_seq, b.card_seq,c.card_code, b.item_type, 50 as item_count 
							, 0 as item_price
 						FROM custom_order a JOIN custom_order_item b ON a.order_seq = b.order_seq
 						JOIN card c ON b.card_seq = c.card_seq
 						WHERE 
 							a.status_Seq = 15  -- 배송완료
							and convert(char(8),a.src_send_date,112) between @SDate and @EDate
							and a.sales_gubun in ('W','T','U','J','B','S','X','G')
							and a.order_type <> '5' -- order_type 주문타입(1:청첩장,2:감사장,3:초대장, 5:미니청첩장)
							and b.item_type = 'M' 
							and a.order_count >= 400 --400장 이상 주문한 경우 50장까지 무료제공 
							and a.mini_price <> 0	
							and b.item_count = 50	
				 		
				 		
 						UNION
				 		
 						-- 3.3 유료제공 수량 (주문수량 초과 수량)
 						SELECT
 							a.order_seq, b.card_seq,c.card_code, b.item_type,b.item_count - 50 as item_count 
							, IsNUll(b.item_sale_price,0) * b.item_count as item_price
 						FROM custom_order a JOIN custom_order_item b ON a.order_seq = b.order_seq
 						JOIN card c ON b.card_seq = c.card_seq
 						WHERE 
 							a.status_Seq = 15  -- 배송완료
							and convert(char(8),a.src_send_date,112) between @SDate and @EDate
							and a.sales_gubun in ('W','T','U','J','B','S','X','G')
							and a.order_type <> '5' -- order_type 주문타입(1:청첩장,2:감사장,3:초대장, 5:미니청첩장)
							and b.item_type = 'M' 
							and a.order_count >= 400
							and a.mini_price <> 0	
							and b.item_count > 50
						
						UNION
							
						-- 3.4 유료제공 수량 (청첩장 400장 이하 주문자)
 						SELECT
 							a.order_seq, b.card_seq,c.card_code, b.item_type,b.item_count as item_count 
							, IsNUll(b.item_sale_price,0) * b.item_count as item_price
 						FROM custom_order a JOIN custom_order_item b ON a.order_seq = b.order_seq
 						JOIN card c ON b.card_seq = c.card_seq
 						WHERE 
 							a.status_Seq = 15  -- 배송완료
							and convert(char(8),a.src_send_date,112) between @SDate and @EDate
							and a.sales_gubun in ('W','T','U','J','B','S','X','G')
							and a.order_type <> '5' -- order_type 주문타입(1:청첩장,2:감사장,3:초대장, 5:미니청첩장)
							and b.item_type = 'M' 
							and a.order_count < 400
							and a.mini_price <> 0		
							
						-- 3.5 미니청첩장 봉투, 스티커	
						UNION
						
						SELECT a.order_seq, 6320,'BSI010','S', b.item_count as item_count 
							, 0 as item_price 			
 						FROM custom_order a JOIN custom_order_item b ON a.order_seq = b.order_seq
 						JOIN card c ON b.card_seq = c.card_seq
 						WHERE 
 							a.status_Seq = 15  -- 배송완료
							and convert(char(8),a.src_send_date,112) between @SDate and @EDate
							and a.sales_gubun in ('W','T','U','J','B','S','X','G')
							and a.order_type <> '5'   
							and b.item_type = 'M' 
						
						UNION
						
						SELECT a.order_seq, 6319,'BE029','E', b.item_count as item_count 
							, 0 as item_price 			
 						FROM custom_order a JOIN custom_order_item b ON a.order_seq = b.order_seq
 						JOIN card c ON b.card_seq = c.card_seq
 						WHERE 
 							a.status_Seq = 15  -- 배송완료
							and convert(char(8),a.src_send_date,112) between @SDate and @EDate
							and a.sales_gubun in ('W','T','U','J','B','S','X','G')
							and a.order_type <> '5'   
							and b.item_type = 'M' 

 					)
						
					UNION
						-- 식권
 						(
 						--1.무료식권 주문시 (fticket_price가 0원일 경우)
 						SELECT  
							a.order_seq, b.card_seq,c.card_code, b.item_type,b.item_count as item_count 
							--, a.fticket_price
							, IsNUll(b.item_sale_price,0) as item_price
						FROM custom_order a JOIN  custom_order_item b ON  a.order_seq = b.order_seq
						JOIN card c ON b.card_seq = c.card_seq
						WHERE 
							a.status_Seq = 15  -- 배송완료
							and convert(char(8),a.src_send_date,112) between @SDate and @EDate
							and a.sales_gubun in ('W','T','U','J','B','S','X','G')
							and b.item_type = 'F' and a.fticket_price = 0
							and b.item_count > 0
				 		
 						UNION
				 		
 						--2. 유료식권 주문시 (fticket_price가 있을 경우)
						--2.1 무료식권 추가일 경우 (청첩장 주문 수량을 초과하는 금액에 대하여 30원 과금)
						--2.1.1 무료수량
						SELECT  
							a.order_seq, b.card_seq,c.card_code, b.item_type
							--, a.order_count
							--, b.item_count as item_count 
							, Round(b.item_count * a1.disRate,0) as item_count
							--,a.fticket_price
							, 0 as item_price
						FROM custom_order a JOIN  custom_order_item b ON  a.order_seq = b.order_seq
						JOIN card c ON b.card_seq = c.card_seq
						JOIN (
							  SELECT a.order_seq, a.order_count, sum(b.item_count) as sum_count
									,((order_count*100)/sum(item_count))/100.0 as disRate
							  FROM custom_order a JOIN custom_order_item b ON a.order_seq = b.order_seq
							  WHERE b.item_type ='F' 
									and b.item_count > 0	
							  GROUP BY a.order_seq, a.order_count			 	
						
							 ) a1 ON a.order_seq = a1.order_seq
						WHERE 
							a.status_Seq = 15  -- 배송완료
							and convert(char(8),a.src_send_date,112) between @SDate and @EDate
							and a.sales_gubun in ('W','T','U','J','B','S','X','G')
							and b.item_type = 'F' and a.fticket_price > 0
							and b.item_count > 0		
							and c.card_code in ('FSB01','FSB02','FSU01','FSU02','FST01','FST02','YC01','YC02') --무료식권

						UNION
						
						--2.1.2 유료수량
						SELECT  
							a.order_seq, b.card_seq,c.card_code, b.item_type
							--, a.order_count
							--, b.item_count as item_count 
							, b.item_count- Round(b.item_count * a1.disRate,0) as item_count
							--, a.fticket_price
							, Round((a.fticket_price/(a1.sum_count*1.00))*item_count,0)  as item_price
						FROM custom_order a JOIN  custom_order_item b ON  a.order_seq = b.order_seq
						JOIN card c ON b.card_seq = c.card_seq
						JOIN (
							  SELECT a.order_seq, a.order_count, sum(b.item_count) as sum_count
									,((order_count*100)/sum(item_count))/100.0 as disRate
							  FROM custom_order a JOIN custom_order_item b ON a.order_seq = b.order_seq
							  WHERE b.item_type ='F' 
									and b.item_count > 0	
							  GROUP BY a.order_seq, a.order_count			 	
						
							 ) a1 ON a.order_seq = a1.order_seq
						WHERE 
							a.status_Seq = 15  -- 배송완료
							and convert(char(8),a.src_send_date,112) between @SDate and @EDate
							and a.sales_gubun in ('W','T','U','J','B','S','X')
							and b.item_type = 'F' and a.fticket_price > 0
							and b.item_count > 0		
							and c.card_code in ('FSB01','FSB02','FSU01','FSU02','FST01','FST02','YC01','YC02') --무료식권

						UNION
						
						--2.2 유료식권일 경우 (청첩장 주문 수량만큼 20원, 초과하는 금액에 대하여 50원 과금)
						SELECT  
							a.order_seq, b.card_seq,c.card_code, b.item_type
							--, a.order_count
							, b.item_count as item_count 
							--, b.item_count- Round(b.item_count * a1.disRate,0)
							--, a.fticket_price
							, Round((a.fticket_price/(a1.sum_count*1.00))*item_count,0)  as item_price
						FROM custom_order a JOIN  custom_order_item b ON  a.order_seq = b.order_seq
						JOIN card c ON b.card_seq = c.card_seq
						JOIN (
							  SELECT a.order_seq, a.order_count, sum(b.item_count) as sum_count
									,((order_count*100)/sum(item_count))/100.0 as disRate
							  FROM custom_order a JOIN custom_order_item b ON a.order_seq = b.order_seq
							  WHERE b.item_type ='F' 
									and b.item_count > 0	
							  GROUP BY a.order_seq, a.order_count			 	
						
							 ) a1 ON a.order_seq = a1.order_seq
						WHERE 
							a.status_Seq = 15  -- 배송완료
							and convert(char(8),a.src_send_date,112) between @SDate and @EDate
							and a.sales_gubun in ('W','T','U','J','B','S','X')
							and b.item_type = 'F' and a.fticket_price > 0
							and b.item_count > 0	
							and c.card_code in ('FS03','FS04','FS07','FS08','FSU03','FSU04') --유료식권
						
 						)
						
					UNION   
						--택배비
						(
						SELECT order_seq, card_seq,  'TBB', 'TBB', 1, delivery_price
						FROM Custom_Order 
						WHERE 
						Convert(char(8),src_send_date,112) between @SDate and @EDate
						and delivery_price > 0
						and status_seq = 15 
						and pay_type <> '4' 
						and sales_gubun in ('W','T','U','J','B','S','X','G') 
						)
					UNION   
						--제본
						(
						SELECT order_seq, card_seq, 'JAEBON','JAEBON',  order_count, JEBON_price
						FROM Custom_Order 
						WHERE 
						Convert(char(8),src_send_date,112) between @SDate and @EDate
						and jebon_price > 0
						and status_seq = 15 
						and pay_type <> '4' 
						and sales_gubun in ('W','T','U','J','B','S','X','G') 
						)  
				
					UNION
						--추가판비   
						(
						SELECT order_seq, card_seq, 'PANBI','PANBI', 1, option_price
						FROM Custom_Order 
						WHERE 
						Convert(char(8),src_send_date,112) between @SDate and @EDate
						and option_price > 0
						and status_seq = 15 
						and pay_type <> '4' 
						and sales_gubun in ('W','T','U','J','B','S','X','G') 
						)  
				
					UNION
						--엠보   
						(
						SELECT order_seq, card_seq,'EMBO', 'EMBO',order_count, embo_price
						FROM Custom_Order 
						WHERE 
						Convert(char(8),src_send_date,112) between @SDate and @EDate
						and embo_price > 0
						and  status_seq = 15 						and pay_type <> '4' 
						and sales_gubun in ('W','T','U','J','B','S','X','G') 
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
						and sales_gubun in ('W','T','U','J','B','S','X','G') 
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
						and sales_gubun in ('W','T','U','J','B','S','X','G') 
						)
					) b ON a.order_seq = b.order_seq

		JOIN company c ON a.company_seq = c.company_seq
		JOIN card d ON b.card_seq = d.card_seq
		LEFT JOIN  OPENQUERY([erpdb.bhandscard.com], 'SELECT  IsNull(stdPurprice,0) as stdPurprice, IsNull(c_sobi,0) as c_sobi,itemcode,itemgroup FROM XERP.DBO.itemSiteMaster ') e ON d.card_code = e.itemCode

	WHERE 
	a.status_Seq = 15 
	--and convert(char(8),src_send_date,112) between @SDate and @EDate
	and a.order_seq = 707004
	and a.pay_type <> '4' 
	and a.sales_gubun in ('W','T','U','J','B','S','X','G') 
	ORDER BY a.order_seq 

GO
