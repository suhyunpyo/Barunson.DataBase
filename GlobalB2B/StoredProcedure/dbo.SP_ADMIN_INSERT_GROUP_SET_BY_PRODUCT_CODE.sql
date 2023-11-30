IF OBJECT_ID (N'dbo.SP_ADMIN_INSERT_GROUP_SET_BY_PRODUCT_CODE', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_INSERT_GROUP_SET_BY_PRODUCT_CODE
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
CREATE PROCEDURE [dbo].[SP_ADMIN_INSERT_GROUP_SET_BY_PRODUCT_CODE]
	-- Add the parameters for the stored procedure here
	@p_group_code nvarchar(30),
	@p_group_type_code char(6),
	@p_prod_code nvarchar(15)
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @t_prod_seq int,
	@t_group_sort_num int;
	
	
	SET @t_group_sort_num = (SELECT MIN(SORT_NUM) FROM PROD_GROUP WHERE GROUP_CODE = @p_group_code);
	
	IF(@t_group_sort_num IS NULL)
		BEGIN
			SET @t_group_sort_num = (SELECT IsNULL(MAX(SORT_NUM),0) + 1 FROM PROD_GROUP WHERE TYPE_CODE = @p_group_type_code);
		END
	
	
	
	
	SET @t_prod_seq = (SELECT PROD_SEQ FROM PROD_MST WHERE PROD_CODE = @p_prod_code);
	
	IF(@t_prod_seq IS NOT NULL)
	BEGIN
		INSERT INTO [GlobalB2B].[dbo].[PROD_GROUP]
			   ([GROUP_CODE]
			   ,[TYPE_CODE]
			   ,[PROD_SEQ]
			   ,SORT_NUM
			   )
		 VALUES
			   (
			   @p_group_code
			   ,@p_group_type_code
			   ,@t_prod_seq
			   ,@t_group_sort_num
			   );
	END
	
END

GO
