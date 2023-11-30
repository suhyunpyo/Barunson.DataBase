IF OBJECT_ID (N'dbo.SP_INSERT_WISH', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_INSERT_WISH
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
CREATE PROCEDURE [dbo].[SP_INSERT_WISH]
	-- Add the parameters for the stored procedure here
	@p_prod_code nvarchar(15),
	@p_user_id nvarchar(255),
	@p_quantity int,
	@p_cart_type_code nvarchar(255)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE @t_prod_seq int,@t_user_seq int
    
    SET @t_prod_seq = (SELECT PROD_SEQ FROM PROD_MST WHERE PROD_CODE = @p_prod_code);
    SET @t_user_seq = (SELECT USER_SEQ FROM USER_MST WHERE USER_ID  = @p_user_id);
    
    DELETE 
    FROM 
    CART_MST 
    WHERE 
    USER_SEQ = @t_user_seq 
    AND 
    PROD_SEQ = @t_prod_seq 
    AND 
    CART_STATE_CODE = '118001'
    AND
    CART_TYPE_CODE = @p_cart_type_code;
    
    INSERT INTO CART_MST 
	(
		USER_SEQ,
		PROD_SEQ,
		REG_DATE,
		QUANTITY,
		CART_TYPE_CODE,
		CART_STATE_CODE,
		PRICE,
		UNIT_PRICE
	)
    VALUES
	(
		@t_user_seq, 
		@t_prod_seq, 
		GETDATE(), 
		@p_quantity, 
		@p_cart_type_code, 
		'118001',
		0,
		0
	);
    
END


GO
