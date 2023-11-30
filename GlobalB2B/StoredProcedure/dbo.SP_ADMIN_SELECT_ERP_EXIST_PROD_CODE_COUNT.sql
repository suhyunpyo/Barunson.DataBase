IF OBJECT_ID (N'dbo.SP_ADMIN_SELECT_ERP_EXIST_PROD_CODE_COUNT', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_SELECT_ERP_EXIST_PROD_CODE_COUNT
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
CREATE PROCEDURE [dbo].[SP_ADMIN_SELECT_ERP_EXIST_PROD_CODE_COUNT]
	@p_prod_code nvarchar(255),
	@r_result int OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET @r_result = (SELECT COUNT(*) FROM [ERPDB.BHANDSCARD.COM].[XERP].[dbo].[ItemSiteMaster] WHERE SiteCode = 'BK10' AND ItemCode = @p_prod_code);
END

GO
