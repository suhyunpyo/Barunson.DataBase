IF OBJECT_ID (N'dbo.SP_ADMIN_UPDATE_CART_ITEM_PRINT', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_UPDATE_CART_ITEM_PRINT
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
CREATE PROCEDURE [dbo].[SP_ADMIN_UPDATE_CART_ITEM_PRINT]
	-- Add the parameters for the stored procedure here
	@p_cart_item_print_seq int,
	@p_pdf_path nvarchar(255),
    @p_jpg_path nvarchar(255),
    @p_quantity int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE [ACube].[dbo].[CART_ITEM_PRINT_MST]
	SET [QUANTITY] = @p_quantity
	  ,[EXPORT_QUANTITY] = @p_quantity
	  ,[PDF_PATH] = @p_pdf_path
	  ,[JPG_PATH] = @p_jpg_path
	WHERE CART_ITEM_PRINT_SEQ = @p_cart_item_print_seq;
	
	DECLARE @t_cart_item_seq int;
	
	SET @t_cart_item_seq = (SELECT  CART_ITEM_SEQ FROM CART_ITEM_PRINT_MST WHERE CART_ITEM_PRINT_SEQ = @p_cart_item_print_seq);
	
	EXECUTE [ACube].[dbo].[SP_ADMIN_EXECUTE_UPDATE_CART_ITEM_INFO] 
		@t_cart_item_seq;    
	
END

GO
