IF OBJECT_ID (N'dbo.up_Insert_S4_Poll_User_Reply_3Check', N'P') IS NOT NULL DROP PROCEDURE dbo.up_Insert_S4_Poll_User_Reply_3Check
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		시스템지원팀, 장형일 과장
-- Create date: 2015-08-25
-- Description:	프론트, 설문 참여, [up_Insert_S4_Poll_User_Reply_3Check]

-- EXEC [up_Insert_S4_Poll_User_Reply_3Check] 14, 92, 'bhandstest'
-- =============================================
CREATE proc [dbo].[up_Insert_S4_Poll_User_Reply_3Check]

	@poll_seq			int
	, @poll_item_seq1			int
	, @poll_item_seq2			int
	, @poll_item_seq3			int
	, @uid				varchar(100)
	
as

set nocount on;

declare @rtnResult smallint, @rtnMsg varchar(100)

if exists(select seq from S4_Poll where seq = @poll_seq and (convert(varchar(10), getdate(), 121) between start_date and end_date))
	begin

		if (not exists (select * from s4_poll_user_reply where poll_seq = @poll_seq and uid = @uid) )
			begin
				insert into s4_poll_user_reply values (@poll_seq, @uid, @poll_item_seq1, GETDATE())
				insert into s4_poll_user_reply values (@poll_seq, @uid, @poll_item_seq2, GETDATE())
				insert into s4_poll_user_reply values (@poll_seq, @uid, @poll_item_seq3, GETDATE())

				update S4_Poll_item set item_count = item_count + 1 where poll_seq = @poll_seq and seq = @poll_item_seq1 
				update S4_Poll_item set item_count = item_count + 1 where poll_seq = @poll_seq and seq = @poll_item_seq2 
				update S4_Poll_item set item_count = item_count + 1 where poll_seq = @poll_seq and seq = @poll_item_seq3 

				set @rtnResult = 1
				set @rtnMsg = '설문 참여에 성공하였습니다.'
			end
		else
			begin

				set @rtnResult = 2
				set @rtnMsg = '이미 설문에 참여 하셨습니다.'

			end
	end
else
	begin

		set @rtnResult = 4
		set @rtnMsg = '설문 기간이 아닙니다.'

	end

select @rtnResult as result, @rtnMsg as msg














GO
