IF OBJECT_ID (N'dbo.sp_stat_CardSum', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_stat_CardSum
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO




/*
	'사이트별 카드 판매 수량 -> 일자별로 집계
*/

CREATE     Procedure [dbo].[sp_stat_CardSum]
	@sdate 	char(8),
	@edate  char(8)
as
begin


select a.regDate as dd,  ISNULL(c.cnt,0) as '더카드', ISNULL(b.cnt,0) as '바른손카드',  ISNULL(d.cnt,0) as '투유카드',  ISNULL(e.cnt,0) as '티아라카드', ISNULL( f.cnt,0) as '제휴'   from  (
            select Convert(char(8),src_send_date,112)  as regdate from custom_order 
            where status_seq = 15 and Convert(char(8),src_send_date,112) between @sdate and @edate and sales_gubun in ('W','T','U','A','B')
            group by  Convert(char(8),src_send_date,112)
            ) a
            Left Join
            (
            select Convert(char(8),src_send_date,112)  as regdate,'바른손카드' as cname ,sum(order_count) as cnt from custom_order 
            where status_seq = 15 and Convert(char(8),src_send_date,112) between @sdate and @edate and sales_gubun in ('W')
            group by  Convert(char(8),src_send_date,112)
            ) b
            On a.regdate = b.regdate
            Left Join
            (
            select Convert(char(8),src_send_date,112)  as regdate,'더카드' as cname ,sum(order_count) as cnt from custom_order 
            where status_seq = 15 and Convert(char(8),src_send_date,112) between @sdate and @edate and sales_gubun in ('T')
            group by  Convert(char(8),src_send_date,112)
            ) c
            On a.regdate = c.regdate
            Left Join
            (
            select Convert(char(8),src_send_date,112)  as regdate,'투유카드' as cname ,sum(order_count) as cnt from custom_order 
            where status_seq = 15 and Convert(char(8),src_send_date,112) between @sdate and @edate and sales_gubun in ('U')
            group by  Convert(char(8),src_send_date,112)
            ) d
            On a.regdate = d.regdate
            Left Join
            (
            select Convert(char(8),src_send_date,112)  as regdate,'티아라카드' as cname ,sum(order_count) as cnt from custom_order 
            where status_seq = 15 and Convert(char(8),src_send_date,112) between @sdate and @edate and sales_gubun in ('A')
            group by  Convert(char(8),src_send_date,112)
            ) e
            On a.regdate = e.regdate
            Left Join
            (
            select Convert(char(8),src_send_date,112)  as regdate,'제휴' as cname ,sum(order_count) as cnt from custom_order 
            where status_seq = 15 and Convert(char(8),src_send_date,112) between @sdate and @edate and sales_gubun in ('B')
            group by  Convert(char(8),src_send_date,112)
            ) f
            On a.regdate = f.regdate
order by a.regDate

end



GO
