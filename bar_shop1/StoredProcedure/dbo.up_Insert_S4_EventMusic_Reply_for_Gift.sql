IF OBJECT_ID (N'dbo.up_Insert_S4_EventMusic_Reply_for_Gift', N'P') IS NOT NULL DROP PROCEDURE dbo.up_Insert_S4_EventMusic_Reply_for_Gift
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		시스템지원팀, 장형일 과장
-- Create date: 2015-07-24
-- Description:	프론트, 초대 이벤트 참여, S4_EventMusic_Reply_01

-- EXEC up_Insert_S4_EventMusic_Reply 86, 'bhandstest', 5006
-- EXEC up_Insert_S4_EventMusic_Reply 87, 'bhandstest', 5006
-- =============================================
/*

EXEC up_Insert_S4_EventMusic_Reply_01 104, 's4guest', 5001, 'asd', 'aaaaa'

*/
CREATE proc [dbo].[up_Insert_S4_EventMusic_Reply_for_Gift]

		@event_seq		int
	, @uid					varchar(100)
	, @company_seq		int
	, @comment			varchar(4000)
	, @var1					varchar(100)
as

set nocount on;

declare @rtnResult smallint, @rtnMsg varchar(100)
declare @uname varchar(50), @umail varchar(100)

SELECT	TOP 1
		@UNAME = UNAME
	,	@UMAIL = UMAIL
--	,   @company_seq = company_seq
FROM	VIEW_USRINFO
WHERE	UID = @UID
AND		(COMPANY_SEQ IS NULL OR COMPANY_SEQ = @COMPANY_SEQ)
AND		(CASE WHEN @COMPANY_SEQ = 5001 THEN TBL_NAME ELSE '' END = CASE WHEN @COMPANY_SEQ = 5001 THEN 'S2_USERINFO' ELSE '' END)


if exists(select seq from S4_EventMusic_Str where seq = @event_seq and (convert(varchar(10), getdate(), 121) between start_date and end_date))
	begin

		if (select duplication_yn from S4_EventMusic_Str where seq = @event_seq AND (COMPANY_SEQ IS NULL OR COMPANY_SEQ = @COMPANY_SEQ)) = 'Y'
			or not exists (select * from S4_EventMusic_Reply where company_seq  = @company_seq and reg_num = @event_seq and uid = @uid)
			begin
				insert into S4_EventMusic_Reply
				(
					company_seq, reg_num, uid, uname, umail, comment, var1
				)
				values
				(
					@company_seq, @event_seq, @uid, @uname, @umail, @comment, @var1
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
