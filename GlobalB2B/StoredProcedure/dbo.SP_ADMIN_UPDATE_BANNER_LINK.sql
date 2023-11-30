IF OBJECT_ID (N'dbo.SP_ADMIN_UPDATE_BANNER_LINK', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_UPDATE_BANNER_LINK
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
CREATE PROCEDURE [dbo].[SP_ADMIN_UPDATE_BANNER_LINK]
	-- Add the parameters for the stored procedure here
	@p_banner_seq int,
	@p_banner_link_url nvarchar(255)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE BANNER_MST
	SET BANNER_LINK_URL = @p_banner_link_url
	WHERE BANNER_SEQ = @p_banner_seq;
END
GO
