IF OBJECT_ID (N'dbo.sp_ERP_Transfer_Daeri', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_ERP_Transfer_Daeri
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ##########################################################################################################      
-- 온라인 대리점 (참카드 등)
-- ########################################################################################################## 
--EXEC sp_ERP_Transfer_Daeri '20100701', '20100721'

CREATE                    procedure [dbo].[sp_ERP_Transfer_Daeri]
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
	DeptGubun	char(2) 		NOT NULL
	 )    
     
-----------------------------------------------------------  
-- * ERP 연동 조건

--대리점가 기준으로 판매금액 설정
--샘플은 참카드에서 직접 발송 (유사미 매출로 안잡힘)
-----------------------------------------------------------  

--1.청첩장
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
	h_date		= Convert(char(8),a.src_send_date,112),
	h_sysCode	= '270',
	h_usrCode	= '270',
	h_comcode	= c.erp_code,
	h_taxType	= '10',
	h_offerPrice	= 0 ,							-- 헤더 합계 금액 0으로 해 놓고 아래에서 업데이트 시킴
	h_superTax	= 0,
	h_sumPrice	= 0,
	--h_partCode	=  Case					
	--	      	   	When e.itemGroup in ('G2000','P1100') Then '830' 	-- 위시메이드일 경우 830으로 잡힘
	--		    	Else '350'
	--                         	    End,			
	h_partCode	=  '300',	--대리점영업으로 통합함 20100701		
	--h_staffcode	=  Case
	--				When e.itemGroup in ('G2000','P1100') Then '980404'
	--				Else '040401'    -- 20081201일부터 김용채 매출로 다시 잡힘	 
	--			   End,	 	              
	h_staffcode	=  '040401',		  -- 20100701일부터 김용재 매출로만 잡히도록 수정.
	h_sonik		= '110',
	h_cost		= '109',
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
	b_unitPrice	= Case 
						When b.item_type = 'M'	 	Then 50       --미니청첩장일 경우 50원으로 넘겨줌
						When b.item_type = 'TBB' 	Then 2000
						When b.item_type = 'SASIK' 	Then 3500
						When b.item_type = 'PANBI' 	Then 2000
						When b.item_type = 'JAEBON' Then 30
						When b.item_type = 'PRTCHG'	Then 5
					Else e.c_daeri
				   End ,
	b_offerPrice	= Case 
							When b.item_type = 'M' 		Then Round(50/1.1,0)  *b.item_count    --미니청첩장일 경우 50원으로 넘겨줌
							When b.item_type = 'TBB' 	Then Round(2000/1.1,0)
							When b.item_type = 'SASIK' 	Then Round(3500/1.1,0)
							When b.item_type IN ('PANBI', 'JAEBON', 'PRTCHG') 	Then Round(b.item_price/1.1,0)
							When b.item_type = 'F'	Then 0	--식권 무료 20100701
						Else Round( (e.c_daeri*b.item_count)/1.1, 0 ) 
					   End ,
	b_superTax	= Case 
						When b.item_type = 'M' 			Then (50 * b.item_count) - Round(50/1.1,0)  *b.item_count
						When b.item_type = 'TBB' 		Then 2000 - Round(2000/1.1,0)
						When b.item_type = 'SASIK' 		Then 3500 - Round(3500/1.1,0)
						When b.item_type IN ('PANBI', 'JAEBON', 'PRTCHG') Then b.item_price - Round(b.item_price/1.1,0)
						When b.item_type = 'F'	Then 0	--식권 무료 20100701
					Else Round( e.c_daeri*b.item_count, 0 ) - Round( (e.c_daeri*b.item_count)/1.1, 0 ) 
				   End ,

	b_sumPrice	= Case 
					When b.item_type = 'M' 		Then 50 * b.item_count
					When b.item_type = 'TBB' 	Then 2000
					When b.item_type = 'SASIK' 	Then 3500 
					When b.item_type IN ('PANBI', 'JAEBON', 'PRTCHG') Then b.item_price 
					When b.item_type = 'F'	Then 0	--식권 무료 20100701
					ELSE ROUND( e.c_daeri * b.item_count, 0) 
				   End ,
	b_memo		= null,
	reg_date		= getdate(),
	FeeAmnt		= 0,
	ItemGubun	= 'item',
	PGCheck	= 'N',
	PayAmnt		= 0,
	SampleCheck	= 'N',
	XartCheck	= 'N',
	SettleDate	= null,
	PayDate		= null,
	PayCheck	= null,
	DealAmnt	= null,
	b_memo_temp	= null,
	DeptGubun	= 'DE'
FROM 
	custom_order a JOIN  (
				SELECT order_seq,card_seq, card_code,item_type, item_count, item_price
				FROM 
					(
					--기본 아이템 정보 (청첩장, 청첩장과 함께 주문하는 식권, 미니청첩장 포함)
					SELECT  a.order_seq, b.card_seq,c.card_code, b.item_type,b.item_count as item_count , item_price
					FROM custom_order a 
					JOIN  custom_order_item b ON  a.order_seq = b.order_seq
					JOIN card c ON b.card_seq = c.card_seq
					WHERE Convert(char(8),a.src_send_date,112) between @SDate and @EDate and pay_type <> '4' and sales_gubun ='D' 
						and src_printer_seq <= 2 and company_seq  = 237
						and c.card_seq <> 15150 --신세계 상품권은 안가져옴
					
					 ) c

					UNION
					--기본 택배비 청구  (추가 배송지 없음)
					(
						SELECT  order_seq, 111 as card_seq ,'TBB' as card_code,'TBB' as item_type,1 as item_count ,  2000 as item_price
						FROM custom_order WHERE Convert(char(8),src_send_date,112) between @SDate and @EDate
						and pay_type <> '4' and sales_gubun ='D' and src_printer_seq <= 2 and company_seq  = 237
					)	
					UNION
					--기본사식
					(
						SELECT  order_seq, 222 as card_seq ,'SASIK' as card_code,'SASIK' as item_type,1 as item_count ,  3500 as item_price
						FROM custom_order WHERE Convert(char(8),src_send_date,112) between @SDate and @EDate
						and pay_type <> '4' and sales_gubun ='D' and src_printer_seq <= 2 and company_seq  = 237
					)	

					UNION
					--판비
					(								
					
						SELECT   a.order_seq, 555, 'PANBI' as card_code,'PANBI' as item_type
								, item_count = count(a.Order_seq)
								, item_price =  count(a.Order_seq) * 2000
						FROM Custom_Order a 
						JOIN custom_order_plist b ON a.order_seq = b.order_seq AND b.print_count > 0
						WHERE Convert(char(8),a.src_send_date,112) between @SDate and @EDate
							and a.pay_type <> '4' 
							and a.sales_gubun ='D' and a.src_printer_seq <= 2 
							and company_seq  = 237
							and b.print_type <> 'M'	--미니청첩장 판수는 제외
							and b.isFPrint = '0' and b.isNotPrint ='0'
						
						GROUP BY a.order_seq


					)  
								
					UNION   
					--제본
					(
					SELECT   order_seq, 444, 'JAEBON' as card_code,'JAEBON',  order_count, order_count * 30 as item_price
					FROM Custom_Order 
					WHERE Convert(char(8),src_send_date,112) between @SDate and @EDate and  JEBON_price > 0 and pay_type <> '4' 
						and sales_gubun ='D' and src_printer_seq <= 2 and company_seq  = 237
					)  

					UNION
					--인쇄비   ex)주문수량 400매 경우 카드 400매 + 봉투 400매해서 800매 * 2를 함					
					(
					SELECT a.order_seq,666,'PRTCHG' as card_code, 'PRTCHG', sum(print_count), sum(print_count)*2  
					FROM custom_order a 
					JOIN custom_order_plist b ON a.order_seq = b.order_seq 
					WHERE Convert(char(8),src_send_date,112) between @SDate and @EDate
					and pay_type <> '4' and sales_gubun ='D' and src_printer_seq <= 2 and company_seq  = 237
					and  b.isNotPrint = '0' and b.print_type in ('E','C','I')
					GROUP BY a.order_seq
					)  			
					
				) b ON a.order_seq = b.order_seq
JOIN company c ON a.company_seq = c.company_seq
JOIN card d ON b.card_seq = d.card_seq
LEFT JOIN  OPENQUERY([erpdb.bhandscard.com], 'SELECT  ItemCode, c_daeri FROM XERP.DBO.itemSiteMaster WHERE SiteCode=''BK10'' and itemuse = ''Y''') e ON d.card_code = e.itemCode

WHERE Convert(char(8),a.src_send_date,112) between @SDate and @EDate 
	and status_seq = 15
	and a.pay_type <> '4' 
	and a.sales_gubun ='D' 
	and a.src_printer_seq <= 2 
	and a.company_seq  = 237 
	--and src_erp_date is null 
ORDER BY a.order_seq 


--2.샘플
--참카드 샘플은 자체 발송하므로 매출 연동 안함



--3. 미니청첩장 및 식권 등 옵션 상품 따로 주문시 
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
	h_comcode	= c.erp_code,
	h_taxType	= '10',
	h_offerPrice	= 0 ,							-- 헤더 합계 금액 0으로 해 놓고 아래에서 업데이트 시킴
	h_superTax	= 0,
	h_sumPrice	= 0,
	h_partCode	= '300',			
	h_staffcode	= '040401',				
	h_sonik		= '110',
	h_cost		= '109',
	h_orderid	= a.pg_tid,
	h_memo1	= null,
	h_memo2	= a.pg_tid,
	h_memo3	= null,
	b_biz		= 'BK10',
	b_goodGubun	= 'SO',
	b_seq		= 1,
	b_storeCode	= 'MF03',
	b_date		= Convert(char(8),a.delivery_date,112),
	b_goodCode	= b.card_code, --b.item_type
	b_goodUnit	= 'EA',
	b_OrderNum	= b.item_count,
	b_unitPrice	=e.c_daeri,
	b_offerPrice = CASE WHEN a.Order_type = 'F' THEN 0 ELSE Round( (e.c_daeri*b.item_count)/1.1, 0 ) END, 
	b_superTax	= CASE WHEN a.Order_type = 'F' THEN 0 ELSE Round( e.c_daeri*b.item_count, 0 )- Round( (e.c_daeri*b.item_count)/1.1, 0 ) END, 
	b_sumPrice	= CASE WHEN a.Order_type = 'F' THEN 0 ELSE Round( e.c_daeri*b.item_count, 0 ) END, 
	b_memo		= null,
	reg_date		= getdate(),
	FeeAmnt		= 0,
	ItemGubun	= 'item',
	PGCheck	= 'N',
	PayAmnt		= 0,
	SampleCheck	= 'N',
	XartCheck	= 'N',
	SettleDate	= null,
	PayDate		= null,
	PayCheck	= null,
	DealAmnt	= null,
	b_memo_temp	= null,
	DeptGubun	= 'DE'

FROM custom_etc_order a 
JOIN  (
			SELECT order_seq,card_seq, card_code,item_type, item_count, item_price
			FROM 
				(
				--기본 아이템 정보
				SELECT  a.order_seq, b.card_seq,c.card_code, 'FOOD' as item_type, b.order_count as item_count ,  b.card_price as item_price
				FROM custom_etc_order a JOIN  custom_etc_order_item b ON  a.order_seq = b.order_seq
				JOIN card c ON b.card_seq = c.card_seq
				WHERE Convert(char(8),a.delivery_date,112) between @SDate and @EDate and sales_gubun ='D' 
				and a.company_seq  = 237
				

				) c
				UNION
				--기본 택배비 청구  (추가 배송지 없음)
				(
				SELECT  order_seq, 111 as card_seq ,'TBB' as card_code,'TBB' as item_type,1 as item_count ,  2000 as item_price
				FROM custom_order WHERE Convert(char(8),src_send_date,112) between @SDate and @EDate
				and sales_gubun ='D'  and  company_seq  = 237
				)	
	
	) b ON a.order_seq = b.order_seq
JOIN company c ON a.company_seq = c.company_seq
JOIN card d ON b.card_seq = d.card_seq
LEFT JOIN  OPENQUERY([erpdb.bhandscard.com], 'SELECT  itemCode, c_daeri  FROM XERP.DBO.itemSiteMaster WHERE SiteCode=''BK10'' and itemuse = ''Y''') e ON d.card_code = e.itemCode



WHERE 	A.status_seq = 12
	and Convert(char(8),A.delivery_date,112) >= @SDate and Convert(char(8),A.delivery_date,112) <= @EDate
	and a.sales_gubun='D' 
	and a.company_seq  = 237

--and A.src_erp_date is null 
ORDER BY a.order_seq 


----위시메이드 카드의 경우 전체 주문건 위시메이드 부서로 변경 (2009.02.10) 
--UPDATE @erp_salesReport
--SET h_partCode = '830', h_cost = '138', h_staffCode = '980404'
--WHERE h_orderid in (SELECT h_orderid FROM @erp_salesReport WHERE h_partCode ='830')


--단수 차이나는 것 위해 Update
UPDATE @erp_salesReport
SET b_sumPrice = b_offerPrice + b_superTax



--BH4021_I 내지는 수량이 반만 출고가 되도록 진행 (정광수차장 요청) 20141230
UPDATE @erp_salesReport
SET b_OrderNum = CEILING(ISNULL(b_OrderNum, 0)/2.0)
WHERE b_goodCode = 'BH4021_I' AND ISNULL(b_OrderNum, 0) > 0



--헤더 금액 update (아이템 금액의 합계로 Update)
UPDATE @erp_salesReport 
SET h_offerprice = b.b_offerPrice, h_superTax = b.b_superTax, h_sumPrice = b.b_sumPrice
FROM @erp_salesReport  a 
JOIN (	SELECT h_orderid, sum(b_offerprice) as b_offerPrice,sum(b_superTax) as b_superTax, sum(b_sumprice) as b_sumPrice 
		FROM @erp_salesReport GROUP BY h_orderid) b
ON a.h_orderid = b.h_orderid	



-- b_seq를 생성해 내기 위한 템프 테이블 생성
SELECT  IDENTITY(int, 1, 1) AS seq, h_OrderID, b_goodCode,b_unitprice
INTO #TempSEQ
FROM @erp_salesReport   
ORDER BY h_Orderid, b_goodcode


-- select * FROM @erp_salesReport  





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
				--ORDER BY a.h_OrderID, a.b_goodCode, GroupSerNo
			         ) b ON a.h_orderid = b.h_orderid and a.b_goodCode = b.b_goodCode
			        --erp_SalesData에 중복 입력 오류 방지		
			        LEFT JOIN OPENQUERY([erpdb.bhandscard.com], 'SELECT DISTINCT h_orderid FROM XERP.DBO.erp_salesData ')  c ON a.h_orderid = c.h_orderid
WHERE c.h_orderid is null			
				


--ERP 업데이트 되었음을 표시함
-- UPDATE custom_order
-- SET src_erp_date = Convert(char(10),getdate(),120)
-- WHERE 	Convert(char(8),src_send_date,112) >= @SDate and Convert(char(8),src_send_date,112) <= @EDate
-- 	and pay_type <> '4' and sales_gubun = 'D' and src_printer_seq <=2 and company_seq  = 237
-- 
-- 
-- 
-- UPDATE custom_etc_order
-- SET src_erp_date = Convert(char(10),getdate(),120)
-- WHERE 	status_seq = 12
-- 	and Convert(char(8),delivery_date,112) >= @SDate and Convert(char(8),delivery_date,112) <= @EDate
-- 	and sales_gubun='D' 
-- 	and company_seq  = 237
-- 
-- 




GO
