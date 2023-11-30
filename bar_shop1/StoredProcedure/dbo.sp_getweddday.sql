IF OBJECT_ID (N'dbo.sp_getweddday', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_getweddday
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_getweddday]
	@sdate as varchar(255),        
	@edate as varchar(255),
	@company_seq as varchar(255)
	         
	
AS
			
			
Create Table #UsTemp
(
order_date varchar(255),
company_seq varchar(255),
weddday varchar(255)
)

insert into dbo.#UsTemp (order_date, company_seq, weddday)

select convert(varchar(10),aa.order_date,121) order_date, aa.company_seq
, bb.event_year + '-' +
case
when len(bb.event_month)=1 then '0'+bb.event_month
when len(bb.event_month)=2 then bb.event_month
else
	''
end + '-' + 
case
when len(bb.event_Day )=1 then '0'+bb.event_Day 
when len(bb.event_Day )=2 then bb.event_Day 
else
	''
end as weddday
from custom_order aa
left join custom_order_WeddInfo bb on aa.order_seq = bb.order_seq
where aa.order_date >= @sdate and aa.order_date < @edate 
and aa.up_order_seq is null 
and aa.company_seq = @company_seq
and aa.settle_status = 2

/*select order_date, company_seq, weddday, DATEDIFF(day, order_date, weddday) from #UsTemp
where LEN(weddday) = 10

select count(*), sum(DATEDIFF(day, order_date, weddday)) from #UsTemp
where LEN(weddday) = 10
*/

select 
cast((select sum(DATEDIFF(day, order_date, weddday)) from #UsTemp where LEN(weddday) = 10 and weddday not like '%00%' and weddday not like '%99%' and weddday >= '2010-01-01' and weddday < '2013-12-31') as int)
/
(select count(*) from #UsTemp where LEN(weddday) = 10 and weddday not like '%00%' and weddday not like '%99%' and weddday >= '2010-01-01' and weddday < '2013-12-31')

drop Table #UsTemp
GO
