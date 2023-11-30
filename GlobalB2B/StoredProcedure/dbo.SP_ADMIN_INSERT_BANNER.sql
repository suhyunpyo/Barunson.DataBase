IF OBJECT_ID (N'dbo.SP_ADMIN_INSERT_BANNER', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_INSERT_BANNER
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
CREATE PROCEDURE [dbo].[SP_ADMIN_INSERT_BANNER]
	@p_banner_type_code char(6),
	@p_banner_image_file_seq int,
	@p_banner_link_url nvarchar(255)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @t_sort_num int;
	SET @t_sort_num = (SELECT ISNULL(MAX(SORT_NUM),0) FROM BANNER_MST WHERE BANNER_TYPE_CODE = @p_banner_type_code);
	
	SET @t_sort_num = @t_sort_num + 1;

    INSERT INTO [GlobalB2B].[dbo].[BANNER_MST]
           ([BANNER_TYPE_CODE]
           ,[BANNER_IMAGE_FILE_SEQ]
           ,[BANNER_LINK_URL]
           ,[SORT_NUM]
           ,[REG_DATE])
     VALUES
           (@p_banner_type_code
           ,@p_banner_image_file_seq
           ,@p_banner_link_url
           ,@t_sort_num
           ,GETDATE())

END
GO
