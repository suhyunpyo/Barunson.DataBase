IF OBJECT_ID (N'dbo.SP_ADMIN_SELECT_BANNER_LIST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_SELECT_BANNER_LIST
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
CREATE PROCEDURE [dbo].[SP_ADMIN_SELECT_BANNER_LIST]
	@p_banner_type_code char(6)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	

	SELECT
	BM.*,
	FM.ORG_FILE_NAME,
	FM.UPLOAD_FILE_NAME,
	FM.UPLOAD_FILE_PATH,
	FM.CONTENT_TYPE
	FROM BANNER_MST BM
	LEFT JOIN UPLOAD_FILE_MST FM ON BM.BANNER_IMAGE_FILE_SEQ = FM.FILE_SEQ
	WHERE 
		ISNULL(@p_banner_type_code, '') = '' OR BM.BANNER_TYPE_CODE = @p_banner_type_code
	ORDER BY BM.SORT_NUM 
END
GO
