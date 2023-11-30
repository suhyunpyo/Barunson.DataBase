IF OBJECT_ID (N'dbo.up_Select_S4_EventMusic_Reply_test', N'P') IS NOT NULL DROP PROCEDURE dbo.up_Select_S4_EventMusic_Reply_test
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		시스템지원팀, 장형일 과장
-- Create date: 2015-07-24
-- Description:	프론트, 초대 이벤트 참여 리스트, S4_EventMusic_Reply

-- EXEC up_Select_S4_EventMusic_Reply_test 84, 1, 10
-- =============================================
CREATE proc [dbo].[up_Select_S4_EventMusic_Reply_test]

	@event_seq			int
	, @page				smallint
	, @page_size        smallint

as

set nocount on;

declare @startRowNum smallint, @endRowNum smallint, @totalCnt int


set @startRowNum = (@page - 1) * @page_size + 1
set @endRowNum   = @page * @page_size

select @totalCnt = count(seq)
from S4_EventMusic_Reply
where reg_num = @event_seq


select @totalCnt as totalCnt, @totalCnt - rowNum + 1 as rowIndex, *
from 
(
	select ROW_NUMBER() over(order by s2er.reg_date desc) as rowNum, s2er.comment, s2er.uid, convert(varchar(10), s2er.reg_date, 102) as reg_date, vu.uname
	from S4_EventMusic_Reply s2er
	inner join view_UsrInfo vu
	on vu.uid = s2er.uid and (vu.company_seq is null or vu.company_seq = s2er.company_seq)
	where s2er.reg_num = @event_seq
) as T
where T.rowNum between @startRowNum and @endRowNum













GO
