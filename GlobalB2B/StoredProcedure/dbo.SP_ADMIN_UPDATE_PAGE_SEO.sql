IF OBJECT_ID (N'dbo.SP_ADMIN_UPDATE_PAGE_SEO', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_UPDATE_PAGE_SEO
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
CREATE PROCEDURE [dbo].[SP_ADMIN_UPDATE_PAGE_SEO]
	-- Add the parameters for the stored procedure here
	@p_seq int,
	@p_page_url nvarchar(255),
	@p_title nvarchar(255),
	@p_description nvarchar(255),
	@p_keyword nvarchar(255)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	UPDATE [GlobalB2B].[dbo].[PAGE_SEO_INFO_MST]
	SET [PAGE_URL] = @p_page_url
	  ,[TITLE] = @p_title
	  ,[DESCRIPTION] = @p_description
	  ,[KEYWORD] = @p_keyword 
	WHERE SEO_SEQ = @p_seq;

END
GO
