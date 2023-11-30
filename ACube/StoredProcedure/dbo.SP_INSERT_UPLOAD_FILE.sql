IF OBJECT_ID (N'dbo.SP_INSERT_UPLOAD_FILE', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_INSERT_UPLOAD_FILE
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
CREATE PROCEDURE [dbo].[SP_INSERT_UPLOAD_FILE]
	-- Add the parameters for the stored procedure here
	@p_org_file_name nvarchar(255),
	@p_content_type nvarchar(255),
	@p_content_length int,
	@p_upload_file_path nvarchar(255),
	@p_upload_file_name nvarchar(255),
	@p_temp_id nvarchar(255),
	@r_upload_file_seq int OUTPUT
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	
	IF(@p_content_length IS NULL)
		SET @p_content_length = 0;
	

    -- Insert statements for procedure here
	INSERT INTO [ACube].[dbo].[UPLOAD_FILE_MST]
           ([ORG_FILE_NAME]
           ,[CONTENT_TYPE]
           ,[CONTENT_LENGTH]
           ,[UPLOAD_FILE_PATH]
           ,[UPLOAD_FILE_NAME]
           ,[TEMP_ID]
           ,[REG_DATE])
     VALUES
           (@p_org_file_name
           ,@p_content_type
           ,@p_content_length
           ,@p_upload_file_path
           ,@p_upload_file_name
           ,@p_temp_id
           ,GETDATE());
           
     SET @r_upload_file_seq = CAST(SCOPE_IDENTITY() AS INT);
END

GO
