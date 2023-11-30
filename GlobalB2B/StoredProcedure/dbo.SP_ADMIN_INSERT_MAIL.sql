IF OBJECT_ID (N'dbo.SP_ADMIN_INSERT_MAIL', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_INSERT_MAIL
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
CREATE PROCEDURE [dbo].[SP_ADMIN_INSERT_MAIL]
	-- Add the parameters for the stored procedure here
	@p_mail_type_code char(6)
	,@p_site_name nvarchar(255)
	,@p_from_name nvarchar(100)
	,@p_from_email nvarchar(255)
	,@p_to_name nvarchar(100)
	,@p_to_email nvarchar(255)
	,@p_title nvarchar(255)
	,@p_content ntext
	,@p_bulk_mail_seq int = NULL
	,@p_schedule_date datetime = NULL
	
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @p_is_unsubscripbe int;
	SET @p_is_unsubscripbe = 0;
	
	IF(@p_schedule_date IS NULL)
		SET @p_schedule_date = GETDATE();
	
	IF(@p_bulk_mail_seq IS NOT NULL)
	BEGIN
		SET @p_is_unsubscripbe = (SELECT COUNT(*) FROM UNSUBSCRIBE_MAIL_ADDR_MST WHERE MAIL_ADDR = @p_to_email);
	END
	
	
	IF(@p_is_unsubscripbe = 0)
	BEGIN
		INSERT INTO [GlobalB2B].[dbo].[MAIL_MST]
			   ([MAIL_TYPE_CODE]
			   ,[SITE_NAME]
			   ,[FROM_MAIL_ADDR]
			   ,[FROM_MAIL_NAME]
			   ,[TO_MAIL_ADDR]
			   ,[TO_MAIL_NAME]
			   ,[MAIL_TITLE]
			   ,[MAIL_CONTENT]
			   ,[SEND_YORN]
			   ,[FAIL_YORN]
			   ,[BULK_MAIL_SEQ]
			   ,[SCHEDULE_DATE]
			   ,[SEND_DATE]
			   ,[REG_DATE])
		 VALUES
			   (@p_mail_type_code
			   ,@p_site_name
			   ,@p_from_email
			   ,@p_from_name
			   ,@p_to_email
			   ,@p_to_name
			   ,@p_title
			   ,@p_content
			   ,'N'
			   ,'N'
			   ,@p_bulk_mail_seq
			   ,@p_schedule_date
			   ,NULL
			   ,GETDATE());
	END
	
	    
END

GO
