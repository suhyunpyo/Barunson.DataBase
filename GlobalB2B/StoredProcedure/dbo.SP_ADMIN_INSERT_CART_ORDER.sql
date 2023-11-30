IF OBJECT_ID (N'dbo.SP_ADMIN_INSERT_CART_ORDER', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_INSERT_CART_ORDER
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
CREATE PROCEDURE [dbo].[SP_ADMIN_INSERT_CART_ORDER]
	-- Add the parameters for the stored procedure here
	@p_order_seq int,
	@p_prod_seq int,
	@p_quantity int,
	@p_cart_type nvarchar(6)
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF(@p_cart_type IS NULL)
		SET @p_cart_type = '111001';
		
	DECLARE @t_user_seq int;
	SET @t_user_seq = (SELECT TOP 1 USER_SEQ FROM ORDER_MST WHERE ORDER_SEQ = @p_order_seq);
	
	INSERT INTO [GlobalB2B].[dbo].[CART_MST]
           ([ORDER_SEQ]
           ,[USER_SEQ]
           ,[PROD_SEQ]
           ,[CART_TYPE_CODE]
           ,[CART_STATE_CODE]
           ,[QUANTITY]
           ,[PRICE]
           ,[UNIT_PRICE]
           ,[REG_DATE])
     VALUES
           (@p_order_seq
           ,@t_user_seq
           ,@p_prod_seq
           ,@p_cart_type
           ,'118002'
           ,@p_quantity
           ,0
           ,0
           ,GETDATE())
	
END


GO
