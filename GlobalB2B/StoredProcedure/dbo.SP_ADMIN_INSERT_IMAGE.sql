IF OBJECT_ID (N'dbo.SP_ADMIN_INSERT_IMAGE', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_INSERT_IMAGE
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
CREATE PROCEDURE [dbo].[SP_ADMIN_INSERT_IMAGE]
	-- Add the parameters for the stored procedure here
	@p_foreign_seq int,
	@p_image_file_path nvarchar(255),
	@p_image_type_code char(6),
	@p_sort_num int
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	INSERT INTO [GlobalB2B].[dbo].[IMAGE_MST]
           ([FOREIGN_SEQ]
           ,[IMAGE_PATH]
           ,[IMAGE_TYPE_CODE]
           ,[SORT_NUM]
           ,[REG_DATE])
     VALUES
           (@p_foreign_seq
           ,@p_image_file_path
           ,@p_image_type_code
           ,@p_sort_num
           ,GETDATE())
           
END
GO
