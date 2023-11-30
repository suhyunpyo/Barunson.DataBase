IF OBJECT_ID (N'dbo.SP_T_ADMIN_INSERT', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_T_ADMIN_INSERT
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_T_ADMIN_INSERT]
/***************************************************************
작성자	:	표수현
작성일	:	2020-02-15
DESCRIPTION	:	ADMIN - 관리자 추가 / 삭제
SPECIAL LOGIC	:
******************************************************************
MODIFICATION
******************************************************************
수정일           작업자                DESCRIPTION
==================================================================
******************************************************************/
 @GUBUN	CHAR(2) = 'I',	--  I(대문자 I) : 저장 /  D : 삭제
 @ADMIN_ID VARCHAR(50) = NULL,
 @ADMIN_PWD VARCHAR(50) = NULL,
 @ADMIN_NAME VARCHAR(50) = NULL,
 @ADMIN_LEVEL INT = 0
  
AS

 SET NOCOUNT ON
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 

 IF @GUBUN = 'I' BEGIN
 
	DECLARE @MEMBERCNT INT = 0

	SELECT @MEMBERCNT = COUNT(*)
	FROM  BARUNSON.DBO.TB_INVITATION_ADMIN
	WHERE ADMIN_ID = @ADMIN_ID

	 IF @MEMBERCNT > 0 BEGIN

		SELECT 'FAIL'

	 END ELSE BEGIN 
 	
		INSERT INTO BARUNSON.DBO.TB_INVITATION_ADMIN (ADMIN_ID, ADMIN_PWD, ADMIN_NAME, ADMIN_LEVEL, REG_DATE)
		VALUES (@ADMIN_ID, @ADMIN_PWD, @ADMIN_NAME, @ADMIN_LEVEL, GETDATE())

		SELECT 'SUCCESS'

	 END 

 END ELSE IF  @GUBUN = 'D' BEGIN 

	DELETE FROM BARUNSON.DBO.TB_INVITATION_ADMIN 
	WHERE ADMIN_ID = @ADMIN_ID AND 
		  ADMIN_NAME = @ADMIN_NAME

 END

GO
