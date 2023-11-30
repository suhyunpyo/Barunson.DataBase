IF OBJECT_ID (N'dbo.SP_ADMIN_DELETE_BANNER', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_DELETE_BANNER
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
CREATE PROCEDURE [dbo].[SP_ADMIN_DELETE_BANNER]
	-- Add the parameters for the stored procedure here
	@p_banner_seq int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DELETE FROM BANNER_MST WHERE BANNER_SEQ = @p_banner_seq;
END
GO
