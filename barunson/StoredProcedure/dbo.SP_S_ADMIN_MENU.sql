IF OBJECT_ID (N'dbo.SP_S_ADMIN_MENU', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_S_ADMIN_MENU
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_S_ADMIN_MENU]
/***************************************************************
작성자	:	표수현
작성일	:	2020-02-15
DESCRIPTION	:	ADMIN - 메뉴 
SPECIAL LOGIC	:  SP_S_ADMIN_CATEGORY 2, 'N', NULL, NULL
******************************************************************
MODIFICATION
******************************************************************
수정일           작업자                DESCRIPTION
==================================================================
******************************************************************/
 @MENU_TYPE_CODE	VARCHAR(50) = NULL,	-- GNB -> MTC01 / 풋터 -> MTC01
 @CATEGORY_ID		INT = NULL			-- 선택한 카테고리의 번호 
AS

 SET NOCOUNT ON
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


	SELECT	MENU_ID, PARENT_MENU_ID, MENU_NAME, MENU_TYPE_CODE, MENU_URL,
			MENU_STEP, SORT = ISNULL(SORT, 1), DISPLAY_YN  = ISNULL(DISPLAY_YN, 'Y'),
			IMAGE_URL
	FROM	TB_COMMON_MENU  
	WHERE	MENU_TYPE_CODE = @MENU_TYPE_CODE AND 
			MENU_ID = @CATEGORY_ID OR PARENT_MENU_ID = @CATEGORY_ID
	ORDER BY 1

	

GO
