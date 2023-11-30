IF OBJECT_ID (N'dbo.SP_ADMIN_DELETE_ROUTE_MAP', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_DELETE_ROUTE_MAP
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
CREATE PROCEDURE [dbo].[SP_ADMIN_DELETE_ROUTE_MAP]
	-- Add the parameters for the stored procedure here
	@p_route_seq int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DELETE FROM ROUTE_MAP_MST WHERE ROUTE_SEQ = @p_route_seq;
END
GO
