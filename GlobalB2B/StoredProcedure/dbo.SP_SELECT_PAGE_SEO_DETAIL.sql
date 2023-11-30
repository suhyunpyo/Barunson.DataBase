IF OBJECT_ID (N'dbo.SP_SELECT_PAGE_SEO_DETAIL', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_PAGE_SEO_DETAIL
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
CREATE PROCEDURE [dbo].[SP_SELECT_PAGE_SEO_DETAIL]
	@p_page_url nvarchar(255)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT * FROM PAGE_SEO_INFO_MST WHERE PAGE_URL = @p_page_url;
END

GO
