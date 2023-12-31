IF OBJECT_ID (N'dbo.SP_S_ADMIN_CATEGORY_DEPTH2INFO', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_S_ADMIN_CATEGORY_DEPTH2INFO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_S_ADMIN_CATEGORY_DEPTH2INFO]
/***************************************************************
작성자	:	표수현
작성일	:	2020-02-15
DESCRIPTION	:	ADMIN - 카테고리 분류에만 사용되는 프로시저(중분류 정보 조회)
SPECIAL LOGIC	: SP_S_ADMIN_CATEGORY_DEPTH2INFO  4
******************************************************************
MODIFICATION
******************************************************************
수정일           작업자                DESCRIPTION
==================================================================
******************************************************************/
 @PARENT_CATEGORYID INT = NULL --대분류 카테고리 번호 
AS

 SET NOCOUNT ON
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	SELECT	CATEGORY_ID, PARENT_CATEGORY_ID, CATEGORY_NAME, CATEGORY_TYPE_CODE, CATEGORY_NAME_TYPE_CODE,
			CATEGORY_NAME_PC, CATEGORY_NAME_PC_URL = ISNULL(CATEGORY_NAME_PC_URL, ''), CATEGORY_NAME_MOBILE, CATEGORY_NAME_MOBILE_URL = ISNULL(CATEGORY_NAME_MOBILE_URL, ''), 
			CATEGORY_STEP = ISNULL(CATEGORY_STEP,1), SORT = ISNULL(SORT, 1), DISPLAY_YN = ISNULL(DISPLAY_YN, 'Y'), CNT = (SELECT COUNT(*) FROM TB_PRODUCT_CATEGORY B WHERE B.CATEGORY_ID = A.CATEGORY_ID)
	 FROM	TB_CATEGORY A
	 WHERE	CATEGORY_TYPE_CODE = 'CTC02' AND 
			PARENT_CATEGORY_ID = @PARENT_CATEGORYID
 

GO
