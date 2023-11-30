IF OBJECT_ID (N'dbo.SP_ADMIN_INSERT_PRODUCT_ADDON', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_INSERT_PRODUCT_ADDON
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
CREATE PROCEDURE [dbo].[SP_ADMIN_INSERT_PRODUCT_ADDON]
	-- Add the parameters for the stored procedure here
	@p_prod_seq int,
	@p_addon_prod_seq int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	INSERT INTO [ACube].[dbo].[PROD_ADDON_MST]
           ([PROD_SEQ]
           ,[ADDON_PROD_SEQ]
           ,[ADDON_PROD_QUANTITY]
           ,[REG_DATE])
     VALUES
           (@p_prod_seq
           ,@p_addon_prod_seq
           ,0
           ,GETDATE())


	
END

GO
