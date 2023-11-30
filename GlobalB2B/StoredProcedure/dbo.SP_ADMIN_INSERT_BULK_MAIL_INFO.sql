IF OBJECT_ID (N'dbo.SP_ADMIN_INSERT_BULK_MAIL_INFO', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_INSERT_BULK_MAIL_INFO
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
CREATE PROCEDURE [dbo].[SP_ADMIN_INSERT_BULK_MAIL_INFO]
	-- Add the parameters for the stored procedure here
	@p_bulk_mail_title nvarchar(255),
	@p_csv_file_seq int,
	@p_schedule_date datetime,
	@r_bulk_mail_seq int OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	INSERT INTO [GlobalB2B].[dbo].[BULK_MAIL_MST]
           ([BULK_MAIL_TITLE]
           ,[CSV_FILE_SEQ]
           ,[SCHEDULE_DATE]
           ,[REG_DATE])
     VALUES
           (@p_bulk_mail_title
           ,@p_csv_file_seq
           ,@p_schedule_date
           ,GETDATE())

	SET @r_bulk_mail_seq = CAST(SCOPE_IDENTITY() AS INT);

END

GO
