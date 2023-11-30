IF OBJECT_ID (N'dbo.SP_ADMIN_DELETE_PAGE_SEO', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_DELETE_PAGE_SEO
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
CREATE PROCEDURE [dbo].[SP_ADMIN_DELETE_PAGE_SEO]
	-- Add the parameters for the stored procedure here
	@p_seq int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DELETE FROM PAGE_SEO_INFO_MST WHERE SEO_SEQ = @p_seq;
END
GO
