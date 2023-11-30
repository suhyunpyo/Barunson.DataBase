IF OBJECT_ID (N'dbo.SP_ADMIN_SELECT_MENU_MST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_SELECT_MENU_MST
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_ADMIN_SELECT_MENU_MST]
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    -- Insert statements for procedure here
	SELECT 
	CASE WHEN PARENT_MENU_SEQ IS NULL OR PARENT_MENU_SEQ < 0 THEN MENU_SEQ ELSE PARENT_MENU_SEQ END AS MAIN_MENU_SEQ	
	,*
	FROM ADMIN_MENU_MST 
	ORDER BY MAIN_MENU_SEQ ASC,(CASE WHEN PARENT_MENU_SEQ IS NULL THEN 1 ELSE 0 END) DESC,PARENT_MENU_SEQ ASC,SORT_NUM ASC;
END


GO
