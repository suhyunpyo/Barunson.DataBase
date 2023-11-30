IF OBJECT_ID (N'dbo.SP_S_ADMIN_COMMON_CODE', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_S_ADMIN_COMMON_CODE
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_S_ADMIN_COMMON_CODE]
/***************************************************************
작성자	:	표수현
작성일	:	2020-02-15
DESCRIPTION	:	ADMIN - 공통 코드정보 리스트  
SPECIAL LOGIC	: SP_S_ADMIN_COMMON_CODE 'Product_Brand_Code'
******************************************************************
MODIFICATION
******************************************************************
수정일           작업자                DESCRIPTION
==================================================================
******************************************************************/
 @CODE_GROUP	VARCHAR(100) = NULL
AS

 SELECT CODE, CODE_NAME, SORT 
 FROM TB_COMMON_CODE A INNER JOIN 
	  TB_COMMON_CODE_GROUP B  ON A.CODE_GROUP = B.CODE_GROUP
 WHERE A.CODE_GROUP = @CODE_GROUP
GO
