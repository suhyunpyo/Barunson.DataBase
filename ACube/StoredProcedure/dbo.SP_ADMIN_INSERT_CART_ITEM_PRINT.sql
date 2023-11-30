IF OBJECT_ID (N'dbo.SP_ADMIN_INSERT_CART_ITEM_PRINT', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_INSERT_CART_ITEM_PRINT
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
CREATE PROCEDURE [dbo].[SP_ADMIN_INSERT_CART_ITEM_PRINT]
	-- Add the parameters for the stored procedure here
	@p_cart_item_seq int,
    @p_pdf_path nvarchar(255) = null,
    @p_jpg_path nvarchar(255) = null,
    @p_quantity int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    
    INSERT INTO [ACube].[dbo].[CART_ITEM_PRINT_MST]
           ([CART_ITEM_SEQ]
           ,[QUANTITY]
           ,[EXPORT_QUANTITY]
           ,[PDF_PATH]
           ,[JPG_PATH]
           ,[REG_DATE])
     VALUES
           (@p_cart_item_seq
           ,@p_quantity
           ,@p_quantity
           ,@p_pdf_path
           ,@p_jpg_path
           ,GETDATE());
           
     EXECUTE [ACube].[dbo].[SP_ADMIN_EXECUTE_UPDATE_CART_ITEM_INFO] 
		@p_cart_item_seq;    
    
	
END

GO
