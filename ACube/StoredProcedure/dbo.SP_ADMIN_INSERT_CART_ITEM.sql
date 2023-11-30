IF OBJECT_ID (N'dbo.SP_ADMIN_INSERT_CART_ITEM', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_INSERT_CART_ITEM
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
CREATE PROCEDURE [dbo].[SP_ADMIN_INSERT_CART_ITEM]
	-- Add the parameters for the stored procedure here
	@p_cart_seq int,
	@p_prod_seq int,
	@p_quantity int,
	@r_result int = null output 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
		
    INSERT INTO [ACube].[dbo].[CART_ITEM_MST]
           ([CART_SEQ]
           ,[PROD_SEQ]
           ,[QUANTITY]
           ,[EXPORT_QUANTITY]
           ,[REG_DATE])
     VALUES
           (@p_cart_seq
           ,@p_prod_seq
           ,@p_quantity
           ,@p_quantity
           ,GETDATE());
           
    SET @r_result = SCOPE_IDENTITY();
        
	EXECUTE [ACube].[dbo].[SP_ADMIN_EXECUTE_UPDATE_CART_ITEM_INFO] 
		@r_result;    
END

GO
