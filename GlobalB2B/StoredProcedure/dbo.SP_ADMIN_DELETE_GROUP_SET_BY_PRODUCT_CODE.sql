IF OBJECT_ID (N'dbo.SP_ADMIN_DELETE_GROUP_SET_BY_PRODUCT_CODE', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_DELETE_GROUP_SET_BY_PRODUCT_CODE
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
CREATE PROCEDURE [dbo].[SP_ADMIN_DELETE_GROUP_SET_BY_PRODUCT_CODE]
	-- Add the parameters for the stored procedure here
	@p_group_type_code char(6)
	,@p_prod_code nvarchar(15)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @t_prod_seq int;
	SET @t_prod_seq = (SELECT PROD_SEQ FROM PROD_MST WHERE PROD_CODE = @p_prod_code);
	
	IF(@t_prod_seq IS NOT NULL)
		DELETE FROM PROD_GROUP WHERE PROD_SEQ = @t_prod_seq AND TYPE_CODE = @p_group_type_code;
END
GO
