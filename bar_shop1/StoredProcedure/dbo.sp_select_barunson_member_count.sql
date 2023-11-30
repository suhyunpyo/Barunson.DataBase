IF OBJECT_ID (N'dbo.sp_select_barunson_member_count', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_select_barunson_member_count
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[sp_select_barunson_member_count]
	-- Add the parameters for the stored procedure here
	@sDate				datetime,
	@eDate				datetime
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;			
	

-- ///////////////////////// 바른손사이트 회원가입 데이터 ////////////////////////////////////////////////////////
--날짜	/요일	/바른손전체	/바른손웹가입	/바른손모바일가입	/멤버십O	/멤버십O가입시	/멤버십O수정시	/멤버십O에프터페이시/멤버십X/멤버십%
-- [sp_select_barunson_member_count] '2014-05-14','2014-05-21'


Create Table #UsTemp1
(
date1 smalldatetime,
cnt1 int
)

Create Table #UsTemp2
(
date2 smalldatetime,
cnt2 int
)

Create Table #UsTemp3
(
date3 smalldatetime,
cnt3 int
)

Create Table #UsTemp4
(
date4 smalldatetime,
cnt4 int
)

Create Table #UsTemp5
(
date5 smalldatetime,
cnt5 int
)

Create Table #UsTemp6
(
date6 smalldatetime,
cnt6 int
)

Create Table #UsTemp7
(
date7 smalldatetime,
cnt7 int
)

insert into #UsTemp1 (date1,cnt1)
select convert(varchar(10),reg_date,120) 'date', count(*) '바른손전체'
from dbo.S2_UserInfo 
where convert(varchar(10),reg_date,120) >= @sDate and convert(varchar(10),reg_date,120) <= @eDate
and site_div ='SB' 
group by convert(varchar(10),reg_date,120)

insert into #UsTemp2 (date2,cnt2)
select convert(varchar(10),reg_date,120) 'date', count(*) '바른손웹가입'
from dbo.S2_UserInfo 
where convert(varchar(10),reg_date,120) >= @sDate and convert(varchar(10),reg_date,120) <= @eDate
and site_div ='SB'
and inflow_route ='web' 
group by convert(varchar(10),reg_date,120)

insert into #UsTemp3 (date3,cnt3)
select convert(varchar(10),reg_date,120) 'date', count(*) '바른손모바일가입'
from dbo.S2_UserInfo 
where convert(varchar(10),reg_date,120) >= @sDate and convert(varchar(10),reg_date,120) <= @eDate
and site_div ='SB'
and inflow_route ='mobile' 
group by convert(varchar(10),reg_date,120)

insert into #UsTemp4 (date4,cnt4)
select convert(varchar(10),reg_date,120) 'date', count(*) '멤버십O'
from dbo.S2_UserInfo 
where convert(varchar(10),reg_date,120) >= @sDate and convert(varchar(10),reg_date,120) <= @eDate
and site_div ='SB' 
and chk_smembership ='Y'
group by convert(varchar(10),reg_date,120)

insert into #UsTemp5 (date5,cnt5)
select convert(varchar(10),reg_date,120) 'date', count(*) '가입시'
from dbo.S2_UserInfo
where convert(varchar(10),reg_date,120) >= @sDate and convert(varchar(10),reg_date,120) <= @eDate
and site_div ='SB' and chk_smembership ='Y'
and smembership_inflow_route ='join' 
group by convert(varchar(10),reg_date,120)

insert into #UsTemp6 (date6,cnt6)
select convert(varchar(10),reg_date,120) 'date', count(*) '수정시'
from dbo.S2_UserInfo
where convert(varchar(10),reg_date,120) >= @sDate and convert(varchar(10),reg_date,120) <= @eDate
and site_div ='SB' and chk_smembership ='Y'
and smembership_inflow_route ='modify'
group by convert(varchar(10),reg_date,120)

insert into #UsTemp7 (date7,cnt7)
select convert(varchar(10),reg_date,120) 'date', count(*) 'after-pay'
from dbo.S2_UserInfo
where convert(varchar(10),reg_date,120) >= @sDate and convert(varchar(10),reg_date,120) <= @eDate
and site_div ='SB' and chk_smembership ='Y'
and smembership_inflow_route ='apay'
group by convert(varchar(10),reg_date,120)

------------------------------------------------------------------

delete dbo.barunson_day_count

insert into dbo.barunson_day_count
(reg_date,[day],barunson_join_total,barunson_join_web,barunson_join_mobile
,barunson_membership_total,barunson_membership_join,barunson_membership_modify
,barunson_membership_apay,barunson_membership_X,barunson_membership_percent)

select convert(varchar(10),a.date1,120) reg_date
,
CASE datepart(dw, a.date1) 
when 2 then '월' 
when 3 then '화'
when 4 then '수'
when 5 then '목'
when 6 then '금'
when 7 then '토'
when 1 then '일' end AS [day]
, a.cnt1 barunson_join_total, b.cnt2 barunson_join_web
, ISNULL(c.cnt3,0) barunson_join_mobile
, d.cnt4 barunson_membership_total, e.cnt5 barunson_membership_join, f.cnt6 barunson_membership_modify
, ISNULL(g.cnt7,0) barunson_membership_apay
, (b.cnt2 - d.cnt4) barunson_membership_X
, (round(d.cnt4/convert(float,(a.cnt1)),2)*100) barunson_membership_percent
from #UsTemp1 a 
join #UsTemp2 b on a.date1 = b.date2
left join #UsTemp3 c on a.date1 = c.date3
join #UsTemp4 d on a.date1 = d.date4
join #UsTemp5 e on a.date1 = e.date5
join #UsTemp6 f on a.date1 = f.date6
left join #UsTemp7 g on a.date1 = g.date7

drop table #UsTemp1
drop table #UsTemp2
drop table #UsTemp3
drop table #UsTemp4
drop table #UsTemp5
drop table #UsTemp6
drop table #UsTemp7

select * from dbo.barunson_day_count order by reg_date 


END

GO
