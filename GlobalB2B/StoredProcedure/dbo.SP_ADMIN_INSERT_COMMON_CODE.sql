IF OBJECT_ID (N'dbo.SP_ADMIN_INSERT_COMMON_CODE', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_INSERT_COMMON_CODE
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
CREATE PROCEDURE [dbo].[SP_ADMIN_INSERT_COMMON_CODE]
	-- Add the parameters for the stored procedure here
	@p_cmmn_code char(6),
	@p_lang_code char(2),
	@p_clss_code char(3),
	@p_clss_name nvarchar(150),
	@p_dtl_clss char(3),
	@p_dtl_name nvarchar(150),
	@p_dtl_desc nvarchar(150),
	@p_use_yorn char(1),
	@p_display_yorn char(1),
	@p_sort_num int,
	@p_reg_id nvarchar(50)
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	INSERT INTO [GlobalB2B].[dbo].[COMMON_CODE]
           ([CMMN_CODE]
           ,[LANG_CODE]
           ,[CLSS_CODE]
           ,[CLSS_NAME]
           ,[DTL_CLSS]
           ,[DTL_NAME]
           ,[DTL_DESC]
           ,[RMRK_CLMN]
           ,[USE_YORN]
           ,[DISPLAY_YORN]
           ,[SORT_NUM]
           ,[REG_DATE]
           ,[REG_ID]
           ,[MDF_DATE]
           ,[MDF_ID])
     VALUES
           (@p_cmmn_code
           ,@p_lang_code
           ,@p_clss_code
           ,@p_clss_name
           ,@p_dtl_clss
           ,@p_dtl_name
           ,@p_dtl_desc
           ,NULL
           ,@p_use_yorn
           ,@p_display_yorn
           ,@p_sort_num
           ,GETDATE()
           ,@p_reg_id
           ,NULL
           ,NULL);


END

GO
