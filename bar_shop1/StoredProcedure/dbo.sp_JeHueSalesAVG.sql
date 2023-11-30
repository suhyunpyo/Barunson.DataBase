IF OBJECT_ID (N'dbo.sp_JeHueSalesAVG', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_JeHueSalesAVG
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec sp_JeHueSalesAVG '20080701', '20090229'
CREATE PROC [dbo].[sp_JeHueSalesAVG]
 @SDate as char(8),
 @EDate as char(8)
AS

set nocount on
SELECT 
'구분' = Case
			When a.sales_gubun = 'T' Then '더카드팀'
			When a.sales_gubun = 'O' Then '원덕규 제휴'
			When a.sales_gubun = 'D' Then '원덕규 제휴'
			When a.sales_gubun = 'B' Then '김성동 제휴'
			When a.sales_gubun = 'P' Then '아웃바운드'
		End ,
 b.company_name as  '제휴사' , AVG(Cast(a.order_total_price as bigInt)) as '평균객단가', (Sum(Cast(a.order_total_price as bigint))/Sum(a.order_count)) as '평균장당가격' ,
(100*(Sum(Cast(order_price as bigint))-Sum(Cast(order_total_price as bigint))))/Sum(Cast(order_price as bigint))  as '평균할인율'
FROM custom_order a JOIN company b ON a.company_seq = b.company_seq
WHERE 
Convert(char(8),a.src_send_date,112) between @SDate and @EDate
and a.status_seq = 15 
and a.pay_type <> '4' 
and a.order_Type <> '5'
and 
(
	a.company_seq in (532,553,587,1186,2107)  --삼성카드 임직원, 삼성카드회원,결사모,결혼도움방, 마이e웨딩
	or
	a.sales_gubun = 'O' and b.jaehu_kind ='C'  and b.company_seq <> 15 -- 일단 웨딩사이트만 올림, 후불결제(ecSupport)는 추후에..
	or
	a.sales_gubun = 'B'
	or
	a.sales_gubun = 'T'
	--or
	--a.sales_gubun = 'P' --아웃바운드
)
and a.company_seq <> 224
GROUP BY a.sales_gubun, b.company_seq, b.company_name
ORDER BY a.sales_gubun



GO
