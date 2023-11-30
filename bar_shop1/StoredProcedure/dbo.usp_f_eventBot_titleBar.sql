IF OBJECT_ID (N'dbo.usp_f_eventBot_titleBar', N'P') IS NOT NULL DROP PROCEDURE dbo.usp_f_eventBot_titleBar
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO








CREATE                                       PROCEDURE [dbo].[usp_f_eventBot_titleBar]
@BarType			as char(1),
@EventIdx			as int,
@botOrderNo			as int
AS

IF (@BarType = 'A')
	BEGIN
		Select a.BotNavi, a.BotOrderNo 
		From tEventBotTemplete a with(nolock) Inner Join (Select BotIdx From tEventBotItem with(nolock) Group By BotIdx) b  on a.botIdx = b.botIdx
		Where a.eventidx =  @EventIdx
		Order By a.BotOrderNo
	END
ELSE
	BEGIN
		Select Top 1 botCopy, botBanner, botUrl, AddBtnYN, AddBtnURL, BotNavi, a.BotOrderNo, BotReview
		From tEventBotTemplete a with(nolock) Inner Join tEventBotItem b with(nolock) on a.botIdx = b.botIdx
		Where 
			a.eventidx = @EventIdx
			and a.botOrderNo = @botOrderNo
		order by b.BotSize, b.botOrderNo
	END
GO
