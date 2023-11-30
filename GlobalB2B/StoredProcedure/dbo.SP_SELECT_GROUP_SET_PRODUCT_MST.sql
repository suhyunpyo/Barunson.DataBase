IF OBJECT_ID (N'dbo.SP_SELECT_GROUP_SET_PRODUCT_MST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_GROUP_SET_PRODUCT_MST
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
CREATE PROCEDURE [dbo].[SP_SELECT_GROUP_SET_PRODUCT_MST]
	-- Add the parameters for the stored procedure here
	@p_group_code nvarchar(30)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    SELECT 
    PG.GROUP_SEQ
    ,PG.GROUP_CODE
    ,PG.PROD_SEQ
    ,PG.TYPE_CODE
    ,PM.PROD_CODE
    FROM PROD_GROUP PG
    LEFT JOIN PROD_MST PM ON PM.PROD_SEQ = PG.PROD_SEQ
    WHERE GROUP_CODE = @p_group_code ORDER BY GROUP_SEQ ASC;
END
GO
