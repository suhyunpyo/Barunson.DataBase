IF OBJECT_ID (N'dbo.SP_SELECT_BANNER_MST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_BANNER_MST
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
CREATE PROCEDURE [dbo].[SP_SELECT_BANNER_MST] 
	@COMPANY_SEQ	INT,
	@BANNER_TYPE	CHAR(1) = ''
AS
BEGIN	
	SET NOCOUNT ON;

    SELECT 
		BANNER_SEQ,
		COMPANY_SEQ,
		BANNER_TYPE,
		BANNER_TITLE,
		BANNER_IMAGE_URL,
		PAGE_LINK_URL,
		DISPLAY_YN,
		SORT_NUM,
		REG_ID,
		REG_DATE,
		UPD_ID,
		UPD_DATE 
	FROM BANNER_MST
	WHERE 
		COMPANY_SEQ = @COMPANY_SEQ
		AND (ISNULL(@BANNER_TYPE, '') = '' OR BANNER_TYPE = @BANNER_TYPE)
		AND DISPLAY_YN = 'Y'
	ORDER BY SORT_NUM 
	
END
GO