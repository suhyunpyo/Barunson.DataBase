IF OBJECT_ID (N'dbo.SP_SELECT_COUNT_PRODUCT_INTO_WISH', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_COUNT_PRODUCT_INTO_WISH
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
CREATE PROCEDURE [dbo].[SP_SELECT_COUNT_PRODUCT_INTO_WISH]
	-- Add the parameters for the stored procedure here
	@p_prod_code nvarchar(15),
	@p_user_id nvarchar(255)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE @t_prod_seq int,@t_user_seq int
    
    SET @t_prod_seq = (SELECT PROD_SEQ FROM PROD_MST WHERE PROD_CODE = @p_prod_code);
    SET @t_user_seq = (SELECT USER_SEQ FROM USER_MST WHERE USER_ID  = @p_user_id);
    
    SELECT 
    SUM(QUANTITY)
    FROM CART_MST 
    WHERE USER_SEQ = @t_user_seq 
    AND PROD_SEQ = @t_prod_seq 
    AND CART_STATE_CODE = '118001' 
    AND CART_TYPE_CODE = '111001'
    
END

GO
