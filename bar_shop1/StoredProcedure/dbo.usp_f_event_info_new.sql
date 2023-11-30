IF OBJECT_ID (N'dbo.usp_f_event_info_new', N'P') IS NOT NULL DROP PROCEDURE dbo.usp_f_event_info_new
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE                                      PROCEDURE [dbo].[usp_f_event_info_new]
@EventIdx			as int
AS


if 	@EventIdx > 0 


	select EventIdx, EventNM, convert(char(8),fromdt,2) fromdt, convert(char(8),todt,2) todt, EventGb, Contents, Banner, templateYN, templateUrl, PageWidth, NaviYN, MainImage, MainHtml, MainText, projectYN, TitleBarType,
		TopBannerType, MiddleBannerType, BottomBannerType,
		--isnull((Select count(*) From tEventBotTemplete a WITH(NOLOCK) Inner Join (Select BotIdx From tEventBotItem with(nolock) Group By BotIdx) b  on a.botIdx = b.botIdx Where eventidx = @EventIdx),0) as botTempCnt
		isnull((Select count(*) From tEventBotTemplete Where eventidx = @EventIdx),0) as botTempCnt,
		Top6Image1, Top6Image2, Top6Image3, Top6Image4, Top6Image5, Top6Image6,
		Top6ImageURL1, Top6ImageURL2, Top6ImageURL3, Top6ImageURL4, Top6ImageURL5, Top6ImageURL6
	from tEvent a WITH(NOLOCK)
	where 
		eventidx = @EventIdx
	order by EventIdx Desc 


else	-- 램덤가져오기
	select  EventNM, EventGb, topType, topBanner, topUrl, TopCopy
		, topItemBanner, (case when topType = 4 then topItemUrl else TopITemCd end) as topItemUrl, a.eventIdx
		, a.fromdt, a.todt, convert(char(8),a.todt,2) todt
		, isnull((select count(botIdx) from tEventBotTemplete WITH(NOLOCK) where eventidx = a.eventidx),0) as botTempCnt
	from (
			select top 1 *
			from tEvent WITH(NOLOCK)
			where fromDt <= convert(char(10),getdate(),120)
			and toDt >= convert(char(10),getdate(),120)
			and viewYN = 'Y'
			order by newid() ) a
		inner join tEventTopTemplete b WITH(NOLOCK) on a.eventidx = b.eventidx
		inner join tEventTopItem c WITH(NOLOCK) on a.eventidx = c.eventidx
GO
