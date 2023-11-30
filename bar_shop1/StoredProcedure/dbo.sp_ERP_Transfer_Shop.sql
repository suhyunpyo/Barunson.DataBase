IF OBJECT_ID (N'dbo.sp_ERP_Transfer_Shop', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_ERP_Transfer_Shop
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
-- EXEC sp_ERP_Transfer_Shop '20100729','20100729'


CREATE PROCEDURE [dbo].[sp_ERP_Transfer_Shop]
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



----**************************************************************************************************************
----1.청첩장
----**************************************************************************************************************

--custom_order 테이블에서 대상데이터를 임시테이블에 넣음. 20090805-이상민
SELECT * 
INTO #custom_order
FROM custom_order A
WHERE A.status_Seq = 15  -- 배송완료
	and convert(char(8), A.src_send_date, 112) BETWEEN @SDate AND @EDate
	and A.sales_gubun in ('W','T','J','B','S','X','G', 'SW', 'SP', 'SH') --'U' : (구)2u카드 제외
	
	--and A.sales_gubun in ('W','T','J','B','S','X','G', 'SB', 'SW', 'SS', 'SP', 'SH') --'U' : (구)2u카드 제외
	
	
--카드정보
SELECT Card_Seq, Card_Code, CASE WHEN RTRIM(LTRIM(ISNULL(ERP_Code, ''))) = '' THEN Card_Code ELSE ERP_Code END  AS Card_ERPCode
	, Cont_Seq, Acc_Seq, Acc_seq2
INTO #CardMaster
FROM Card A
WHERE  ISNULL(A.CARD_CATE, '') <> 'SL' --사은품 제거
Union ALL
SELECT A.Card_Seq, A.Card_Code, CASE WHEN RTRIM(LTRIM(ISNULL(A.Card_ERPCode, ''))) = '' THEN A.Card_Code ELSE A.Card_ERPCode END  AS Card_ERPCode 
	, ISNULL(B.Inpaper_seq, 0) AS Cont_Seq, ISNULL(B.Acc1_seq, 0) AS Acc_Seq, ISNULL(B.Acc2_seq, 0) AS Acc_seq2
FROM S2_Card A
LEFT JOIN S2_CardDetail B ON A.Card_Seq = B.Card_Seq
WHERE  ISNULL(A.Card_Div, '') <> 'C05' --사은품 제거


	INSERT INTO #erp_salesReport ( 	h_biz,
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

		--** 결제금액이 있는것은 모든 아이템에 대하여 정상출고로 출고시킨다. 추후 ERP가 아이템별 출고 유형을 달리 할 수 있도록 수정하면 여기도 수정해 줘야 함
		h_sysCode	= Case 
						When b.item_Type = 'C'                                           	Then @SysCode1     -- 카드는 정상출고
						When b.item_Type = 'E'  and b.Card_ErpCode <> 'BE029'                 	Then @SysCode1     -- 일반봉투 정상출고
						When b.item_Type = 'E'  and b.Card_ErpCode = 'BE029'                  	Then @SysCode2     -- 미니봉투 예외출고
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
						When b.item_Type = 'D'                                           	Then @SysCode1     -- 카드띠지 20091030_이상민
						When b.item_Type = 'G'                                           	Then @SysCode1     -- 20100507_이상민
						Else b.item_Type 
					End,
		
		h_usrCode	= Case 
						When b.item_Type = 'C'                                       		Then @UsrCode1     -- 카드는 정상출고
						When b.item_Type = 'E' and b.Card_ErpCode <> 'BE029'                  	Then @UsrCode1     -- 일반봉투 정상출고
						When b.item_Type = 'E' and b.Card_ErpCode = 'BE029'                  	Then @UsrCode2     -- 미니봉투 예외출고
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
						When b.item_Type = 'D'                                           	Then @UsrCode1     -- 카드띠지 20091030_이상민
						When b.item_Type = 'G'                                           	Then @UsrCode1     -- 20100507_이상민
						Else b.item_Type
					 End, 	

		--**************************************************************************************************************
		--   * 거래처코드 (company_seq로 구분)
		--**************************************************************************************************************
		--1. 후불결제 업체의 경우 정상주문건은 거래처가 후불결제 업체로 넘어가고 추가주문이나 옵션에 대한 것은 제휴코드로 넘어감
		h_comcode	=   Case
							When a.sales_gubun = 'W' Then '1450002'
							When a.sales_gubun = 'T' Then '1450005'
							--When a.sales_gubun = 'U' Then '17577'	--'U' : (구)2u카드 제외
							When a.sales_gubun = 'S' Then '1450065'
							When a.sales_gubun = 'X' Then '1450003'
							When a.sales_gubun = 'G' Then '1450066'							
							When a.sales_gubun = 'SB' Then '1450071'	--바른손카드
							When a.sales_gubun = 'SW' Then '1450072'	--위시메이드
							When a.sales_gubun = 'SS' Then '1450073'	--스토리오브러브
							When a.sales_gubun = 'SH' Then '1450074'	--해피카드
							When a.sales_gubun = 'SP' Then '1450075'	--Wpaper
							
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
							--When a.sales_gubun = 'U' Then '10'		--'U' : (구)2u카드 제외
							When a.sales_gubun = 'S' Then '22'
							When a.sales_gubun = 'X' Then '22'
							When a.sales_gubun = 'G' Then '22'
							When a.sales_gubun = 'SB' Then '22'	--바른손카드
							When a.sales_gubun = 'SW' Then '22'	--위시메이드
							When a.sales_gubun = 'SS' Then '22'	--스토리오브러브
							When a.sales_gubun = 'SH' Then '22'	--해피카드
							When a.sales_gubun = 'SP' Then '22'	--Wpaper
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
							--When a.sales_gubun = 'U' Then	'550'	--투유	--'U' : (구)2u카드 제외
							When a.sales_gubun = 'J' Then	'390'	--제휴
							When a.sales_gubun = 'B' Then	'390'	--제휴 
							--When a.sales_gubun = 'A' Then	'870'	--티아라
							When a.sales_gubun = 'S' Then	'450'	--스토리러브
							When a.sales_gubun = 'X' Then	'395'	--시즌
							When a.sales_gubun = 'G' Then	'890'	--아가
							When a.sales_gubun = 'SB' Then 'N110'	--바른손카드
							When a.sales_gubun = 'SW' Then 'N210'	--위시메이드
							When a.sales_gubun = 'SS' Then 'N130'	--스토리오브러브
							When a.sales_gubun = 'SH' Then 'N220'	--해피카드
							When a.sales_gubun = 'SP' Then 'N120'	--Wpaper
							
						End	,				
		h_staffcode	= Case 
		
							When a.sales_gubun = 'W' Then	'030603'	--김성동
							When a.sales_gubun = 'T' Then	'090501'	--기형석
							--When a.sales_gubun = 'U' Then	'090501'	--기형석		--'U' : (구)2u카드 제외
							When a.sales_gubun = 'J' Then	'030603'	--김성동
							When a.sales_gubun = 'B' Then	'030603'	--김성동 
							--When a.sales_gubun = 'A' Then	'030603'	--티아라
							When a.sales_gubun = 'S' Then	'090501'	--기형석
							When a.sales_gubun = 'X' Then	'030603'	--김성동
							When a.sales_gubun = 'G' Then	'080403'	--배민영->김효주
							
							When a.sales_gubun = 'SB' Then '030603'	--바른손카드	김성동
							When a.sales_gubun = 'SW' Then '100906'	--위시메이드	기형석->배종희
							When a.sales_gubun = 'SS' Then '030603'	--스토리오브러브	김성동
							When a.sales_gubun = 'SH' Then '030603'	--해피카드	기형석->김성동
							When a.sales_gubun = 'SP' Then '100906'	--Wpaper	최문정->배종희
						End	,   			
		h_sonik		= '110',
		h_cost		= Case 
		
							When a.sales_gubun = 'W' Then	'117'	
							When a.sales_gubun = 'T' Then	'143'	
							--When a.sales_gubun = 'U' Then	'149'	--기형석		--'U' : (구)2u카드 제외
							When a.sales_gubun = 'J' Then	'148'	--김성동
							When a.sales_gubun = 'B' Then	'148'	--김성동 
							--When a.sales_gubun = 'A' Then	'152'	--티아라
							When a.sales_gubun = 'S' Then	'163'	--기형석
							When a.sales_gubun = 'X' Then	'153'	--김성동
							When a.sales_gubun = 'G' Then	'155'	--배민영
							When a.sales_gubun = 'SB' Then '117'	--바른손카드	김성동
							When a.sales_gubun = 'SW' Then '143'	--위시메이드	기형석
							When a.sales_gubun = 'SS' Then '117'	--스토리오브러브	김성동
							When a.sales_gubun = 'SH' Then '143'	--해피카드	기형석
							When a.sales_gubun = 'SP' Then '117'	--Wpaper	최문정
						End	,   
			
		--h_orderid	=  Case  
		--				   When c.company_seq in (232,1137,1250,2235) Then --디지털플라자, 워커힐, G마켓 (후불결제), 전자랜드
		--						Case 
		--							When (b.item_Type ='F'  and b.item_price > 0 )         --후불결제 업체라도 식권, 엠보인쇄 등 옵션이나 추가주문건은 PG를 타서 결제함 (주문번호 앞에 'IC' 붙힘)
		--								or (a.up_order_seq is not null and a.settle_price > 0) 
		--								or ( b.item_type in ('TBB','PANBI','JAEBON','EMBO','EnvInsert','QICKDELIVERY') 
		--								and a.settle_price > 0) Then 'IC'+ Cast(a.order_seq as nvarchar(50))
		--							Else 'D'+Cast(a.order_seq as nvarchar(50))  --후불건에 대해서는 주문번호 앞에 'D' 붙힘
		--						End
		--					Else
		--						'IC'+Cast(a.order_seq as nvarchar(50))
		--				End,
		h_orderid	= ISNULL(a.pg_tid, 'IC'+Cast(a.order_seq as nvarchar(50)) ), 		
		h_memo1	= null,
		h_memo2	=	Case	When a.sales_gubun = 'U' Then 'Inisis'	Else a.pg_tid End,						
		h_memo3	= null,
		
		b_biz		= 'BK10',
		b_goodGubun	= 'SO',
		b_seq		= 1,
		b_storeCode	= 'MF03',
		b_date		= Convert(char(8),a.src_send_date,112),
		b_goodCode	= b.Card_ErpCode, --b.item_type
		b_goodUnit	= 'EA',
		b_OrderNum	= Case 
							When b.Card_ErpCode = 'BSI010' Then (b.item_count/50)*6 
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
								When b.item_Type IN ('L', 'V') and b.item_Price = 0								 Then	0  --이상민추가 20100220
								When b.item_Type  = 'E'	and b.Card_ErpCode = 'BE029'							 Then	0  --미니청첩장 봉투는 무료로 넘김
								When b.item_Type  in ('S','M')  and b.item_price > 0							 Then 	Round(b.item_price*b.item_count/1.1 , 0)
								When b.item_Type  in ('S','M')  and b.item_price <= 0							 Then 	0
								Else Round(e.c_sobi*b.item_count/1.1,0)
	    					End,	


		b_superTax	=  Case
							When b.item_Type in ('TBB','JAEBON','PANBI','EMBO','ENVINSERT','QICKDELIVERY')  Then b.item_Price - Round(b.item_Price/1.1,0)	
							When b.item_Type = 'F' and b.item_Price <> 0									Then b.item_price - Round(b.item_price/1.1,0)
							When b.item_Type = 'F' and b.item_Price = 0										Then 0
							When b.item_Type  = 'E'		and b.Card_ErpCode = 'BE029'						Then	0
							When b.item_Type IN ('L', 'V') and b.item_Price = 0								 Then	0  --이상민추가 20100220
							When b.item_Type  in ('S','M')  and b.item_price > 0							Then 	b.item_price*b.item_count - Round(b.item_price*b.item_count/1.1 , 0)
							When b.item_Type  in ('S','M')  and b.item_price <= 0							Then 	0			
							Else (e.c_sobi*b.item_count) - Round(e.c_sobi*b.item_count/1.1,0)
    					End,	


		b_sumPrice	=  Case
						When b.item_Type in ('TBB','JAEBON','PANBI','EMBO','ENVINSERT','QICKDELIVERY')  Then b.item_Price	
						When b.item_Type = 'F' and b.item_Price <> 0									Then b.item_price
						When b.item_Type = 'F' and b.item_Price = 0										Then 0
						When b.item_Type IN ('L', 'V') and b.item_Price = 0								 Then	0  --이상민추가 20100220
						When b.item_Type  = 'E' and b.Card_ErpCode = 'BE029'								Then	0
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
						--When a.sales_gubun = 'U' Then 'N'		--'U' : (구)2u카드 제외
						When a.sales_gubun = 'S' Then 'Y'
						When a.sales_gubun = 'X' Then 'Y'
						When a.sales_gubun = 'G' Then 'Y'
						When a.sales_gubun = 'SB' Then 'Y'	--바른손카드	김성동
						When a.sales_gubun = 'SW' Then 'Y'	--위시메이드	기형석
						When a.sales_gubun = 'SS' Then 'Y'	--스토리오브러브	김성동
						When a.sales_gubun = 'SH' Then 'Y'	--해피카드	기형석
						When a.sales_gubun = 'SP' Then 'Y'	--Wpaper	최문정
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
							--When a.sales_gubun = 'U' Then	'TU'	--기형석			--'U' : (구)2u카드 제외
							When a.sales_gubun = 'J' Then	'BR'	--김성동
							When a.sales_gubun = 'B' Then	'BR'	--김성동 
							--When a.sales_gubun = 'A' Then	'TI'	--티아라는 다른 SP에서 올라감
							When a.sales_gubun = 'S' Then	'SI'	--기형석
							When a.sales_gubun = 'X' Then	'TI'	--김성동
							When a.sales_gubun = 'G' Then	'AG'	--아가 배민영
							When a.sales_gubun = 'SB' Then 'SB'	--바른손카드	김성동
							When a.sales_gubun = 'SW' Then 'SW'	--위시메이드	기형석
							When a.sales_gubun = 'SS' Then 'SS'	--스토리오브러브	김성동
							When a.sales_gubun = 'SH' Then 'SH'	--해피카드	기형석
							When a.sales_gubun = 'SP' Then 'SP'	--Wpaper	최문정							
						End	
	FROM #custom_order a 
	JOIN  (
	
					SELECT order_seq,card_seq, Card_ErpCode,item_type, item_count, item_price
					FROM 
						(
						--기본 아이템 정보 (무료식권, 무료 미니청첩장)
						SELECT  
							a.order_seq, b.card_seq, c.Card_ErpCode, b.item_type,b.item_count as item_count , IsNUll(b.item_sale_price,0) as item_price
						FROM #custom_order a 
						JOIN custom_order_item b ON  a.order_seq = b.order_seq
						JOIN #CardMaster c ON b.card_seq = c.card_seq
						WHERE a.status_Seq = 15  -- 배송완료
							and convert(char(8),a.src_send_date,112) between @SDate and @EDate
							and b.item_count > 0
							and a.sales_gubun in ('W','T','J','B','S','X','G', 'SB', 'SW', 'SS', 'SH', 'SP')	--'U' : (구)2u카드 제외
							and b.item_type not in ('F','M') --C:카드,E:봉투,I:내지,S:스티커,M:미니청첩장,F:식권,A:부속품 ,B:라벨지,R: 리본
							and c.Card_ErpCode <> 'BPC001'
						) c
						
					UNION
	  
 					--미니청첩장
 						(

 						-- 1. 미니청첩장 독립주문 (스티커, 봉투 추가되어 나감)
 						SELECT  
							a.order_seq, b.card_seq,c.Card_ErpCode, b.item_type,b.item_count as item_count 
							, IsNUll(b.item_sale_price,0) * b.item_count as item_price
						FROM #custom_order a 
						JOIN custom_order_item b ON  a.order_seq = b.order_seq
						JOIN #CardMaster c ON b.card_seq = c.card_seq
						WHERE 
							a.status_Seq = 15  -- 배송완료
							and convert(char(8),a.src_send_date,112) between @SDate and @EDate
							and b.item_count > 0
							and a.sales_gubun in ('W','T','J','B','S','X','G', 'SB', 'SW', 'SS', 'SH', 'SP')		--'U' : (구)2u카드 제외
							and a.order_type = '5'
 						UNION
				 		
 						-- 2. 무료제공 미니청첩장 (청첩장 400장 이상 주문한 경우 50장까지 무료)
 						SELECT
 							a.order_seq, b.card_seq,c.Card_ErpCode, b.item_type,b.item_count as item_count 
							, 0 as item_price
 						FROM #custom_order a 
 						JOIN custom_order_item b ON a.order_seq = b.order_seq
 						JOIN #CardMaster c ON b.card_seq = c.card_seq
 						WHERE 
 							a.status_Seq = 15  -- 배송완료
							and convert(char(8),a.src_send_date,112) between @SDate and @EDate
							and a.sales_gubun in ('W','T','J','B','S','X','G', 'SB', 'SW', 'SS', 'SH', 'SP')	--'U' : (구)2u카드 제외
							and a.order_type <> '5'   
							and b.item_type = 'M' 
							and a.mini_price = 0
				 		
				 		
						UNION
						
						-- 3. 유료제공 미니청첩장 (청첩장 400장 이상 주문한 경우 50장까지 무료 초과시 장당 200원 )
						-- 3.1 무료제공 수량 (400장 이상 주문시 50장 무료제공)
						SELECT
 							a.order_seq, b.card_seq,c.Card_ErpCode, b.item_type, 50 as item_count 
							, 0 as item_price
 						FROM #custom_order a 
 						JOIN custom_order_item b ON a.order_seq = b.order_seq
 						JOIN #CardMaster c ON b.card_seq = c.card_seq
 						WHERE 
 							a.status_Seq = 15  -- 배송완료
							and convert(char(8),a.src_send_date,112) between @SDate and @EDate
							and a.sales_gubun in ('W','T','J','B','S','X','G', 'SB', 'SW', 'SS', 'SH', 'SP')		--'U' : (구)2u카드 제외
							and a.order_type <> '5' -- order_type 주문타입(1:청첩장,2:감사장,3:초대장, 5:미니청첩장)
							and b.item_type = 'M' 
							and a.order_count >= 400 --400장 이상 주문한 경우 50장까지 무료제공 
							and a.mini_price <> 0	
							and b.item_count = 50	
				 		
				 		
 						UNION
				 		
 						-- 3.3 유료제공 수량 (주문수량 초과 수량)
 						SELECT
 							a.order_seq, b.card_seq,c.Card_ErpCode, b.item_type,b.item_count - 50 as item_count 
							, IsNUll(b.item_sale_price,0) * b.item_count as item_price
 						FROM #custom_order a 
 						JOIN custom_order_item b ON a.order_seq = b.order_seq
 						JOIN #CardMaster c ON b.card_seq = c.card_seq
 						WHERE a.status_Seq = 15  -- 배송완료
							and convert(char(8),a.src_send_date,112) between @SDate and @EDate
							and a.sales_gubun in ('W','T','J','B','S','X','G', 'SB', 'SW', 'SS', 'SH', 'SP')		--'U' : (구)2u카드 제외
							and a.order_type <> '5' -- order_type 주문타입(1:청첩장,2:감사장,3:초대장, 5:미니청첩장)
							and b.item_type = 'M' 
							and a.order_count >= 400
							and a.mini_price <> 0	
							and b.item_count > 50
						
						UNION
							
						-- 3.4 유료제공 수량 (청첩장 400장 이하 주문자)
 						SELECT a.order_seq, b.card_seq,c.Card_ErpCode, b.item_type,b.item_count as item_count 
							, IsNUll(b.item_sale_price,0) * b.item_count as item_price
 						FROM #custom_order a 
 						JOIN custom_order_item b ON a.order_seq = b.order_seq
 						JOIN #CardMaster c ON b.card_seq = c.card_seq
 						WHERE a.status_Seq = 15  -- 배송완료
							and convert(char(8),a.src_send_date,112) between @SDate and @EDate
							and a.sales_gubun in ('W','T','J','B','S','X','G', 'SB', 'SW', 'SS', 'SH', 'SP')		--'U' : (구)2u카드 제외
							and a.order_type <> '5' -- order_type 주문타입(1:청첩장,2:감사장,3:초대장, 5:미니청첩장)
							and b.item_type = 'M' 
							and a.order_count < 400
							and a.mini_price <> 0		
							
						-- 3.5 미니청첩장 봉투, 스티커	
						UNION
						
						SELECT a.order_seq, 6320,'BSI010','S', b.item_count as item_count 
							, 0 as item_price 			
 						FROM #custom_order a 
 						JOIN custom_order_item b ON a.order_seq = b.order_seq
 						JOIN #CardMaster c ON b.card_seq = c.card_seq
 						WHERE a.status_Seq = 15  -- 배송완료
							and convert(char(8),a.src_send_date,112) between @SDate and @EDate
							and a.sales_gubun in ('W','T','J','B','S','X','G', 'SB', 'SW', 'SS', 'SH', 'SP')		--'U' : (구)2u카드 제외
							and a.order_type <> '5'   
							and b.item_type = 'M' 
						
						UNION
						
						SELECT a.order_seq, 6319,'BE029','E', b.item_count as item_count 
							, 0 as item_price 			
 						FROM #custom_order a 
 						JOIN custom_order_item b ON a.order_seq = b.order_seq
 						JOIN #CardMaster c ON b.card_seq = c.card_seq
 						WHERE a.status_Seq = 15  -- 배송완료
							and convert(char(8),a.src_send_date,112) between @SDate and @EDate
							and a.sales_gubun in ('W','T','J','B','S','X','G', 'SB', 'SW', 'SS', 'SH', 'SP')		--'U' : (구)2u카드 제외
							and a.order_type <> '5'   
							and b.item_type = 'M' 

 					)
						
					UNION
						-- 식권
 						(
 						--1.무료식권 주문시 (fticket_price가 0원일 경우)
 						SELECT a.order_seq, b.card_seq,c.Card_ErpCode, b.item_type,b.item_count as item_count 
							--, a.fticket_price
							, IsNUll(b.item_sale_price,0) as item_price
						FROM #custom_order a 
						JOIN  custom_order_item b ON  a.order_seq = b.order_seq
						JOIN #CardMaster c ON b.card_seq = c.card_seq
						WHERE a.status_Seq = 15  -- 배송완료
							and convert(char(8),a.src_send_date,112) between @SDate and @EDate
							and a.sales_gubun in ('W','T','J','B','S','X','G', 'SB', 'SW', 'SS', 'SH', 'SP')		--'U' : (구)2u카드 제외
							and b.item_type = 'F' and a.fticket_price = 0
							and b.item_count > 0
				 		
 						UNION
				 		
 						--2. 유료식권 주문시 (fticket_price가 있을 경우)
						--2.1 무료식권 추가일 경우 (청첩장 주문 수량을 초과하는 금액에 대하여 30원 과금)
						--2.1.1 무료수량
						SELECT  a.order_seq, b.card_seq,c.Card_ErpCode, b.item_type
							, Round(b.item_count * a1.disRate,0) as item_count
							, 0 as item_price
						FROM #custom_order a 
						JOIN  custom_order_item b ON  a.order_seq = b.order_seq
						JOIN #CardMaster c ON b.card_seq = c.card_seq
						JOIN (
							  SELECT a.order_seq, a.order_count, sum(b.item_count) as sum_count
									,((order_count*100)/sum(item_count))/100.0 as disRate
							  FROM #custom_order a 
							  JOIN custom_order_item b ON a.order_seq = b.order_seq
							  WHERE b.item_type ='F' 
									and b.item_count > 0	
							  GROUP BY a.order_seq, a.order_count			 	
						
							 ) a1 ON a.order_seq = a1.order_seq
						WHERE a.status_Seq = 15  -- 배송완료
							and convert(char(8),a.src_send_date,112) between @SDate and @EDate
							and a.sales_gubun in ('W','T','J','B','S','X','G', 'SB', 'SW', 'SS', 'SH', 'SP')			--'U' : (구)2u카드 제외
							and b.item_type = 'F' and a.fticket_price > 0
							and b.item_count > 0		
							and c.Card_ErpCode in ('FSB01','FSB02','FSU01','FSU02','FST01','FST02','YC01','YC02') --무료식권

						UNION
						
						--2.1.2 유료수량
						SELECT  
							a.order_seq, b.card_seq,c.Card_ErpCode, b.item_type
							--, a.order_count
							--, b.item_count as item_count 
							, b.item_count- Round(b.item_count * a1.disRate,0) as item_count
							--, a.fticket_price
							, Round((a.fticket_price/(a1.sum_count*1.00))*item_count,0)  as item_price
						FROM #custom_order a 
						JOIN custom_order_item b ON  a.order_seq = b.order_seq
						JOIN #CardMaster c ON b.card_seq = c.card_seq
						JOIN (
							  SELECT a.order_seq, a.order_count, sum(b.item_count) as sum_count
									,((order_count*100)/sum(item_count))/100.0 as disRate
							  FROM #custom_order a 
							  JOIN custom_order_item b ON a.order_seq = b.order_seq
							  WHERE b.item_type ='F' 
									and b.item_count > 0	
							  GROUP BY a.order_seq, a.order_count			 	
						
							 ) a1 ON a.order_seq = a1.order_seq
						WHERE a.status_Seq = 15  -- 배송완료
							and convert(char(8),a.src_send_date,112) between @SDate and @EDate
							and a.sales_gubun in ('W','T','J','B','S','X','G', 'SB', 'SW', 'SS', 'SH', 'SP')			--'U' : (구)2u카드 제외
							and b.item_type = 'F' and a.fticket_price > 0
							and b.item_count > 0		
							and c.Card_ErpCode in ('FSB01','FSB02','FSU01','FSU02','FST01','FST02','YC01','YC02') --무료식권

						UNION
						
						--2.2 유료식권일 경우 (청첩장 주문 수량만큼 20원, 초과하는 금액에 대하여 50원 과금)
						SELECT  a.order_seq, b.card_seq,c.Card_ErpCode, b.item_type
							, b.item_count as item_count 
							, Round((a.fticket_price/(a1.sum_count*1.00))*item_count,0)  as item_price
						FROM #custom_order a 
						JOIN  custom_order_item b ON  a.order_seq = b.order_seq
						JOIN #CardMaster c ON b.card_seq = c.card_seq
						JOIN (
							  SELECT a.order_seq, a.order_count, sum(b.item_count) as sum_count
									,((order_count*100)/sum(item_count))/100.0 as disRate
							  FROM #custom_order a 
							  JOIN custom_order_item b ON a.order_seq = b.order_seq
							  WHERE b.item_type ='F' 
									and b.item_count > 0	
							  GROUP BY a.order_seq, a.order_count			 	
						
							 ) a1 ON a.order_seq = a1.order_seq
						WHERE 
							a.status_Seq = 15  -- 배송완료
							and convert(char(8),a.src_send_date,112) between @SDate and @EDate
							and a.sales_gubun in ('W','T','J','B','S','X','G', 'SB', 'SW', 'SS', 'SH', 'SP')			--'U' : (구)2u카드 제외
							and b.item_type = 'F' and a.fticket_price > 0
							and b.item_count > 0	
							and c.Card_ErpCode in ('FS03','FS04','FS07','FS08','FSU03','FSU04') --유료식권
						
 						)
						
					UNION   
						--택배비
						(
						SELECT order_seq, card_seq,  'TBB', 'TBB', 1, delivery_price
						FROM #custom_order 
						WHERE 
						Convert(char(8),src_send_date,112) between @SDate and @EDate
						and delivery_price > 0
						and status_seq = 15 
						and pay_type <> '4' 
						and sales_gubun in ('W','T','J','B','S','X','G', 'SB', 'SW', 'SS', 'SH', 'SP')			--'U' : (구)2u카드 제외
						)
					UNION   
						--제본
						(
						SELECT order_seq, card_seq, 'JAEBON','JAEBON',  order_count, JEBON_price
						FROM #custom_order 
						WHERE 
						Convert(char(8),src_send_date,112) between @SDate and @EDate
						and jebon_price > 0
						and status_seq = 15 
						and pay_type <> '4' 
						and sales_gubun in ('W','T','J','B','S','X','G', 'SB', 'SW', 'SS', 'SH', 'SP')			--'U' : (구)2u카드 제외
						)  
				
					UNION
						--추가판비   
						(
						SELECT order_seq, card_seq, 'PANBI','PANBI', 1, option_price
						FROM #custom_order 
						WHERE 
						Convert(char(8),src_send_date,112) between @SDate and @EDate
						and option_price > 0
						and status_seq = 15 
						and pay_type <> '4' 
						and sales_gubun in ('W','T','J','B','S','X','G', 'SB', 'SW', 'SS', 'SH', 'SP')				--'U' : (구)2u카드 제외
						)  
				
					UNION
						--엠보   
						(
						SELECT order_seq, card_seq,'EMBO', 'EMBO',order_count, embo_price
						FROM #custom_order 
						WHERE 
						Convert(char(8),src_send_date,112) between @SDate and @EDate
						and embo_price > 0
						and  status_seq = 15 						and pay_type <> '4' 
						and sales_gubun in ('W','T','J','B','S','X','G', 'SB', 'SW', 'SS', 'SH', 'SP')		--'U' : (구)2u카드 제외
						)  
					UNION   
						--봉투삽입
						(
						SELECT order_seq, card_seq,'ENVINSERT', 'ENVINSERT',order_count,  envInsert_price
						FROM #custom_order 
						WHERE 
						Convert(char(8),src_send_date,112) between @SDate and @EDate
						and envinsert_price > 0
						and  status_seq = 15 
						and pay_type <> '4' 
						and sales_gubun in ('W','T','J','B','S','X','G', 'SB', 'SW', 'SS', 'SH', 'SP')		--'U' : (구)2u카드 제외
						)  
					
					UNION
						--초특급 배송(custom_order.isSpecial='1' 그리고, custom_order.delivery_price=30000)
						(
						SELECT order_seq, card_seq,'QICKDELIVERY', 'QICKDELIVERY',order_count, delivery_price = 30000
						FROM #custom_order 
						WHERE 
						Convert(char(8),src_send_date,112) between @SDate and @EDate
						and isSpecial = '1'
						and status_seq = 15 
						and pay_type <> '4' 
						and sales_gubun in ('W','T','J','B','S','X','G', 'SB', 'SW', 'SS', 'SH', 'SP')		--'U' : (구)2u카드 제외
						)
					) b ON a.order_seq = b.order_seq 
							AND b.Card_ErpCode <> '코리아나'
		JOIN company c ON a.company_seq = c.company_seq
		JOIN #CardMaster d ON b.card_seq = d.card_seq
		LEFT JOIN  OPENQUERY([erpdb.bhandscard.com], 'SELECT  IsNull(stdPurprice,0) as stdPurprice, IsNull(c_sobi,0) as c_sobi,itemcode,itemgroup FROM XERP.DBO.itemSiteMaster WHERE SiteCode = ''BK10''') e ON d.Card_ErpCode = e.itemCode

	WHERE 
	a.status_Seq = 15 
	and convert(char(8),src_send_date,112) between @SDate and @EDate
	and a.pay_type <> '4' 
	and a.sales_gubun in ('W','T','J','B','S','X','G', 'SB', 'SW', 'SS', 'SH', 'SP')		--'U' : (구)2u카드 제외
	ORDER BY a.order_seq 

--select * from #CardMaster where Card_ErpCode = '코리아나'
--**************************************************************************************************************
--2.샘플
--**************************************************************************************************************
	
--custom_sample_order 테이블에서 대상데이터를 임시테이블에 넣음. 20090805-이상민
SELECT *
INTO #custom_sample_order
FROM custom_sample_order a 
WHERE Convert(char(8),a.delivery_Date,112) BETWEEN @SDate AND @EDate


				

-- 샘플 매출은 자사카드는 출고가 기준 10% 할인율 적용해서 올림
--      "  "         타사카드는 매입가 기준으로 올림
-- 배송비는 안올림
	INSERT INTO #erp_salesReport ( 	h_biz,
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
						When b.Card_ErpCode = 'TBB' Then @SysCode3  --택배비
						Else @SysCode3
					   End,

		h_usrCode	= Case 
						When b.Card_ErpCode = 'TBB' Then @UsrCode3  --택배비
						Else @UsrCode3
					   End,
					   
		h_comcode	=   Case
							When a.sales_gubun = 'W' Then '1450002'
							When a.sales_gubun = 'T' Then '1450005'
							--When a.sales_gubun = 'U' Then '17577'			--'U' : (구)2u카드 제외
							When a.sales_gubun = 'S' Then '1450065'
							When a.sales_gubun = 'X' Then '1450003'
							When a.sales_gubun = 'G' Then '1450066'
							When a.sales_gubun = 'B' Then '1489998'
							When a.sales_gubun = 'SB' Then '1450071'	--바른손카드
							When a.sales_gubun = 'SW' Then '1450072'	--위시메이드
							When a.sales_gubun = 'SS' Then '1450073'	--스토리오브러브
							When a.sales_gubun = 'SH' Then '1450074'	--해피카드
							When a.sales_gubun = 'SP' Then '1450075'	--Wpaper
								--Case
								--	When a.company_seq = (1250) Then '1400019'  --지마켓
								--	When a.company_seq = (2235) Then '1510052'  --전자랜드
								--	Else '1489998'
								--End	
						End, 	

		 h_taxType	=	Case
							When a.sales_gubun = 'W' Then '22'
							When a.sales_gubun = 'T' Then '22'
							--When a.sales_gubun = 'U' Then '10'				--'U' : (구)2u카드 제외
							When a.sales_gubun = 'S' Then '22'
							When a.sales_gubun = 'X' Then '22'
							When a.sales_gubun = 'B' Then '22'
							When a.sales_gubun = 'G' Then '22'
							When a.sales_gubun = 'SB' Then '22'	--바른손카드
							When a.sales_gubun = 'SW' Then '22'	--위시메이드
							When a.sales_gubun = 'SS' Then '22'	--스토리오브러브
							When a.sales_gubun = 'SH' Then '22'	--해피카드
							When a.sales_gubun = 'SP' Then '22'	--Wpaper
						End, 	
		h_offerPrice	=  Round(a.settle_price/1.1,0),	
		h_superTax		=  Round(a.settle_price- a.settle_price/1.1,0),	
		h_sumPrice		=  a.settle_price,	
		
		--**************************************************************************************************************
		--담당자 정보 및 기타 헤더 정보
		--**************************************************************************************************************
		h_partCode	=	Case 
		
							When a.sales_gubun = 'W' Then	'510'	--바른손카드
							When a.sales_gubun = 'T' Then	'380'	--더카드
							--When a.sales_gubun = 'U' Then	'550'	--투유			--'U' : (구)2u카드 제외
							When a.sales_gubun = 'J' Then	'390'	--제휴
							When a.sales_gubun = 'B' Then	'390'	--제휴 
							When a.sales_gubun = 'S' Then	'450'	--스토리러브
							When a.sales_gubun = 'X' Then	'395'	--시즌
							When a.sales_gubun = 'G' Then	'890'
							When a.sales_gubun = 'SB' Then 'N110'	--바른손카드
							When a.sales_gubun = 'SW' Then 'N210'	--위시메이드
							When a.sales_gubun = 'SS' Then 'N130'	--스토리오브러브
							When a.sales_gubun = 'SH' Then 'N220'	--해피카드
							When a.sales_gubun = 'SP' Then 'N120'	--Wpaper

						End	,				
		h_staffcode	= Case 
		
							When a.sales_gubun = 'W' Then	'030603'	--김성동
							When a.sales_gubun = 'T' Then	'090501'	--기형석
							--When a.sales_gubun = 'U' Then	'090501'	--기형석				--'U' : (구)2u카드 제외
							When a.sales_gubun = 'J' Then	'030603'	--김성동
							When a.sales_gubun = 'B' Then	'030603'	--김성동 
							When a.sales_gubun = 'S' Then	'090501'	--기형석
							When a.sales_gubun = 'X' Then	'030603'	--김성동
							When a.sales_gubun = 'G' Then	'080401'
							
							When a.sales_gubun = 'SB' Then '030603'	--바른손카드	김성동
							When a.sales_gubun = 'SW' Then '100906'	--위시메이드	기형석->배종희
							When a.sales_gubun = 'SS' Then '030603'	--스토리오브러브	김성동
							When a.sales_gubun = 'SH' Then '030603'	--해피카드	기형석->김성동
							When a.sales_gubun = 'SP' Then '100906'	--Wpaper	최문정->배종희
							
							
						End	,   			
		h_sonik		= '110',
		h_cost		= Case 
		
							When a.sales_gubun = 'W' Then	'117'	
							When a.sales_gubun = 'T' Then	'143'	
							--When a.sales_gubun = 'U' Then	'149'	--기형석				--'U' : (구)2u카드 제외
							When a.sales_gubun = 'J' Then	'148'	--김성동
							When a.sales_gubun = 'B' Then	'148'	--김성동 
							When a.sales_gubun = 'S' Then	'163'	--기형석
							When a.sales_gubun = 'X' Then	'153'	--김성동
							When a.sales_gubun = 'G' Then	'155'
							When a.sales_gubun = 'SB' Then '117'	--바른손카드	김성동
							When a.sales_gubun = 'SW' Then '143'	--위시메이드	기형석
							When a.sales_gubun = 'SS' Then '117'	--스토리오브러브	김성동
							When a.sales_gubun = 'SH' Then '143'	--해피카드	기형석
							When a.sales_gubun = 'SP' Then '117'	--Wpaper	최문정
						End	, 
						
		
		h_orderid	= ISNULL(a.pg_tid,  'IS'+ Cast(a.sample_order_seq as varchar(30))) ,
		h_memo1		= null,
		h_memo2		= Case
						When a.sales_gubun = 'U' Then 'Inisis'
						Else a.pg_tid
					  End,
		h_memo3		= null,
		b_biz		= 'BK10',
		b_goodGubun	= 'SO',
		b_seq		= 1,
		b_storeCode	= 'MF03',
		b_date		= Convert(char(8),a.delivery_Date,112),
		b_goodCode	= Case 
						When b.Card_ErpCode = 'TBB' Then 'TBB'  --택배비
						Else  d.Card_ErpCode
					  End,
		b_goodUnit	= 'EA',
		b_OrderNum	= b.card_count,
		b_unitPrice	= Case
						When b.Card_ErpCode = 'TBB' Then a.settle_price			 --샘플은 금액 0원, 택배비에만 금액 부과
						Else 0
					   End ,
		
		b_offerPrice = Case
							When b.Card_ErpCode = 'TBB' Then Round(a.settle_price/1.1, 0)		
							Else 0
					   End ,
		b_superTax	= Case
						When b.Card_ErpCode = 'TBB' Then Round(a.settle_price - (a.settle_price/1.1) ,0)	
						Else 0
					  End ,
		b_sumPrice	= Case
						When b.Card_ErpCode = 'TBB' Then  a.settle_price	
						Else 0
					  End ,
		b_memo		= null,
		reg_date	= getdate(),
		FeeAmnt		=  dbo.getPGFee_New (a.pg_mertid, a.settle_method, a.settle_price), --2009년 3월 16일 결제부터 새로운 PG수수료율 적용		
		
		
					--Case 
					--		When Convert(char(8),a.settle_Date,112) >= '20090316' Then 
					--			dbo.getPGFee (a.pg_mertid, a.settle_method, a.settle_price,  
					--					Case
					--						When pg_resultinfo like '국민%'		Then '국민'	
					--						When pg_resultinfo like '씨티%'		Then '국민'		
					--						When pg_resultinfo like '농협%'		Then '국민'	
					--						When pg_resultinfo like '외환%'		Then '외환'		
					--						When pg_resultinfo like '산은%'		Then '외환'	
					--						When pg_resultinfo like '비씨%'		Then '비씨'
					--						When pg_resultinfo like '하나%'		Then '비씨'
					--						When pg_resultinfo like '구 LG%'	Then 'LG'
					--						When pg_resultinfo like '삼성%'		Then '삼성'
					--						When pg_resultinfo like '현대%'		Then '현대'
					--						When pg_resultinfo like '롯데%'		Then '롯데'
					--						When pg_resultinfo like '신한%'		Then '신한'			
					--						When pg_resultinfo like '수협%'		Then '신한'				
					--						When pg_resultinfo like '제주%'		Then '신한'						 
					--						When pg_resultinfo like '광주%'		Then '신한'				
					--						When pg_resultinfo like '전북%'		Then '신한'	
					--					End)
					--		Else dbo.getPGFee_New (a.pg_mertid, a.settle_method, a.settle_price) --2009년 3월 16일 결제부터 새로운 PG수수료율 적용			
					--End	,									
		ItemGubun	= 'item',
		PGCheck		= Case 
		
							When a.sales_gubun = 'W' Then	'Y'	--바른손카드
							When a.sales_gubun = 'T' Then	'Y'	--더카드
							--When a.sales_gubun = 'U' Then	'N'	--투유		--'U' : (구)2u카드 제외
							When a.sales_gubun = 'J' Then	'Y'	--제휴
							When a.sales_gubun = 'B' Then	'Y'	--제휴 
							When a.sales_gubun = 'S' Then	'Y'	--스토리러브
							When a.sales_gubun = 'X' Then	'Y'	--시즌
							When a.sales_gubun = 'G' Then	'Y'	--아가
							When a.sales_gubun = 'SB' Then 'Y'	--바른손카드	김성동
							When a.sales_gubun = 'SW' Then 'Y'	--위시메이드	기형석
							When a.sales_gubun = 'SS' Then 'Y'	--스토리오브러브	김성동
							When a.sales_gubun = 'SH' Then 'Y'	--해피카드	기형석
							When a.sales_gubun = 'SP' Then 'Y'	--Wpaper	최문정
						End	,
		PayAmnt		= 0,
		SampleCheck	= 'Y',
		XartCheck	= 'N',
		SettleDate	= null,
		PayDate		= null,
		PayCheck	= null,
		DealAmnt	= null,
		b_memo_temp	= null,
		DeptGubun	= Case 
		
							When a.sales_gubun = 'W' Then	'BA'	
							When a.sales_gubun = 'T' Then	'TH'	
							--When a.sales_gubun = 'U' Then	'TU'	--기형석			--'U' : (구)2u카드 제외
							When a.sales_gubun = 'J' Then	'BR'	--김성동
							When a.sales_gubun = 'B' Then	'BR'	--김성동 
							When a.sales_gubun = 'S' Then	'SI'	--기형석
							When a.sales_gubun = 'X' Then	'TI'	--김성동
							When a.sales_gubun = 'G' Then	'AG'	--배민영
							When a.sales_gubun = 'SB' Then 'SB'	--바른손카드	김성동
							When a.sales_gubun = 'SW' Then 'SW'	--위시메이드	기형석
							When a.sales_gubun = 'SS' Then 'SS'	--스토리오브러브	김성동
							When a.sales_gubun = 'SH' Then 'SH'	--해피카드	기형석
							When a.sales_gubun = 'SP' Then 'SP'	--Wpaper	최문정
						End	
	FROM #custom_sample_order a 
	JOIN (
			SELECT sample_order_seq, card_seq, Card_ErpCode, settle_price, card_count 
			FROM  (
						SELECT a.sample_order_seq,  b.card_seq,  'item' as Card_ErpCode, settle_price, 1 as card_count  
						FROM #custom_sample_order a 
						JOIN custom_sample_order_item b ON a.sample_order_seq = b.sample_order_seq
						WHERE Convert(char(8),a.delivery_Date,112) between @SDate and @EDate 
				) c
					
				UNION
				-- 내지정보  
				SELECT a.sample_order_seq,d.card_seq as card_seq, 'item' as Card_ErpCode,a.settle_price,count(*) as card_count  FROM #custom_sample_order a 
				JOIN custom_sample_order_item b 
				ON a.sample_order_seq = b.sample_order_seq
				JOIN #CardMaster c ON b.card_seq = c.card_seq
				JOIN #CardMaster d ON c.cont_seq = d.card_seq
				WHERE Convert(char(8),a.delivery_Date,112) between @SDate and @EDate and (c.cont_seq is not null and c.cont_seq <> '0')
				GROUP BY a.sample_order_seq, d.card_seq,a.settle_price
				
				UNION
				-- 악세사리1 정보 
				SELECT a.sample_order_seq, d.card_seq as card_seq, 'item' as Card_ErpCode ,a.settle_price,count(*) as card_count FROM #custom_sample_order a 
				JOIN custom_sample_order_item b 
				ON a.sample_order_seq = b.sample_order_seq
				JOIN #CardMaster c	ON b.card_seq = c.card_seq
				JOIN #CardMaster d	ON c.acc_seq = d.card_seq
				WHERE Convert(char(8),a.delivery_Date,112) between @SDate and @EDate
				and (c.acc_seq is not null and c.acc_seq <> '0')
				GROUP BY a.sample_order_seq, d.card_seq,a.settle_price

				UNION
				-- 악세사리2 정보 
				SELECT a.sample_order_seq,d.card_seq as card_seq, 'item' as Card_ErpCode,a.settle_price,count(*) as card_count FROM #custom_sample_order a 
				JOIN custom_sample_order_item b 
				ON a.sample_order_seq = b.sample_order_seq
				JOIN #CardMaster c	ON b.card_seq = c.card_seq
				JOIN #CardMaster d 	ON c.acc_seq2 = d.card_seq
				WHERE Convert(char(8),a.delivery_Date,112) between @SDate and @EDate
						and (c.acc_seq2 is not null and c.acc_seq2 <> '0')
				GROUP BY a.sample_order_seq, d.card_seq,a.settle_price
		
				UNION

				SELECT  sample_order_seq, 1, 'TBB' as Card_ErpCode, settle_price, 1 as card_count
				FROM #custom_sample_order 
				WHERE Convert(char(8),delivery_Date,112) between @SDate and @EDate 

			)  b ON a.sample_order_seq = b.sample_order_seq
		JOIN company c ON a.company_seq = c.company_seq
		JOIN #CardMaster d ON b.card_seq = d.card_seq
		--LEFT JOIN  OPENQUERY([erpdb.bhandscard.com], 'SELECT  IsNull(stdPurprice,0) as stdPurprice, IsNull(c_sobi,0) as c_sobi,itemcode,itemgroup FROM XERP.DBO.itemSiteMaster WHERE SiteCode = ''BK10''') e ON d.Card_ErpCode = e.itemCode
	WHERE 
	a.status_seq = 12 
	and Convert(char(8),a.delivery_Date,112) between @SDate and @EDate
	and a.sales_gubun in ('W','T','J','B','S','X','G', 'SB', 'SW', 'SS', 'SH', 'SP')		--'U' : (구)2u카드 제외
	and ISNULL(a.pg_mertid, '') <> 'tiaracard1' 
	and ISNULL(a.sales_gubun, '') <> 'A' 
	--and a.src_erp_date is null  
	ORDER BY a.sample_order_seq 




--**************************************************************************************************************
 --3. 미니청첩장 및 식권 등 옵션 상품 따로 주문시 
--**************************************************************************************************************

--custom_etc_order 테이블에서 대상데이터를 임시테이블에 넣음. 20090805-이상민
SELECT *
INTO #custom_etc_order
FROM custom_etc_order a 
WHERE Convert(char(8), a.delivery_Date,112) BETWEEN @SDate AND @EDate

	
	INSERT INTO #erp_salesReport ( 	h_biz,
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
		h_sysCode	= @SysCode1,
		h_usrCode	= @UsrCode1, 	

		--**************************************************************************************************************
		--   * 거래처코드 (company_seq로 구분)
		--**************************************************************************************************************
		h_comcode	=  Case
							When a.sales_gubun = 'W' Then '1450002'
							When a.sales_gubun = 'T' Then '1450005'
							--When a.sales_gubun = 'U' Then '17577'			--'U' : (구)2u카드 제외
							When a.sales_gubun = 'S' Then '1450065'
							When a.sales_gubun = 'X' Then '1450003'
							When a.sales_gubun = 'B' Then '1489998'
							When a.sales_gubun = 'SB' Then '1450071'	--바른손카드
							When a.sales_gubun = 'SW' Then '1450072'	--위시메이드
							When a.sales_gubun = 'SS' Then '1450073'	--스토리오브러브
							When a.sales_gubun = 'SH' Then '1450074'	--해피카드
							When a.sales_gubun = 'SP' Then '1450075'	--Wpaper

								--Case
								--	When a.company_seq = (1250) Then '1400019'  --지마켓
								--	When a.company_seq = (2235) Then '1510052'  --전자랜드
								--	Else '1489998'
								--End	
						End, 
		------------------------------------------------------------------------------------------------------------------




		--**************************************************************************************************************
		--   * 과세유형
		--**************************************************************************************************************
		 h_taxType	=	Case
							When a.sales_gubun = 'W' Then '22'
							When a.sales_gubun = 'T' Then '22'
							--When a.sales_gubun = 'U' Then '10'				--'U' : (구)2u카드 제외
							When a.sales_gubun = 'S' Then '22'
							When a.sales_gubun = 'X' Then '22'
							When a.sales_gubun = 'B' Then '22'
							When a.sales_gubun = 'G' Then '22'
							When a.sales_gubun = 'SB' Then '22'	--바른손카드
							When a.sales_gubun = 'SW' Then '22'	--위시메이드
							When a.sales_gubun = 'SS' Then '22'	--스토리오브러브
							When a.sales_gubun = 'SH' Then '22'	--해피카드
							When a.sales_gubun = 'SP' Then '22'	--Wpaper
						End, 
		------------------------------------------------------------------------------------------------------------------

		
		h_offerPrice	= Round(a.settle_price/1.1,0),				
		h_superTax		= Round(a.settle_price- a.settle_price/1.1,0),	
		h_sumPrice		= a.settle_price,	


		--**************************************************************************************************************
		--담당자 정보 및 기타 헤더 정보
		--**************************************************************************************************************
		h_partCode	=	Case 
		
							When a.sales_gubun = 'W' Then	'510'	--바른손카드
							When a.sales_gubun = 'T' Then	'380'	--더카드
							--When a.sales_gubun = 'U' Then	'550'	--투유				--'U' : (구)2u카드 제외
							When a.sales_gubun = 'J' Then	'390'	--제휴
							When a.sales_gubun = 'B' Then	'390'	--제휴 
							When a.sales_gubun = 'S' Then	'450'	--스토리러브
							When a.sales_gubun = 'X' Then	'395'	--시즌
							When a.sales_gubun = 'G' Then	'890'
							When a.sales_gubun = 'SB' Then 'N110'	--바른손카드
							When a.sales_gubun = 'SW' Then 'N210'	--위시메이드
							When a.sales_gubun = 'SS' Then 'N130'	--스토리오브러브
							When a.sales_gubun = 'SH' Then 'N220'	--해피카드
							When a.sales_gubun = 'SP' Then 'N120'	--Wpaper
						End	,				
		h_staffcode	= Case 
		
							When a.sales_gubun = 'W' Then	'030603'	--김성동
							When a.sales_gubun = 'T' Then	'090501'	--기형석	
							--When a.sales_gubun = 'U' Then	'090501'	--기형석			--'U' : (구)2u카드 제외
							When a.sales_gubun = 'J' Then	'030603'	--김성동
							When a.sales_gubun = 'B' Then	'030603'	--김성동 
							When a.sales_gubun = 'S' Then	'090501'	--기형석
							When a.sales_gubun = 'X' Then	'030603'	--김성동
							When a.sales_gubun = 'G' Then	'080403'    --배민영->김효주
							
							When a.sales_gubun = 'SB' Then '030603'	--바른손카드	김성동
							When a.sales_gubun = 'SW' Then '100906'	--위시메이드	기형석->배종희
							When a.sales_gubun = 'SS' Then '030603'	--스토리오브러브	김성동
							When a.sales_gubun = 'SH' Then '030603'	--해피카드	기형석->김성동
							When a.sales_gubun = 'SP' Then '100906'	--Wpaper	최문정->배종희
							
						End	,   			
		h_sonik		= '110',
		h_cost		= Case 
		
							When a.sales_gubun = 'W' Then	'117'	
							When a.sales_gubun = 'T' Then	'143'	
							--When a.sales_gubun = 'U' Then	'149'	--기형석				--'U' : (구)2u카드 제외
							When a.sales_gubun = 'J' Then	'148'	--김성동
							When a.sales_gubun = 'B' Then	'148'	--김성동 
							When a.sales_gubun = 'S' Then	'163'	--기형석
							When a.sales_gubun = 'X' Then	'153'	--김성동
							When a.sales_gubun = 'G' Then	'155'	--배민영
							When a.sales_gubun = 'SB' Then '117'	--바른손카드	김성동
							When a.sales_gubun = 'SW' Then '143'	--위시메이드	기형석
							When a.sales_gubun = 'SS' Then '117'	--스토리오브러브	김성동
							When a.sales_gubun = 'SH' Then '143'	--해피카드	기형석
							When a.sales_gubun = 'SP' Then '117'	--Wpaper	최문정
							
						End	, 
						
		h_orderid	= Case
						When a.pg_shopid = '2ucard0001'	Then Cast(a.order_seq as nvarchar(20))
						Else a.pg_tid 
					  End,	
		h_memo1		= null,
		h_memo2		= Case
							When a.sales_gubun = 'U' Then 'Inisis'
							Else a.pg_tid
					   End,
		h_memo3		= null,
		b_biz		= 'BK10',
		b_goodGubun	= 'SO',
		b_seq		= 1,
		b_storeCode	= 'MF03',
		b_date		= Convert(char(8),a.delivery_date,112),
		b_goodCode	= b.Card_ErpCode, --b.item_type
		b_goodUnit	= 'EA',
		b_OrderNum	=  Case 
							When b.Card_ErpCode = 'BSI010' Then (b.order_count/50)*6 
							Else b.order_count 
						End,	
		
		------------------------------------------------------------------------------------------------------------------


		--**************************************************************************************************************
		--   * 아이템별 금액 셋팅
		--**************************************************************************************************************
		b_unitPrice	 =  Case
							When b.Card_ErpCode = 'TBB' Then b.item_Price				
							Else e.c_sobi
    					End,
					
		b_offerPrice =  Case
							When b.Card_ErpCode = 'TBB' Then Round(b.item_Price/1.1,0)				
							Else Round(e.c_sobi*b.order_count/1.1,0)
						End,	
		b_superTax	 =  Case
							When b.Card_ErpCode = 'TBB' Then b.item_Price - Round(b.item_Price/1.1,0)						
							Else (e.c_sobi*b.order_count) - Round(e.c_sobi*b.order_count/1.1,0)
						End,	
		b_sumPrice	 =  Case
							When b.Card_ErpCode = 'TBB' Then b.item_Price							
							Else e.c_sobi*b.order_count
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
					--		When Convert(char(8),a.settle_Date,112) >= '20090316' Then 
					--			dbo.getPGFee (a.pg_shopid, a.settle_method, a.settle_price,  
					--					Case
					--						When pg_resultinfo like '국민%'		Then '국민'	
					--						When pg_resultinfo like '씨티%'		Then '국민'		
					--						When pg_resultinfo like '농협%'		Then '국민'	
					--						When pg_resultinfo like '외환%'		Then '외환'		
					--						When pg_resultinfo like '산은%'		Then '외환'	
					--						When pg_resultinfo like '비씨%'		Then '비씨'
					--						When pg_resultinfo like '하나%'		Then '비씨'
					--						When pg_resultinfo like '구 LG%'	Then 'LG'
					--						When pg_resultinfo like '삼성%'		Then '삼성'
					--						When pg_resultinfo like '현대%'		Then '현대'
					--						When pg_resultinfo like '롯데%'		Then '롯데'
					--						When pg_resultinfo like '신한%'		Then '신한'			
					--						When pg_resultinfo like '수협%'		Then '신한'				
					--						When pg_resultinfo like '제주%'		Then '신한'						 
					--						When pg_resultinfo like '광주%'		Then '신한'				
					--						When pg_resultinfo like '전북%'		Then '신한'	
					--					End)
					--		Else dbo.getPGFee_New (a.pg_shopid, a.settle_method, a.settle_price) --2009년 3월 16일 결제부터 새로운 PG수수료율 적용			
					--End,

		------------------------------------------------------------------------------------------------------------------
		ItemGubun	= 'item',


		--**************************************************************************************************************
		--   * PG체크
		--**************************************************************************************************************
		PGCheck		= Case 
		
							When a.sales_gubun = 'W' Then	'Y'	--바른손카드
							When a.sales_gubun = 'T' Then	'Y'	--더카드
							--When a.sales_gubun = 'U' Then	'N'	--투유			--'U' : (구)2u카드 제외
							When a.sales_gubun = 'J' Then	'Y'	--제휴
							When a.sales_gubun = 'B' Then	'Y'	--제휴 
							When a.sales_gubun = 'S' Then	'Y'	--스토리러브
							When a.sales_gubun = 'X' Then	'Y'	--시즌
							When a.sales_gubun = 'G' Then	'Y'
							When a.sales_gubun = 'SB' Then 'Y'	--바른손카드	김성동
							When a.sales_gubun = 'SW' Then 'Y'	--위시메이드	기형석
							When a.sales_gubun = 'SS' Then 'Y'	--스토리오브러브	김성동
							When a.sales_gubun = 'SH' Then 'Y'	--해피카드	기형석
							When a.sales_gubun = 'SP' Then 'Y'	--Wpaper	최문정
						End	,
		------------------------------------------------------------------------------------------------------------------


		PayAmnt		= 0,
		SampleCheck	= 'N',
		XartCheck	= 'N',
		SettleDate	= null,
		PayDate		= null,
		PayCheck	= null,
		DealAmnt	= null,
		b_memo_temp	= null,
		DeptGubun	= Case 
		
							When a.sales_gubun = 'W' Then	'BA'	
							When a.sales_gubun = 'T' Then	'TH'	
							--When a.sales_gubun = 'U' Then	'TU'	--기형석				--'U' : (구)2u카드 제외
							When a.sales_gubun = 'J' Then	'BR'	--김성동
							When a.sales_gubun = 'B' Then	'BR'	--김성동 
							When a.sales_gubun = 'S' Then	'SI'	--기형석
							When a.sales_gubun = 'X' Then	'TI'	--김성동
							When a.sales_gubun = 'G' Then	'AG'
							When a.sales_gubun = 'SB' Then 'SB'	--바른손카드	김성동
							When a.sales_gubun = 'SW' Then 'SW'	--위시메이드	기형석
							When a.sales_gubun = 'SS' Then 'SS'	--스토리오브러브	김성동
							When a.sales_gubun = 'SH' Then 'SH'	--해피카드	기형석
							When a.sales_gubun = 'SP' Then 'SP'	--Wpaper	최문정
						End	
	FROM #custom_etc_order a 
	JOIN (
			SELECT order_seq, card_seq, Card_ErpCode, order_count, item_price FROM 
				(
				--기본 주문정보
				SELECT a.order_seq, b.card_seq, c.Card_ErpCode, b.order_count, b.card_sale_price as item_price 
				FROM #custom_etc_order a JOIN custom_etc_order_item b 
				ON a.order_seq = b.order_seq
				JOIN #CardMaster c ON b.card_seq = c.card_seq
				WHERE 
				Convert(char(8),delivery_date,112) between @SDate and @EDate
				and a.status_seq = 12 
				and a.order_type in ('F','P')
				and ISNULL(a.sales_gubun, '') <> 'D' 
				and b.order_count >0
				
				) z
				
				UNION
				
				--택배비
				SELECT order_seq,123,  'TBB' as Card_ErpCode ,1 as order_count ,delivery_price as item_price
				FROM #custom_etc_order  
				WHERE 
				Convert(char(8),delivery_date,112) between @SDate and @EDate
				and delivery_price > 0
				and status_seq = 12 
				and order_type in ('F','P')
				and ISNULL(sales_gubun, '') <> 'D'  
				and ISNULL(sales_gubun, '') <> 'O' 
						
			
		
		) b ON a.order_seq = b.order_seq
		JOIN company c ON a.company_seq = c.company_seq
		--JOIN #CardMaster d ON b.card_seq = d.card_seq
		LEFT JOIN  OPENQUERY([erpdb.bhandscard.com], 'SELECT  IsNull(stdPurprice,0) as stdPurprice, IsNull(c_sobi,0) as c_sobi,itemcode,itemgroup FROM XERP.DBO.itemSiteMaster WHERE SiteCode = ''BK10''') e ON b.Card_ErpCode = e.itemCode


	WHERE Convert(char(8),a.delivery_date,112) between @SDate and @EDate
		and a.status_seq = 12 
		and a.order_type in ('F','P')
		and ISNULL(a.sales_gubun, '') <> 'D' 
		and a.sales_gubun in ('W','T','J','B','S','X','G', 'SB', 'SW', 'SS', 'SH', 'SP') --20090804 이상민추가			--'U' : (구)2u카드 제외
		and ISNULL(a.pg_shopid, '') <> 'tiaracard1' 
		--and a.src_erp_date is null  
	ORDER BY a.order_seq 





--**************************************************************************************************************
-- --4. e청첩장 
--**************************************************************************************************************
	INSERT INTO #erp_salesReport ( 	h_biz,
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
		h_date		= Convert(char(8),a.settle_date,112),
		h_sysCode	= @SysCode1,
		h_usrCode	= @UsrCode1, 	

		--**************************************************************************************************************
		--   * 거래처코드 (company_seq로 구분)
		--**************************************************************************************************************
		h_comcode	=  Case
							When a.sales_gubun = 'W' Then '1450004'
							When a.sales_gubun = 'T' Then '1450007'
							--When a.sales_gubun = 'U' Then '17577'					--'U' : (구)2u카드 제외
							--When a.sales_gubun = 'A' Then '1489997'  --티아라는 마젠타 매출로
							When a.sales_gubun = 'O' Then '1450004'  --웨딩에서 결제되는거 바른손으로 준다.
							When a.sales_gubun = 'B' Then '1489998'
							When a.sales_gubun = 'G' Then '1450066'
							When a.sales_gubun = 'SB' Then '1450071'	--바른손카드
							When a.sales_gubun = 'SW' Then '1450072'	--위시메이드
							When a.sales_gubun = 'SS' Then '1450073'	--스토리오브러브
							When a.sales_gubun = 'SH' Then '1450074'	--해피카드
							When a.sales_gubun = 'SP' Then '1450075'	--Wpaper
							
						End, 
		------------------------------------------------------------------------------------------------------------------


		--**************************************************************************************************************
		--   * 과세유형
		--**************************************************************************************************************
		 h_taxType	=	Case
							When a.sales_gubun = 'W' Then '22'
							When a.sales_gubun = 'T' Then '22'
							--When a.sales_gubun = 'U' Then '10'				--'U' : (구)2u카드 제외
							--When a.sales_gubun = 'A' Then '10'  --티아라는 마젠타 매출로
							When a.sales_gubun = 'O' Then '22'  --웨딩에서 결제되는거 바른손으로 준다.
							When a.sales_gubun = 'B' Then '22'
							When a.sales_gubun = 'G' Then '22'
							When a.sales_gubun = 'SB' Then '22'	--바른손카드
							When a.sales_gubun = 'SW' Then '22'	--위시메이드
							When a.sales_gubun = 'SS' Then '22'	--스토리오브러브
							When a.sales_gubun = 'SH' Then '22'	--해피카드
							When a.sales_gubun = 'SP' Then '22'	--Wpaper
						End, 
		------------------------------------------------------------------------------------------------------------------

		
		h_offerPrice	= Round(a.settle_price/1.1,0),				
		h_superTax		= Round(a.settle_price- a.settle_price/1.1,0),	
		h_sumPrice		= a.settle_price,	


		--**************************************************************************************************************
		--담당자 정보 및 기타 헤더 정보
		--**************************************************************************************************************
		h_partCode	=	Case 
							When a.sales_gubun = 'W' Then '510'
							When a.sales_gubun = 'T' Then '380'
							--When a.sales_gubun = 'U' Then '550'				--'U' : (구)2u카드 제외
							When a.sales_gubun = 'O' Then '510'  --웨딩에서 결제되는거 바른손으로 준다.
							When a.sales_gubun = 'B' Then '390'						
							When a.sales_gubun = 'G' Then '890'		
							When a.sales_gubun = 'SB' Then 'N110'	--바른손카드
							When a.sales_gubun = 'SW' Then 'N210'	--위시메이드
							When a.sales_gubun = 'SS' Then 'N130'	--스토리오브러브
							When a.sales_gubun = 'SH' Then 'N220'	--해피카드
							When a.sales_gubun = 'SP' Then 'N120'	--Wpaper			
						End	,				
		h_staffcode	= Case 
		
							When a.sales_gubun = 'W' Then	'030603'	--김성동
							When a.sales_gubun = 'T' Then	'090501'	--기형석
							--When a.sales_gubun = 'U' Then	'090501'	--기형석				--'U' : (구)2u카드 제외
							When a.sales_gubun = 'O' Then	'030603'	--김성동
							When a.sales_gubun = 'B' Then	'030603'	--김성동 	
							When a.sales_gubun = 'G' Then	'080403'		
										
							When a.sales_gubun = 'SB' Then '030603'	--바른손카드	김성동
							When a.sales_gubun = 'SW' Then '100906'	--위시메이드	기형석->배종희
							When a.sales_gubun = 'SS' Then '030603'	--스토리오브러브	김성동
							When a.sales_gubun = 'SH' Then '030603'	--해피카드	기형석->김성동
							When a.sales_gubun = 'SP' Then '100906'	--Wpaper	최문정->배종희
							
							
						End	,   			
		h_sonik		= '110',
		h_cost		= Case 
		
							When a.sales_gubun = 'W' Then	'117'	
							When a.sales_gubun = 'T' Then	'143'	
							--When a.sales_gubun = 'U' Then	'149'	--기형석				--'U' : (구)2u카드 제외
							When a.sales_gubun = 'O' Then	'148'	--김성동
							When a.sales_gubun = 'B' Then	'148'	--김성동 						
							When a.sales_gubun = 'G' Then	'155'
							When a.sales_gubun = 'SB' Then '117'	--바른손카드	김성동
							When a.sales_gubun = 'SW' Then '143'	--위시메이드	기형석
							When a.sales_gubun = 'SS' Then '117'	--스토리오브러브	김성동
							When a.sales_gubun = 'SH' Then '143'	--해피카드	기형석
							When a.sales_gubun = 'SP' Then '117'	--Wpaper	최문정
						End	, 
						
		h_orderid	= Cast(a.pg_tid as varchar(20)),	
		h_memo1		= null,
		h_memo2		= Case
						When a.sales_gubun = 'U' Then 'Inisis'
						Else a.pg_tid
					  End,
		h_memo3		= null,
		b_biz		= 'BK10',
		b_goodGubun	= 'SO',
		b_seq		= 1,
		b_storeCode	= 'MF03',
		b_date		= Convert(char(8),a.settle_date,112),
		b_goodCode	= 'ON006',
		b_goodUnit	= 'EA',
		b_OrderNum	= 1,
		------------------------------------------------------------------------------------------------------------------


		--**************************************************************************************************************
		--   * 아이템별 금액 셋팅
		--**************************************************************************************************************
		b_unitPrice	 =  a.settle_price,
					
		b_offerPrice =  Round(a.settle_price/1.1,0),	
		b_superTax	 =  a.settle_price - Round(a.settle_price/1.1,0),	
		b_sumPrice	 =  a.settle_price,	
		------------------------------------------------------------------------------------------------------------------


			
		b_memo		= null,
		reg_date	= getdate(),

		--**************************************************************************************************************
		--   * PG수수료 (PG로 넘어가는 것은 수수료를 셋팅해 준다.)
		--   pgFee getPGFee 함수 호출 (pg아이디, 결제수단, 결제금액, 카드사정보)
		--**************************************************************************************************************
		FeeAmnt		=  dbo.getPGFee_New (a.pg_shopid, 
														Case	
															When a.settle_method = 'H' Then 5
															When a.settle_method = 'B' Then 3
															When a.settle_method = 'C' Then 2
														End
										,a.settle_price),

		------------------------------------------------------------------------------------------------------------------
		ItemGubun	= 'item',


		--**************************************************************************************************************
		--   * PG체크
		--**************************************************************************************************************
		PGCheck		= Case 
		
							When a.sales_gubun = 'W' Then	'Y'	--바른손카드
							When a.sales_gubun = 'T' Then	'Y'	--더카드
							--When a.sales_gubun = 'U' Then	'N'	--투유				--'U' : (구)2u카드 제외
							When a.sales_gubun = 'B' Then	'Y'	--제휴 
							When a.sales_gubun = 'O' Then	'Y'	--스토리러브
							When a.sales_gubun = 'G' Then	'Y'	--아가바른손
							When a.sales_gubun = 'SB' Then 'Y'	--바른손카드	김성동
							When a.sales_gubun = 'SW' Then 'Y'	--위시메이드	기형석
							When a.sales_gubun = 'SS' Then 'Y'	--스토리오브러브	김성동
							When a.sales_gubun = 'SH' Then 'Y'	--해피카드	기형석
							When a.sales_gubun = 'SP' Then 'Y'	--Wpaper	최문정
						End	,
		------------------------------------------------------------------------------------------------------------------
		PayAmnt		= 0,
		SampleCheck	= 'N',
		XartCheck	= 'N',
		SettleDate	= null,
		PayDate		= null,
		PayCheck	= null,
		DealAmnt	= null,
		b_memo_temp	= null,
		DeptGubun	= Case 
		
							When a.sales_gubun = 'W' Then	'BA'	
							When a.sales_gubun = 'T' Then	'TH'	
							--When a.sales_gubun = 'U' Then	'TU'	--기형석				--'U' : (구)2u카드 제외
							When a.sales_gubun = 'B' Then	'BR'	--김성동 
							When a.sales_gubun = 'O' Then	'WE'	--기형석
							When a.sales_gubun = 'G' Then	'AG'
							When a.sales_gubun = 'SB' Then 'SB'	--바른손카드	김성동
							When a.sales_gubun = 'SW' Then 'SW'	--위시메이드	기형석
							When a.sales_gubun = 'SS' Then 'SS'	--스토리오브러브	김성동
							When a.sales_gubun = 'SH' Then 'SH'	--해피카드	기형석
							When a.sales_gubun = 'SP' Then 'SP'	--Wpaper	최문정	
					  End	
	FROM the_ewed_order a 
	WHERE 
		AC_STATE='P' and settle_Status=2 and status_Seq=2 and order_result in ('3','4') 
		and Convert(char(8), settle_date, 112) BETWEEN @SDate and @EDate
		--and src_erp_date is null 
		and sales_gubun in ('W','T','J','B','S','X','G', 'SB', 'SW', 'SS', 'SH', 'SP')			--'U' : (구)2u카드 제외


--select * from the_ewed_order where order_id = '6385'
--select * from s2_ecardorder where Settle_date is not null and dacom_tid is not null and settle_status = 2


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
	UPDATE #erp_salesReport 
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

	FROM #erp_salesReport  b JOIN
		 (
		
		SELECT 
			h_orderid       = a.h_orderid,
			option_sumPrice = c.option_sumprice,
			b_sumPrice 		= b.b_sumprice,
			h_sumPrice 		= a.h_sumPrice,
			DiscountRate	= Case
								 When c.option_sumprice is  null  Then ((b.b_sumprice - a.h_sumprice)*100 )/ Replace(b.b_sumprice,0,1)
								 Else (((b.b_sumprice-c.option_sumprice) - (a.h_sumprice-c.option_sumprice))*100) / Replace((b.b_sumprice-c.option_sumprice),0,1)
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
	WHERE c.h_orderid is null


/*
-- src_erp_date 더이상 컬럼이 안써여져서 없어짐.

----**************************************************************************************************************
---- --ERP 업데이트 되었음을 표시함
----**************************************************************************************************************
	----청청장 업데이트
	UPDATE custom_order
	SET src_erp_date = Convert(char(10),getdate(),120)
	FROM custom_order a JOIN company c ON a.company_seq = c.company_seq
	WHERE 	status_seq = 15 
		and  Convert(char(8),src_send_date,112) between @SDate and @EDate
		and pay_type <> '4' 
		and ISNULL(pg_shopid, '') ='tiaracard1'
		and src_erp_date is null  
		and 
		(
		c.company_seq in (532,553,587,1186,2107)  --삼성카드 임직원, 삼성카드회원,결사모,결혼도움방, 마이e웨딩
		or
		a.sales_gubun = 'O' and c.jaehu_kind ='C'  and c.company_seq <> 15 -- 일단 웨딩사이트만 올림, 후불결제(ecSupport)는 추후에..
		)



	----샘플업데이트
	UPDATE custom_sample_order
	SET src_erp_date = Convert(char(10),getdate(),120)
	FROM custom_sample_order a JOIN company c ON a.company_seq = c.company_seq
	WHERE  status_seq = 12 
		and  Convert(char(8),delivery_Date,112) between @SDate and @EDate
		and src_erp_date is null  
		and 
		(
		c.company_seq in (532,553,587,1186,2107)  --삼성카드 임직원, 삼성카드회원,결사모,결혼도움방, 마이e웨딩
		or
		a.sales_gubun = 'O' and c.jaehu_kind ='C'  and c.company_seq <> 15 -- 일단 웨딩사이트만 올림, 후불결제(ecSupport)는 추후에..
		)


	----기타업데이트 
	UPDATE custom_etc_order
	SET src_erp_date = Convert(char(10),getdate(),120)
	FROM custom_etc_order a JOIN company c ON a.company_seq = c.company_seq
	WHERE 	Convert(char(8),a.delivery_date,112) between @SDate and @EDate
			and  a.status_seq = 12 
			and a.order_type in ('F','P')
			and 
			(
				c.company_seq in (532,553,587,1186,2107)  --삼성카드 임직원, 삼성카드회원,결사모,결혼도움방, 마이e웨딩
				or
				a.sales_gubun = 'O' and c.jaehu_kind ='C'  and c.company_seq <> 15 -- 일단 웨딩사이트만 올림, 후불결제(ecSupport)는 추후에..
			)
	
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
