IF OBJECT_ID (N'dbo.SP_ADMIN_INSERT_ORDER', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_INSERT_ORDER
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
CREATE PROCEDURE [dbo].[SP_ADMIN_INSERT_ORDER]
	-- Add the parameters for the stored procedure here
	@p_order_code nvarchar(255),
	@p_request_status_type_code nchar(6),
	@p_order_status_type_code nchar(6),
	@p_memo ntext,
	@p_xml_file_path nvarchar(255) = null,
	@p_xml_url nvarchar(255) = null,
	@r_result int output	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @t_exist_count int;
	
	SET @t_exist_count = (SELECT COUNT(*) FROM ORDER_MST WHERE ORDER_CODE = @p_order_code);

	IF(@t_exist_count < 1)
	BEGIN
		INSERT INTO [ACube].[dbo].[ORDER_MST]
			   ([ORDER_CODE]
			   ,[REQUEST_STATUS_TYPE_CODE]
			   ,[ORDER_STATUS_TYPE_CODE]
			   ,[MEMO]
			   ,[XML_DATA_PATH]
			   ,[XML_URL]
			   ,[REG_DATE])
		 VALUES
			   (@p_order_code
			   ,@p_request_status_type_code
			   ,@p_order_status_type_code
			   ,@p_memo
			   ,@p_xml_file_path
			   ,@p_xml_url
			   ,GETDATE());
			   
		SET @r_result = SCOPE_IDENTITY();
	END
END

GO
