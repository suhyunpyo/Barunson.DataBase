IF OBJECT_ID (N'dbo.SP_T_ADMIN_BANNER_CATEGORY', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_T_ADMIN_BANNER_CATEGORY
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_T_ADMIN_BANNER_CATEGORY]
/***************************************************************
작성자	:	표수현
작성일	:	2020-02-15
DESCRIPTION	:	ADMIN - @GUBUN - D1 -> 배너 삭제
						@GUBUN - D2 -> 배너 분류 삭제
						@GUBUN - S ->  배너 등록
SPECIAL LOGIC	:
******************************************************************
MODIFICATION
******************************************************************
수정일           작업자                DESCRIPTION
==================================================================
******************************************************************/
 @GUBUN			CHAR(2) = NULL,
 @ID OBJECTTYPE READONLY, -- 테이블 반환 매개변수 
 @BANNER_CATEGORY_ID INT = NULL, 
 @BANNER_PC_YN CHAR(1) = NULL, 
 @BANNER_MOBILE_YN CHAR(1) = NULL, 
 @BANNER_NAME VARCHAR(200) = NULL,
 @BANNER_TYPE_CODE VARCHAR(50) = NULL,
 @IMAGE_URL VARCHAR(1000) = NULL,
 @DEADLINE_TYPE_CODE VARCHAR(50) = NULL, 
 @START_DATE VARCHAR(10) = NULL, 
 @START_TIME VARCHAR(2) = NULL, 
 @END_DATE VARCHAR(10) = NULL,  
 @END_TIME VARCHAR(2) = NULL, 
 @LINK_URL VARCHAR(1000) = NULL,
 @NEWPAGE_YN CHAR(1) = NULL, 
 @CLICK_COUNT INT = NULL, 
 @SORT INT = NULL,
 @REGIST_USER_ID VARCHAR(50) = NULL, 
 @REGIST_DATETIME DATETIME = NULL, 
 @REGIST_IP VARCHAR(15) = NULL, 
 @UPDATE_USER_ID VARCHAR(50) = NULL, 
 @UPDATE_DATETIME DATETIME = NULL,  
 @UPDATE_IP VARCHAR(50) = NULL

AS

 SET NOCOUNT ON
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 

 IF @GUBUN = 'D1' BEGIN

	-- 배너만 삭제 
	 DELETE FROM TB_BANNER
			FROM TB_BANNER A INNER JOIN 
			@ID B ON A.BANNER_ID = B.ID

 END ELSE IF @GUBUN = 'D2' BEGIN 
	-- 해당 분류에 속한 배너까지 같이 삭제 

	-- 1. 분류 삭제 
		DELETE FROM TB_BANNER_CATEGORY 
			   FROM TB_BANNER_CATEGORY A INNER JOIN 
			   @ID B ON A.BANNER_CATEGORY_ID = B.ID

	-- 2. 배너 삭제 
		DELETE FROM TB_BANNER
	 		   FROM TB_BANNER A INNER JOIN 
			   @ID B ON A.BANNER_CATEGORY_ID = B.ID

 END ELSE IF @GUBUN = 'S' BEGIN 

		INSERT 	TB_BANNER  (BANNER_CATEGORY_ID, BANNER_PC_YN, BANNER_MOBILE_YN, BANNER_NAME, REGIST_USER_ID, REGIST_DATETIME, REGIST_IP,
							UPDATE_USER_ID, UPDATE_DATETIME, UPDATE_IP)
		VALUES (@BANNER_CATEGORY_ID, @BANNER_PC_YN, @BANNER_MOBILE_YN, @BANNER_NAME, @REGIST_USER_ID, @REGIST_DATETIME, @REGIST_IP,
				@UPDATE_USER_ID, @UPDATE_DATETIME, @UPDATE_IP)

		DECLARE @PARENT_BANNER_ID INT = @@IDENTITY

		INSERT TB_BANNER_ITEM  (BANNER_ID, BANNER_TYPE_CODE, IMAGE_URL, DEADLINE_TYPE_CODE, START_DATE, START_TIME, END_DATE, END_TIME,
								LINK_URL, NEWPAGE_YN, CLICK_COUNT, SORT, REGIST_USER_ID, REGIST_DATETIME, REGIST_IP, UPDATE_USER_ID,
								UPDATE_DATETIME, UPDATE_IP)
		VALUES (@PARENT_BANNER_ID, @BANNER_TYPE_CODE, @IMAGE_URL, @DEADLINE_TYPE_CODE, @START_DATE, @START_TIME, @END_DATE, @END_TIME,
				@LINK_URL, @NEWPAGE_YN, @CLICK_COUNT, @SORT, @REGIST_USER_ID, @REGIST_DATETIME, @REGIST_IP, @UPDATE_USER_ID,
				@UPDATE_DATETIME, @UPDATE_IP)


 END 
GO