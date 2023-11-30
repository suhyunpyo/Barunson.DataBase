IF OBJECT_ID (N'dbo.SP_ADMIN_SELECT_PRODUCT_DETAIL_BY_PROD_CODE', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_SELECT_PRODUCT_DETAIL_BY_PROD_CODE
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
CREATE PROCEDURE [dbo].[SP_ADMIN_SELECT_PRODUCT_DETAIL_BY_PROD_CODE]
	-- Add the parameters for the stored procedure here
	@p_prod_code nvarchar(15)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE @t_prod_seq int;
    
    SET @t_prod_seq = (SELECT PROD_SEQ FROM PROD_MST WHERE PROD_CODE = @p_prod_code);
    
    DECLARE @RC int

	EXECUTE @RC = [GlobalB2B].[dbo].[SP_ADMIN_SELECT_PRODUCT_DETAIL] 
		@t_prod_seq
END
GO
