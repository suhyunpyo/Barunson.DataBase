IF OBJECT_ID (N'dbo.sp_ERP_Transfer_Tiara_20090318', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_ERP_Transfer_Tiara_20090318
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ##########################################################################################################      
-- 티아라 매출 연동 (08.08.18 부터 티아라 매출 분리, 마젠타 매출로 잡힘)
-- ########################################################################################################## 
--exec sp_ERP_Transfer_Tiara '20081015','20081015'
CREATE  procedure [dbo].[sp_ERP_Transfer_Tiara_20090318]
 @SDate as char(8),
 @EDate as char(8)
as

set nocount on

-- Declare @disRate smallint
-- 
-- Set @disRate = 0.75


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
	b_memo_temp	char(16) 	NULL,   --아이템 타입을 임시로 넣어 둔다.
	DeptGubun	char(2) 		NOT NULL
	 )    
     
-----------------------------------------------------------  
-- * ERP 연동 조건

--대리점가 기준으로 판매금액 설정
--샘플은 참카드에서 직접 발송 (유사미 매출로 안잡힘)
-----------------------------------------------------------  
-- 
-- -- --1.청첩장
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
	h_biz		 = 'BK10',
	h_gubun		 = 'SO',
	h_date		 = Convert(char(8),a.src_send_date,112),
	h_sysCode	 = '270',
	h_usrCode	 = '270',
	h_comcode	 = '1510050',                        -- 거래처 마젠타
	h_taxType	 = '10',							    -- 과세유형 일반과세
	h_offerPrice = 0 ,							-- 헤더 합계 금액 0으로 해 놓고 아래에서 업데이트 시킴
	h_superTax	 = 0,
	h_sumPrice	 = 0,
	h_partCode	 = '870',				
	h_staffcode	 = '030603',				
	h_sonik		 = '110',
	h_cost		 = '152',
	h_orderid	 = a.pg_tid,
	h_memo1	     = null,
	h_memo2	     = a.pg_tid,
	h_memo3	     = null,
	b_biz		 = 'BK10',
	b_goodGubun	 = 'SO',
	b_seq		 = 1,
	b_storeCode	 = 'MF03',
	b_date		 = Convert(char(8),a.src_send_date,112),
	b_goodCode	 = b.card_code, --b.item_type
	b_goodUnit	 = 'EA',
	b_OrderNum	 = b.item_count,
	b_unitPrice	= Case 
					When b.item_type = '수수료'	Then b.item_Price      
					When e.itemGroup = 'G2100' 	Then e.stdPurprice
					Else e.c_chool
				  End ,
	b_offerPrice	= Case 
						When b.item_type = '수수료'	Then Round(b.item_price/1.1,0)
						When e.itemGroup = 'G2100' 	Then Round(e.stdPurprice*b.item_count/1.1,0)
						Else Round(e.c_chool*0.75*b.item_count/1.1,0)   --출고가에 25% 할인된 금액으로 넘김
					  End ,
	b_superTax	= Case 
				When b.item_type = '수수료'	Then Round(b.item_price,0) - Round(b.item_price/1.1,0)		
				When e.itemGroup = 'G2100' 	Then Round(e.stdPurprice*b.item_count,0)- Round(e.stdPurprice*b.item_count/1.1,0)
				Else Round(e.c_chool*0.75*b.item_count,0)-(Round(e.c_chool*0.75*b.item_count/1.1,0))
			   End ,

	b_sumPrice	= Case 
				When b.item_type = '수수료'	Then b.item_price
				When e.itemGroup = 'G2100' 	Then (e.stdPurprice)*b.item_count
				Else Round(e.c_chool*0.75*b.item_count,0)
			   End ,
		
	b_memo		= null,
	reg_date	= getdate(),
	FeeAmnt		= 0,
	ItemGubun	= 'item',
	PGCheck	    = 'N',
	PayAmnt		= 0,
	SampleCheck	= 'N',
	XartCheck	= 'N',
	SettleDate	= null,
	PayDate		= null,
	PayCheck	= null,
	DealAmnt	= null,
	b_memo_temp	= b.item_type,   --티아라 카드의 경우 동일한 카드 2장이 나가는 경우가 있음. (하나는 카드 형태 하나는 내지형태.. 하지만 코드가 같은.. 뒤에 이를 구분해 주기 위해 필요)
	DeptGubun	= 'TI'
FROM 
	custom_order a JOIN  (
				SELECT order_seq,card_seq, card_code,item_type, item_count, item_price
				FROM 
					(
					--기본 아이템 정보 (청첩장,  청첩장과 함께 주문하는 식권, 미니청첩장, 별도로 주문하는 미니청첩장)
					SELECT  a.order_seq, b.card_seq,c.card_code, b.item_type,b.item_count as item_count ,  item_price
					FROM custom_order a JOIN  custom_order_item b ON  a.order_seq = b.order_seq
					JOIN card c ON b.card_seq = c.card_seq
					WHERE Convert(char(8),a.src_send_date,112) between @SDate and @EDate and pay_type <> '4' 
					and pg_shopid ='tiaracard1' and b.item_count > 0
					--GROUP BY a.order_seq, b.card_seq, c.card_code, b.item_type, item_price
					 ) c
				
					--수수료 정보 (결제금액 3만원 이상이면 수수료 2만5천원, 3만원 미만이면 5천원) 
					UNION
					SELECT order_seq, 1, '수수료', '수수료', 1, item_price  =  Case
												When settle_price >= 30000 Then 18000
												Else 5000
											     End	
					FROM custom_order
					WHERE Convert(char(8),src_send_date,112) between @SDate and @EDate and pay_type <> '4' 
					and pg_shopid ='tiaracard1'

				) b ON a.order_seq = b.order_seq
	JOIN company c ON a.company_seq = c.company_seq
	JOIN card d ON b.card_seq = d.card_seq
	LEFT JOIN  OPENQUERY([211.172.242.78], 'SELECT  IsNull(stdPurprice,0) as stdPurprice, IsNull(c_chool,0) as c_chool,itemcode,itemgroup FROM XERP.DBO.itemSiteMaster ') e ON d.card_code = e.itemCode

WHERE 
a.status_seq = 15 
and  Convert(char(8),a.src_send_date,112) between @SDate and @EDate
and pay_type <> '4' 
and pg_shopid ='tiaracard1'
and a.src_erp_date is null  
ORDER BY a.order_seq 

-- 
-- --2.샘플
-- -- 샘플 매출은 자사카드는 출고가 기준 10% 할인율 적용해서 올림
-- --      "  "         타사카드는 매입가 기준으로 올림
-- -- 배송비는 안올림
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
	h_sysCode	= '270',
	h_usrCode	= '270',
	h_comcode	= '1510050',
	h_taxType	= '10',							-- 과세유형 일반과세
	h_offerPrice	= 0 ,							-- 헤더 합계 금액 0으로 해 놓고 아래에서 업데이트 시킴
	h_superTax	= 0,
	h_sumPrice	= 0,
	h_partCode	= '870',				
	h_staffcode	= '030603',				
	h_sonik		= '110',
	h_cost		= '152',
	h_orderid	= a.pg_tid,
	h_memo1	= null,
	h_memo2	= a.pg_tid,
	h_memo3	= null,
	b_biz		= 'BK10',
	b_goodGubun	= 'SO',
	b_seq		= 1,
	b_storeCode	= 'MF03',
	b_date		= Convert(char(8),a.delivery_Date,112),
	b_goodCode	= e.itemcode, --b.item_type
	b_goodUnit	= 'EA',
	b_OrderNum	= 1,
	b_unitPrice	=  Case 
				When e.itemGroup = 'G2100' Then e.stdPurprice
				Else e.c_chool
			    End,			
	b_offerPrice	=  Case 
				When e.itemGroup = 'G2100' Then Round(e.stdPurprice/1.1,0)
				Else Round(e.c_chool*0.75/1.1,0)
			   End, 

	b_superTax	=  Case
				When e.itemGroup = 'G2100' Then Round(e.stdPurprice,0)- Round(e.stdPurprice/1.1,0)
				Else Round(e.c_chool*0.75,0)- Round(e.c_chool*0.75/1.1,0)
			   End,
	b_sumPrice	=  Case 
				When e.itemGroup = 'G2100' Then e.stdPurprice
				Else Round(e.c_chool*0.75,0)
			    End,	
	b_memo		= null,
	reg_date		= getdate(),
	FeeAmnt		= 0,
	ItemGubun	= 'item',
	PGCheck	= 'N',
	PayAmnt		= 0,
	SampleCheck	= 'Y',
	XartCheck	= 'N',
	SettleDate	= null,
	PayDate		= null,
	PayCheck	= null,
	DealAmnt	= null,
	b_memo_temp	= 'C',
	DeptGubun	= 'TI'
FROM 
	custom_sample_order a JOIN custom_sample_order_item b ON a.sample_order_seq = b.sample_order_seq
	--JOIN company c ON a.company_seq = c.company_seq
	JOIN card d ON b.card_seq = d.card_seq
	LEFT JOIN  OPENQUERY([211.172.242.78], 'SELECT  IsNull(stdPurprice,0) as stdPurprice, IsNull(c_chool,0) as c_chool,itemcode,itemgroup FROM XERP.DBO.itemSiteMaster ') e ON d.card_code = e.itemCode

WHERE 
a.status_seq = 12 
and  Convert(char(8),a.delivery_Date,112) between @SDate and @EDate
--and (pg_mertid ='tiaracard1' or (pg_mertid is null and Convert(char(8),a.delivery_Date,112) >= '20080820'))
and a.sales_gubun = 'A'
and a.src_erp_date is null  
ORDER BY a.sample_order_seq 


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
	h_comcode	= '1510050',
	h_taxType	= '10',							-- 과세유형 일반과세
	h_offerPrice	= 0 ,							-- 헤더 합계 금액 0으로 해 놓고 아래에서 업데이트 시킴
	h_superTax	= 0,
	h_sumPrice	= 0,
	h_partCode	= '870',				
	h_staffcode	= '030603',				
	h_sonik		= '110',
	h_cost		= '152',
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
	b_unitPrice	= Case 
				When b.item_type = '수수료'	Then b.item_Price      
				When e.itemGroup = 'G2100' 	Then e.stdPurprice
				Else e.c_chool

			   End ,
	b_offerPrice	= Case 
				When b.item_type = '수수료'	Then Round(b.item_price/1.1,0)
				When e.itemGroup = 'G2100' 	Then Round(e.stdPurprice*b.item_count/1.1,0)
				Else Round(e.c_chool*0.75*b.item_count/1.1,0)
			   End ,
	b_superTax	= Case 
				When b.item_type = '수수료'	Then b.item_price - Round(b.item_price/1.1,0)		
				When e.itemGroup = 'G2100' 	Then Round(e.stdPurprice*b.item_count,0)- Round(e.stdPurprice*b.item_count/1.1,0)
				Else Round(e.c_chool*0.75*b.item_count,0)- Round(e.c_chool*0.75*b.item_count/1.1,0)
			   End ,

	b_sumPrice	= Case 
				When b.item_type = '수수료'	Then b.item_price
				When e.itemGroup = 'G2100' 	Then (e.stdPurprice)*b.item_count
				Else Round(e.c_chool*0.75*b.item_count,0)
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
	b_memo_temp	= a.order_type,
	DeptGubun	= 'TI'
FROM 
	custom_etc_order a JOIN  (
				SELECT order_seq,card_seq, card_code,item_type, item_count, item_price
				FROM 
					(
					--기본 아이템 정보
					SELECT  a.order_seq, b.card_seq,c.card_code, 'FOOD' as item_type, b.order_count as item_count ,  b.card_price as item_price
					FROM custom_etc_order a JOIN  custom_etc_order_item b ON  a.order_seq = b.order_seq
					JOIN card c ON b.card_seq = c.card_seq
					WHERE Convert(char(8),a.delivery_date,112) between @SDate and @EDate
					and status_seq = 12  
					and order_type in ('F','P')
					and pg_shopid ='tiaracard1'
					--and src_erp_date is null
					) c
					UNION
					--수수료 정보 (결제금액 3만원 이상이면 수수료 2만5천원, 3만원 미만이면 5천원) 
					SELECT order_seq, 1, '수수료', '수수료', 1, item_price  =  Case
												When settle_price >= 30000 Then 18000
												Else 5000
											     End	
					FROM custom_etc_order
					WHERE Convert(char(8),delivery_date,112) between @SDate and  @EDate
					and status_seq = 12  
					and order_type in ('F','P')
					and pg_shopid ='tiaracard1'
					--and src_erp_date is null
		
				) b ON a.order_seq = b.order_seq
	JOIN company c ON a.company_seq = c.company_seq
	JOIN card d ON b.card_seq = d.card_seq
	LEFT JOIN  OPENQUERY([211.172.242.78], 'SELECT  IsNull(stdPurprice,0) as stdPurprice, IsNull(c_chool,0) as c_chool,itemcode,itemgroup FROM XERP.DBO.itemSiteMaster ') e ON d.card_code = e.itemCode


WHERE 	A.status_seq = 12
	and Convert(char(8),delivery_date,112) between @SDate and  @EDate
	and status_seq = 12  
	and order_type in ('F','P')
	and pg_shopid ='tiaracard1'
	and src_erp_date is null
ORDER BY a.order_seq 


--헤더 금액 update (아이템 금액의 합계로 Update)
UPDATE @erp_salesReport 
SET h_offerprice = b.b_offerPrice, h_superTax = b.b_superTax, h_sumPrice = b.b_sumPrice
FROM @erp_salesReport  a 
JOIN (SELECT h_orderid, sum(b_offerprice) as b_offerPrice,sum(b_superTax) as b_superTax,sum(b_sumprice) as b_sumPrice FROM @erp_salesReport GROUP BY h_orderid) b
ON a.h_orderid = b.h_orderid	




-- b_seq를 생성해 내기 위한 템프 테이블 생성
SELECT  IDENTITY(int, 1, 1) AS seq, h_OrderID, b_goodCode,b_unitprice,b_OrderNum,b_memo_temp
INTO #TempSEQ
FROM @erp_salesReport   
--GROUP BY h_orderID, b_goodCode, b_unitPrice, b_orderNum
ORDER BY h_Orderid, b_goodcode


-- 
-- --erp_salesData에 자료 Insert
INSERT INTO  OPENQUERY([211.172.242.78], 'SELECT  
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
	b.b_OrderNum,
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
FROM @erp_salesReport  a  JOIN (
				SELECT  A.h_OrderID, A.b_goodCode  , A.seq - B.MinSeq + 1 AS b_seq, a.b_orderNum,a.b_memo_temp
				FROM #TempSEQ  A JOIN (
							 SELECT h_OrderID, MIN(seq) AS MinSeq
							 FROM #TempSEQ
							 GROUP BY h_Orderid
							) B ON A.h_OrderID = B.h_OrderID
				--ORDER BY a.h_OrderID, a.b_goodCode, GroupSerNo
			         ) b ON a.h_orderid = b.h_orderid and a.b_goodCode = b.b_goodCode  and  a.b_memo_temp = b.b_memo_temp
			
			     --erp_SalesData에 중복 입력 오류 방지		
			     LEFT JOIN OPENQUERY([211.172.242.78], 'SELECT  h_orderid FROM XERP.DBO.erp_salesData ')  c ON a.h_orderid = c.h_orderid
WHERE c.h_orderid is null





-- --ERP 업데이트 되었음을 표시함
UPDATE custom_order
SET src_erp_date = Convert(char(10),getdate(),120)
WHERE 	status_seq = 15 
	and  Convert(char(8),src_send_date,112) between @SDate and @EDate
	and pay_type <> '4' 
	and pg_shopid ='tiaracard1'
	and src_erp_date is null  


UPDATE custom_sample_order
SET src_erp_date = Convert(char(10),getdate(),120)
WHERE  status_seq = 12 
	and  Convert(char(8),delivery_Date,112) between @SDate and @EDate
	and sales_gubun = 'A'
	and src_erp_date is null  

 
UPDATE custom_etc_order
SET src_erp_date = Convert(char(10),getdate(),120)
WHERE 	status_seq = 12
	and Convert(char(8),delivery_date,112) between @SDate and  @EDate
	and order_type in ('F','P')
	and pg_shopid ='tiaracard1'
	and src_erp_date is null








GO
