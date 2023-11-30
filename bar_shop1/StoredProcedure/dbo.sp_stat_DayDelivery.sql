IF OBJECT_ID (N'dbo.sp_stat_DayDelivery', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_stat_DayDelivery
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE      Procedure [dbo].[sp_stat_DayDelivery]
	@sdate 	char(10),
	@edate  char(10)
as
begin


select a.regDate as dd, ISNULL(c.cnt,0) as T_cnt,  ISNULL(c.price,0) as T_price,  ISNULL(d.cnt,0) as U_cnt,  ISNULL(d.price,0) as U_price
,  ISNULL(g.cnt,0) as S_cnt,  ISNULL(g.price,0) as S_price,  ISNULL(b.cnt,0) as W_cnt,  ISNULL(b.price,0) as W_price
,  ISNULL(e.cnt,0) as A_cnt,  ISNULL(e.price,0) as A_price,  ISNULL(f.cnt,0) as B_cnt,  ISNULL(f.price,0) as B_price
   from  (
            select  distinct convert(varchar(10),src_send_date,21)  as regdate from custom_order 
            where status_seq = 15 and  convert(varchar(10),src_send_date,21) between @sdate and @edate
            group by   convert(varchar(10),src_send_date,21)
            ) a
            Left Join
            (
            select  convert(varchar(10),src_send_date,21)  as regdate,count(order_seq) as cnt,sum(last_total_price) as price from custom_order 
            where status_seq = 15 and  convert(varchar(10),src_send_date,21) between @sdate and @edate and sales_gubun in ('W') and pay_Type<>'4'
            group by   convert(varchar(10),src_send_date,21)
            ) b
            On a.regdate = b.regdate
            Left Join
            (
            select  convert(varchar(10),src_send_date,21)  as regdate,count(order_seq) as cnt,sum(last_total_price) as price from custom_order 
            where status_seq = 15 and  convert(varchar(10),src_send_date,21) between @sdate and @edate and sales_gubun in ('T') and pay_Type<>'4'
            group by   convert(varchar(10),src_send_date,21)
            ) c
            On a.regdate = c.regdate
            Left Join
            (
            select  convert(varchar(10),src_send_date,21)  as regdate,count(order_seq) as cnt,sum(last_total_price) as price from custom_order 
            where status_seq = 15 and  convert(varchar(10),src_send_date,21) between @sdate and @edate and sales_gubun in ('U') and pay_Type<>'4'
            group by   convert(varchar(10),src_send_date,21)
            ) d
            On a.regdate = d.regdate
            Left Join
            (
            select  convert(varchar(10),src_send_date,21)  as regdate,count(order_seq) as cnt,sum(last_total_price) as price from custom_order 
            where status_seq = 15 and  convert(varchar(10),src_send_date,21) between @sdate and @edate and sales_gubun in ('A') and pay_Type<>'4'
            group by   convert(varchar(10),src_send_date,21)
            ) e
            On a.regdate = e.regdate
            Left Join
            (
            select  convert(varchar(10),src_send_date,21)  as regdate,count(order_seq) as cnt,sum(last_total_price) as price from custom_order 
            where status_seq = 15 and  convert(varchar(10),src_send_date,21) between @sdate and @edate and sales_gubun in ('B') and pay_Type<>'4'
            group by   convert(varchar(10),src_send_date,21)
            ) f
            On a.regdate = f.regdate
            Left Join
            (
            select  convert(varchar(10),src_send_date,21)  as regdate,count(order_seq) as cnt,sum(last_total_price) as price from custom_order 
            where status_seq = 15 and  convert(varchar(10),src_send_date,21) between @sdate and @edate and sales_gubun in ('S') and pay_Type<>'4'
            group by   convert(varchar(10),src_send_date,21)
            ) g
            On a.regdate = g.regdate
order by a.regDate

end






GO
