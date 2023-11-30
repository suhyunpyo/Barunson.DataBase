IF OBJECT_ID (N'dbo.sp_ERP_Transfer_Photobook_20090605', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_ERP_Transfer_Photobook_20090605
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE            procedure [dbo].[sp_ERP_Transfer_Photobook_20090605]
 @SDate as char(8),
 @EDate as char(8)
as

set nocount on


--자료 Reporting을 위한 임시 테이블 생성      
Declare @Report  Table  (      
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
     




INSERT INTO @Report  (
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
	h_biz 			= 'BK10',
	h_gubun 		= 'SO',
	h_date 			= Convert(char(8),delivery_date,112),
	syscode 		= '270' ,
	usrCode 		= '270'  , 	
	h_comcode 		= '1450064',	
	h_TaxType 		= '22',
	h_offerPrice 		=  CAST(settle_price/1.1 as int),
	h_superTax 		= (settle_price - (CAST(settle_price/1.1 as int))),
	h_sumPrice 		= settle_price,
	h_optionPrice                     = 0,
	h_partCode 		='880',
	h_staffCode 		= '030603',
	h_sonik 			= '110',
	h_cost 			= '100',
	h_orderid 		= pg_tid,
	h_memo1		= null,
	h_memo2 		= pg_tid,
	h_memo3		= null,
	b_biz 			= 'BK10',
	b_goodGubun 		= 'SO',
	b_seq 			= 1,	
	b_storeCode 		= 'MF03',
	b_date 			=  Convert(char(8),delivery_date,112),
	b_goodCode 		=  Case 
					When c.itemCode = 'TBB' Then 'TBB'
					Else erp_code
				     End	,
	b_goodUnit 		= 'EA',
	--할인율
	--disrate  = (-reduce_price*100)/(settle_price - reduce_price),
	b_orderNum 		=  SUM(item_count)  ,
	b_unitPrice 		=  Case 
	                      			When c.itemCode = 'TBB' Then CAST(2500/1.1 as int)
				    Else c.item_price
		         		    End,	
	b_offerPrice 		= Case 
	                      			When c.itemCode = 'TBB' Then CAST(2500/1.1 as int)
					Else CAST(c.item_price*count(*)/1.1 as int)
		         		    End,	

	b_superTax 		= Case 
	                      			When c.itemCode = 'TBB' Then (2500 - (CAST(2500/1.1 as int)))
					Else (c.item_price*count(*) - (CAST(c.item_price*count(*)/1.1 as int)))
		        		   End,	

	b_sumPrice 		=  Case 
	                      			When c.itemCode = 'TBB' Then 2500
					Else c.item_price*count(*)
		         		   End,
	b_memo			= null,
	reg_date			= getdate(),
	--FeeAmnt 		= dbo.getPGFee ('zzico', settle_method, settle_price,  Case
	--								                 When pg_resultinfo like '국민%' then '국민'	
	--									   When pg_resultinfo like '씨티%' then '국민'		
	--									   When pg_resultinfo like '농협%' then '국민'	
	--								  	   When pg_resultinfo like '외환%' then '외환'		
	--								                 When pg_resultinfo like '산은%' then '외환'	
	--									   When pg_resultinfo like '비씨%' then '비씨'
	--									   When pg_resultinfo like '하나%' then '비씨'
	--								                 When pg_resultinfo like '구 LG%'   then 'LG'
	--								                 When pg_resultinfo like '삼성%'   then '삼성'
	--								                 When pg_resultinfo like '현대%'   then '현대'
	--									   When pg_resultinfo like '롯데%'   then '롯데'
	--									   When pg_resultinfo like '신한%'   then '신한'			
	--									   When pg_resultinfo like '수협%'   then '신한'				
	--								                 When pg_resultinfo like '제주%'   then '신한'						 
	--									   When pg_resultinfo like '광주%'   then '신한'				
	--									   When pg_resultinfo like '전북%'   then '신한'					
	--								             End		
	--			),
				
	FeeAmnt		= dbo.getPGFee_New ('zzico', settle_method, settle_price), --2009년 3월 16일 결제부터 새로운 PG수수료율 적용			
	itemGubun 		= 'item',
	PGCheck 		= 'Y',
	PayAmnt			= 0,
	SampleCheck 		= 'N',
	XartCheck 		= 'N',
	SettleDate		= null,
	PayDate			= null,
	PayCheck		= null,
	DealAmnt		= null,
	b_memo_temp		= null,
	DeptGubun 		= 'ZI'

		     
FROM  photobook_order a join photobook_order_detail_erp b ON a.id = b.order_id 
LEFT JOIN   
	--택배비
	(
	SELECT id, erp_code as itemCode, b.item_price as item_price
	FROM  photobook_order a JOIN photobook_order_detail_erp b ON a.id = b.order_id
	WHERE  Convert(char(8),delivery_date,112) between @SDate and @EDate  	
	UNION
	SELECT id,'TBB' as itemCode, delivery_price as item_price
	FROM  photobook_order a JOIN photobook_order_detail_erp b ON a.id = b.order_id
	WHERE  Convert(char(8),delivery_date,112) between @SDate and @EDate and  delivery_price > 0	
	)  c
ON a.id  = c.id and  (b.erp_code = c.itemCode or c.itemCode = 'TBB')

WHERE status_seq = 12 
and src_erp_date is null 
and pay_type <> 4 --사고건이 아닌것
and Convert(char(8),delivery_date,112) between @SDate and @EDate
GROUP BY a.pg_tid, b.erp_code, a.settle_price,a.delivery_price, a.delivery_date,a.settle_method, a.pg_resultinfo,b.item_sale_price,a.order_price,c.item_price, c.itemCode
ORDER BY  pg_tid  DESC







SELECT * FROM @Report

GO
