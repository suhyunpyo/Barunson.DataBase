IF OBJECT_ID (N'dbo.sp_jehu_20150127', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_jehu_20150127
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[sp_jehu_20150127]
	@date as int,
	@Gubun as varchar(100)
	
AS

    SET NOCOUNT ON
    
    /*
부서코드 : 390 / 365 / 366 / 340
select left((convert(varchar(10), dateadd(yy,-2, GETDATE()), 112)),6)
select left((convert(varchar(10), dateadd(yy,-1, GETDATE()), 112)),6)
select left((convert(varchar(10), GETDATE(), 112)),6)

[sp_jehu_20150127] '201301',390

*/

select a.COMPANY_SEQ, a.ERP_PartCode, a.COMPANY_NAME, a.LOGIN_ID 
,
(
select COUNT(*) from CUSTOM_SAMPLE_ORDER b 
where a.COMPANY_SEQ = b.company_seq 
and left((convert(varchar(10), b.REQUEST_DATE, 112)),6) = @date 
) 샘플주문1
,
(
select sum(SETTLE_PRICE) from CUSTOM_SAMPLE_ORDER b 
where a.COMPANY_SEQ = b.company_seq 
and left((convert(varchar(10), b.REQUEST_DATE, 112)),6) = @date
) 샘플주문합1
,
(
select COUNT(*) from custom_order b 
where a.COMPANY_SEQ = b.company_seq 
and b.status_Seq in (1,4,6,7,8,9,10,11,12,13,14,15)
and b.order_type =1
and left((convert(varchar(10), b.order_date, 112)),6) = @date
) 주문건수1
,
(
select sum(settle_price) from custom_order b 
where a.COMPANY_SEQ = b.company_seq 
and b.status_Seq in (1,4,6,7,8,9,10,11,12,13,14,15)
and b.order_type =1
and left((convert(varchar(10), b.order_date, 112)),6) = @date
) 주문건수합1
,
(
select COUNT(*) from custom_order b 
where a.COMPANY_SEQ = b.company_seq 
and b.settle_status = 2
and b.order_type =1
and left((convert(varchar(10), b.src_send_date, 112)),6) = @date
) 배송건수1
,
(
select sum(settle_price) from custom_order b 
where a.COMPANY_SEQ = b.company_seq 
and b.settle_status = 2
and b.order_type =1
and left((convert(varchar(10), b.src_send_date, 112)),6) = @date
) 배송건수합1
---------------------------------------------------------
,
(
select COUNT(*) from CUSTOM_SAMPLE_ORDER b 
where a.COMPANY_SEQ = b.company_seq 
and left((convert(varchar(10), b.REQUEST_DATE, 112)),6) = @date +100
) 샘플주문2
,
(
select sum(SETTLE_PRICE) from CUSTOM_SAMPLE_ORDER b 
where a.COMPANY_SEQ = b.company_seq 
and left((convert(varchar(10), b.REQUEST_DATE, 112)),6) = @date +100
) 샘플주문합2
,
(
select COUNT(*) from custom_order b 
where a.COMPANY_SEQ = b.company_seq 
and b.status_Seq in (1,4,6,7,8,9,10,11,12,13,14,15)
and b.order_type =1
and left((convert(varchar(10), b.order_date, 112)),6) = @date +100
) 주문건수2
,
(
select sum(settle_price) from custom_order b 
where a.COMPANY_SEQ = b.company_seq 
and b.status_Seq in (1,4,6,7,8,9,10,11,12,13,14,15)
and b.order_type =1
and left((convert(varchar(10), b.order_date, 112)),6) = @date +100
) 주문건수합2
,
(
select COUNT(*) from custom_order b 
where a.COMPANY_SEQ = b.company_seq 
and b.settle_status = 2
and b.order_type =1
and left((convert(varchar(10), b.src_send_date, 112)),6) = @date +100
) 배송건수2
,
(
select sum(settle_price) from custom_order b 
where a.COMPANY_SEQ = b.company_seq 
and b.settle_status = 2
and b.order_type =1
and left((convert(varchar(10), b.src_send_date, 112)),6) = @date +100
) 배송건수합2
---------------------------------------------------------
,
(
select COUNT(*) from CUSTOM_SAMPLE_ORDER b 
where a.COMPANY_SEQ = b.company_seq 
and left((convert(varchar(10), b.REQUEST_DATE, 112)),6) = @date +200
) 샘플주문3
,
(
select sum(SETTLE_PRICE) from CUSTOM_SAMPLE_ORDER b 
where a.COMPANY_SEQ = b.company_seq 
and left((convert(varchar(10), b.REQUEST_DATE, 112)),6) = @date +200
) 샘플주문합3
,
(
select COUNT(*) from custom_order b 
where a.COMPANY_SEQ = b.company_seq 
and b.status_Seq in (1,4,6,7,8,9,10,11,12,13,14,15)
and b.order_type =1
and left((convert(varchar(10), b.order_date, 112)),6) = @date +200
) 주문건수3
,
(
select sum(settle_price) from custom_order b 
where a.COMPANY_SEQ = b.company_seq 
and b.status_Seq in (1,4,6,7,8,9,10,11,12,13,14,15)
and b.order_type =1
and left((convert(varchar(10), b.order_date, 112)),6) = @date +200
) 주문건수합3
,
(
select COUNT(*) from custom_order b 
where a.COMPANY_SEQ = b.company_seq 
and b.settle_status = 2
and b.order_type =1
and left((convert(varchar(10), b.src_send_date, 112)),6) = @date +200
) 배송건수3
,
(
select sum(settle_price) from custom_order b 
where a.COMPANY_SEQ = b.company_seq 
and b.settle_status = 2
and b.order_type =1
and left((convert(varchar(10), b.src_send_date, 112)),6) = @date +200
) 배송건수합3

from company a
where a.ERP_PartCode = @Gubun
and (a.sales_gubun ='B' or a.sales_gubun ='H') and a.status = 'S2' 


	

    SET NOCOUNT OFF



GO
