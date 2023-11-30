IF OBJECT_ID (N'dbo.up_Insert_S4_Event_Blank_Keyword', N'P') IS NOT NULL DROP PROCEDURE dbo.up_Insert_S4_Event_Blank_Keyword
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		시스템지원팀, 장형일 과장
-- Create date: 2015-07-24
-- Description:	프론트, Blank Keyword, S4_Event_Blank_Keyword

-- EXEC up_Insert_S4_Event_Blank_Keyword 86, 'bhandstest', 5006
--  0 : 답 틀림 
--  1 : 등록
--  2 : 이벤트 참여자
--  3 : 이벤트 대상자 아님 
--  4 : 이벤트 미기간
--  5 : 오류
--  6 : 로그인 에러
--  7 : 댓글 없음
-- =============================================

CREATE proc [dbo].[up_Insert_S4_Event_Blank_Keyword]

	@event_seq			int
	, @uid					varchar(100)
	, @company_seq		int
	, @comment			varchar(1000)
AS

	SET NOCOUNT ON;

	DECLARE @rtnResult smallint 
	DECLARE @rtnMsg varchar(100)
	DECLARE @uname varchar(50)
	DECLARE @umail varchar(100)

	SELECT TOP 1
		@UNAME = UNAME
		,@UMAIL = UMAIL
	--	,@company_seq = company_seq
	FROM VIEW_USRINFO
	WHERE UID = @UID
	AND (COMPANY_SEQ IS NULL OR COMPANY_SEQ = @COMPANY_SEQ)
	AND (CASE WHEN @COMPANY_SEQ = 5001 THEN TBL_NAME ELSE '' END = CASE WHEN @COMPANY_SEQ = 5001 THEN 'S2_USERINFO' ELSE '' END)

	IF exists(SELECT seq FROM S4_EventMusic_Str_Temp WHERE seq = @event_seq and (convert(varchar(10), getdate(), 121) between start_date and end_date))
		BEGIN

			if (select duplication_yn from S4_EventMusic_Str_Temp where seq = @event_seq AND (COMPANY_SEQ IS NULL OR COMPANY_SEQ = @COMPANY_SEQ)) = 'Y'
				or not exists (select * from S4_Event_Blank_Keyword where company_seq  = @company_seq and reg_num = @event_seq and uid = @uid)
				begin
					insert into S4_Event_Blank_Keyword
					(
						company_seq, reg_num, uid, uname, umail, comment, ordered
					)
					values
					(
						@company_seq, @event_seq, @uid, @uname, @umail, @comment, 0
					)

					set @rtnResult = 1
					set @rtnMsg = '축하드립니다. 청첩장 주문시 사은품을 함께 보내드립니다. 선착순이니 주문을 서둘러주세요.'

				end
			else
				begin

					set @rtnResult = 2
					set @rtnMsg = '이미 이벤트에 참여 하셨습니다.'

				end
		end
	ELSE
		begin

			set @rtnResult = 4
			set @rtnMsg = '이벤트 기간이 아닙니다.'

		end

	select @rtnResult as result, @rtnMsg as msg
GO
