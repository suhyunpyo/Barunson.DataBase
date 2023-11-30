IF OBJECT_ID (N'dbo.Up_Select_S4_Poll_User_Reply_List', N'P') IS NOT NULL DROP PROCEDURE dbo.Up_Select_S4_Poll_User_Reply_List
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		시스템지원팀, 장형일 과장
-- Create date: 2015-08-21
-- Description:	관리자(manager.thecard.co.kr), 설문참여 회원 리스트

-- EXEC Up_Select_S4_Poll_User_Reply_List 13, 1, 15
-- =============================================
CREATE proc [dbo].[Up_Select_S4_Poll_User_Reply_List]

	@poll_seq		int
	, @sch_type		varchar(50)
	, @sch_text		varchar(100)
	, @page			int
	, @page_size	int

as

	
set nocount on;

declare @startRowNum smallint, @endRowNum smallint

set @startRowNum = (@page - 1) * @page_size + 1
set @endRowNum   = @page * @page_size


Select count(*) as tot, ceiling(cast(count(*) as float)/@page_size) as totpage 
From s4_poll_user_reply s4pur
inner join S4_Poll_item s4pi
on s4pi.poll_seq = s4pur.poll_seq and s4pi.seq = s4pur.poll_item_seq
inner join s4_Poll s4P
on s4P.seq = s4pur.poll_seq
left outer join view_UsrInfo vu
on vu.uid = s4pur.uid
where s4P.seq = @poll_seq
	and
	exists
	(
		select 1 where @sch_type = ''
		union
		select 1 where @sch_type = 'uid' and vu.uid like '%' + @sch_text + '%'
		union
		select 1 where @sch_type = 'uname' and vu.uname like '%' + @sch_text + '%'
	)


select *
from
(
	Select ROW_NUMBER() over(order by s4pur.reg_date desc) as rNum 
		, case when s4P.company_seq = 5006 then '비핸즈'
			   when s4P.company_seq = 5001 then '바른손'
			   when s4P.company_seq = 5003 then '프리미어페이퍼'
			   when s4P.company_seq = 5007 then '더카드'
			   else ''
		  end siteNm
		, s4pur.uid
		, vu.uname
		, s4pur.poll_item_seq
		, s4pi.item_title
		, convert(varchar(10), s4pur.reg_date, 121) as reg_date
	From s4_poll_user_reply s4pur
	inner join S4_Poll_item s4pi
	on s4pi.poll_seq = s4pur.poll_seq and s4pi.seq = s4pur.poll_item_seq
	inner join s4_Poll s4P
	on s4P.seq = s4pur.poll_seq
	left outer join view_UsrInfo vu
	on vu.uid = s4pur.uid
	where s4P.seq = @poll_seq
		and
		exists
		(
			select 1 where @sch_type = ''
			union
			select 1 where @sch_type = 'uid' and vu.uid like '%' + @sch_text + '%'
			union
			select 1 where @sch_type = 'uname' and vu.uname like '%' + @sch_text + '%'
		)		
) as T
where T.rNum between @startRowNum and @endRowNum
order by T.reg_date desc
GO
