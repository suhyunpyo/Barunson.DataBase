IF OBJECT_ID (N'dbo.SP_ADMIN_UPDATE_COMMON_CODE', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_UPDATE_COMMON_CODE
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
CREATE PROCEDURE [dbo].[SP_ADMIN_UPDATE_COMMON_CODE]
	@p_cmmn_code char(6),
	@p_clss_name nvarchar(150),
	@p_dtl_name nvarchar(150),
	@p_dtl_desc nvarchar(150),
	@p_use_yorn char(1),
	@p_display_yorn char(1),
	@p_sort_num int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	DECLARE @t_clss_code char(3);
	
	SET @t_clss_code = (SELECT CLSS_CODE FROM COMMON_CODE WHERE CMMN_CODE = @p_cmmn_code);
	
	
	UPDATE COMMON_CODE 
	SET CLSS_NAME = @p_clss_name
	WHERE CLSS_CODE = @t_clss_code;
	
	
	UPDATE COMMON_CODE
	SET 
		DTL_NAME = @p_dtl_name
		,DTL_DESC = @p_dtl_desc
		,USE_YORN = @p_use_yorn
		,DISPLAY_YORN = @p_display_yorn
		,SORT_NUM = @p_sort_num
	WHERE CMMN_CODE = @p_cmmn_code
	
	
	
	
END
GO
