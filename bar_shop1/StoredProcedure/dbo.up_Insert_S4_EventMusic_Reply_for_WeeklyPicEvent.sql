IF OBJECT_ID (N'dbo.up_Insert_S4_EventMusic_Reply_for_WeeklyPicEvent', N'P') IS NOT NULL DROP PROCEDURE dbo.up_Insert_S4_EventMusic_Reply_for_WeeklyPicEvent
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		시스템지원팀, 장형일 과장
-- Create date: 2015-07-24
-- Description:	프론트, 초대 이벤트 참여, S4_EventMusic_Reply_for_WeeklyPicEvent

-- EXEC up_Insert_S4_EventMusic_Reply_for_WeeklyPicEvent 90, 'bhandstest', 5003, 'aaa'
-- EXEC up_Insert_S4_EventMusic_Reply_for_WeeklyPicEvent 90, 'bhandstest', 5006
-- =============================================
CREATE proc [dbo].[up_Insert_S4_EventMusic_Reply_for_WeeklyPicEvent]

	@event_seq			int
	, @uid				varchar(100)
	, @company_seq		int
	, @comment			varchar(1000)
as

set nocount on;

declare @rtnResult smallint, @rtnMsg varchar(100)
declare @uname varchar(50), @umail varchar(100)

select @uname = @uname, @umail = umail
from view_UsrInfo
where uid = @uid
	and exists
	(
		select 1 where @company_seq = 5001 and tbl_name = 's2_userinfo'
		union all
		select 1 where @company_seq = 5003 and tbl_name = 's2_userinfo'
		union all
		select 1 where @company_seq = 5006 and tbl_name = 's2_userinfo_bhands'
		union all
		select 1 where @company_seq = 5007 and tbl_name = 's2_userinfo_thecard'
	)

if exists(select seq from S4_EventMusic_Str where seq = @event_seq and (convert(varchar(10), getdate(), 121) between start_date and end_date))
	begin

		if (select duplication_yn from S4_EventMusic_Str where seq = @event_seq) = 'Y'
			and not exists (select * from S4_EventMusic_Reply where company_seq  = @company_seq and reg_num = @event_seq and uid = @uid and CONVERT(varchar(10), getdate(), 121) = CONVERT(varchar(10), reg_date, 121))
			begin
				insert into S4_EventMusic_Reply
				(
					company_seq, reg_num, uid, uname, umail, comment
				)
				values
				(
					@company_seq, @event_seq, @uid, @uname, @umail, @comment
				)

				set @rtnResult = 1
				set @rtnMsg = '이벤트 참여에 성공하였습니다.'

			end
		else
			begin

				set @rtnResult = 2
				set @rtnMsg = '이미 이벤트에 참여 하셨습니다.'

			end
	end
else
	begin

		set @rtnResult = 4
		set @rtnMsg = '이벤트 기간이 아닙니다.'

	end



select @rtnResult as result, @rtnMsg as msg














GO
