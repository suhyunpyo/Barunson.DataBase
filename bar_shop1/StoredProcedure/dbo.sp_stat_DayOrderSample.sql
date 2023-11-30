IF OBJECT_ID (N'dbo.sp_stat_DayOrderSample', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_stat_DayOrderSample
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE        Procedure [dbo].[sp_stat_DayOrderSample]
	@sdate 	char(10),
	@edate  char(10)
as
begin


select a.regDate as dd,  ISNULL(c.cnt,0) as T_cnt, ISNULL(d.cnt,0) as U_cnt, ISNULL( g.cnt,0) as S_cnt,   ISNULL(b.cnt,0) as W_cnt, ISNULL(e.cnt,0) as A_cnt, ISNULL( f.cnt,0) as B_cnt   from  (
            select  convert(varchar(10),request_date,21)  as regdate from custom_sample_order 
            where status_seq = 12 and  convert(varchar(10),request_date,21) between @sdate and @edate and sales_gubun in ('W','T','U','A','B','S')
            group by   convert(varchar(10),request_date,21)
            ) a
            Left Join
            (
            select  convert(varchar(10),request_date,21)  as regdate,'바른손카드' as cname ,count(sample_order_seq) as cnt from custom_sample_order 
            where status_seq = 12 and  convert(varchar(10),request_date,21) between @sdate and @edate and sales_gubun in ('W')
            group by   convert(varchar(10),request_date,21)
            ) b
            On a.regdate = b.regdate
            Left Join
            (
            select  convert(varchar(10),request_date,21)  as regdate,'더카드' as cname ,count(sample_order_seq) as cnt from custom_sample_order 
            where status_seq = 12 and  convert(varchar(10),request_date,21) between @sdate and @edate and sales_gubun in ('T')
            group by   convert(varchar(10),request_date,21)
            ) c
            On a.regdate = c.regdate
            Left Join
            (
            select  convert(varchar(10),request_date,21)  as regdate,'투유카드' as cname ,count(sample_order_seq) as cnt from custom_sample_order 
            where status_seq = 12 and  convert(varchar(10),request_date,21) between @sdate and @edate and sales_gubun in ('U')
            group by   convert(varchar(10),request_date,21)
            ) d
            On a.regdate = d.regdate
            Left Join
            (
            select  convert(varchar(10),request_date,21)  as regdate,'티아라카드' as cname ,count(sample_order_seq) as cnt from custom_sample_order 
            where status_seq = 12 and  convert(varchar(10),request_date,21) between @sdate and @edate and sales_gubun in ('A')
            group by   convert(varchar(10),request_date,21)
            ) e
            On a.regdate = e.regdate
            Left Join
            (
            select  convert(varchar(10),request_date,21)  as regdate,'제휴' as cname ,count(sample_order_seq) as cnt from custom_sample_order 
            where status_seq = 12 and  convert(varchar(10),request_date,21) between @sdate and @edate and sales_gubun in ('B')
            group by   convert(varchar(10),request_date,21)
            ) f
            On a.regdate = f.regdate
            Left Join
            (
            select  convert(varchar(10),request_date,21)  as regdate,'고급' as cname ,count(sample_order_seq) as cnt from custom_sample_order 
            where status_seq = 12 and  convert(varchar(10),request_date,21) between @sdate and @edate and sales_gubun in ('S')
            group by   convert(varchar(10),request_date,21)
            ) g
            On a.regdate =g.regdate
order by a.regDate

end







GO
