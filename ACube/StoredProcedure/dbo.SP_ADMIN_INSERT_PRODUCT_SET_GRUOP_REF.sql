IF OBJECT_ID (N'dbo.SP_ADMIN_INSERT_PRODUCT_SET_GRUOP_REF', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_INSERT_PRODUCT_SET_GRUOP_REF
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
CREATE PROCEDURE [dbo].[SP_ADMIN_INSERT_PRODUCT_SET_GRUOP_REF]
	-- Add the parameters for the stored procedure here
	@p_prod_set_group_seq int ,
	@p_prod_seq int,
	@p_ref_type_code nchar(6)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	INSERT INTO [ACube].[dbo].[PROD_SET_GROUP_REF_MST]
           ([PROD_SET_GROUP_SEQ]
           ,[PROD_SEQ]
           ,[REF_TYPE_CODE]
           ,[REG_DATE])
     VALUES
           (@p_prod_set_group_seq
           ,@p_prod_seq
           ,@p_ref_type_code
           ,GETDATE());
END

GO
