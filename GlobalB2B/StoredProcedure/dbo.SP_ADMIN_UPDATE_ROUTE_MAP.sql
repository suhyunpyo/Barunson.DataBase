IF OBJECT_ID (N'dbo.SP_ADMIN_UPDATE_ROUTE_MAP', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_UPDATE_ROUTE_MAP
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
CREATE PROCEDURE [dbo].[SP_ADMIN_UPDATE_ROUTE_MAP]
	-- Add the parameters for the stored procedure here
	@p_route_seq int,
	@p_route_name nvarchar(255),
	@p_route_url nvarchar(255),
	@p_physical_url nvarchar(255),
	@p_check_physicial_access_yorn char(1)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	UPDATE [GlobalB2B].[dbo].[ROUTE_MAP_MST]
	   SET [ROUTE_NAME] = @p_route_name
		  ,[ROUTE_URL] = @p_route_url
		  ,[PHYSICAL_URL] = @p_physical_url
		  ,[CHECK_PHYSICAL_URL_CHECK_YORN] = @p_check_physicial_access_yorn
	 WHERE ROUTE_SEQ = @p_route_seq

END
GO
