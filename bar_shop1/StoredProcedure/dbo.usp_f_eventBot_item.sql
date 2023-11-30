IF OBJECT_ID (N'dbo.usp_f_eventBot_item', N'P') IS NOT NULL DROP PROCEDURE dbo.usp_f_eventBot_item
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO









CREATE                                       PROCEDURE [dbo].[usp_f_eventBot_item]
@BotSize			as char(1),
@EventIdx			as int,
@botOrderNo			as int
AS


select 
	 disYN = 'Y'
	, 0
	, botType, botBanner, botUrl, botCopy, AddBtnYN, AddBtnURL
	, b.BotSize, a.BotReview
	, a.BotStock, a.BotSaleCnt
from tEventBotTemplete a with(nolock)
	inner join tEventBotItem b with(nolock) on a.botIdx = b.botIdx
	--inner join tItemSum i WITH(NOLOCK) on i.itemCd = b.botItemCd
	
where 
	b.botSize = @BotSize
	and a.eventidx = @EventIdx
	and a.botOrderNo = @botOrderNo
	--and i.viewYN = 'Y' 
	--and i.useYN = 'Y'
order by b.BotSize, b.botOrderNo




GO
