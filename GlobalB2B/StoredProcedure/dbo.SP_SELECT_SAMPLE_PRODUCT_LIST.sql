IF OBJECT_ID (N'dbo.SP_SELECT_SAMPLE_PRODUCT_LIST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_SAMPLE_PRODUCT_LIST
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
CREATE PROCEDURE [dbo].[SP_SELECT_SAMPLE_PRODUCT_LIST]
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    -- Insert statements for procedure here
    
	SELECT 
	PM.*
	FROM PROD_MST PM
	WHERE PM.SAMPLE_USE_YORN = 'Y'
END


GO
