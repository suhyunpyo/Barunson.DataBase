IF OBJECT_ID (N'dbo.up_select_event_view', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_event_view
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		조창연
-- Create date: 2014-12-02
-- Description:	Event View
-- up_select_event_view 

-- =============================================
CREATE PROCEDURE [dbo].[up_select_event_view]
	
	@idx			int				-- 이벤트 번호	
	
AS
BEGIN

	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	
	SET NOCOUNT ON;	
	
	
	SELECT   EventIdx
			,EventNM
			,FromDt
			,ToDt
			,Contents
			,Banner
			,MainImage
			,MainHtml 
	FROM tEvent
	WHERE EventIdx = @idx	
	
END
GO
