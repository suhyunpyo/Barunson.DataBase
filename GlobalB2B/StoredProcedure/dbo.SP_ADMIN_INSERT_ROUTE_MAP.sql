IF OBJECT_ID (N'dbo.SP_ADMIN_INSERT_ROUTE_MAP', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_INSERT_ROUTE_MAP
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
CREATE PROCEDURE [dbo].[SP_ADMIN_INSERT_ROUTE_MAP]
	@p_route_name nvarchar(255),
	@p_route_url nvarchar(255),
	@p_physical_url nvarchar(255),
	@p_check_physicial_access_yorn char(1)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	INSERT INTO [GlobalB2B].[dbo].[ROUTE_MAP_MST]
           ([ROUTE_NAME]
           ,[ROUTE_URL]
           ,[PHYSICAL_URL]
           ,[CHECK_PHYSICAL_URL_CHECK_YORN]
           ,[REG_DATE])
     VALUES
           (@p_route_name
           ,@p_route_url
           ,@p_physical_url
           ,@p_check_physicial_access_yorn
           ,GETDATE());




END
GO
