IF OBJECT_ID (N'dbo.SP_T_ADMIN_PRODUCT_CATEGORY', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_T_ADMIN_PRODUCT_CATEGORY
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_T_ADMIN_PRODUCT_CATEGORY]
/***************************************************************
작성자	:	표수현
작성일	:	2020-02-15
DESCRIPTION	:	ADMIN - 메인 / 카데고리 분류에 상품 저장 / 상품에 매칭된 카테고리 변경 / 특정 카테고리 상품 진열 취소 
SPECIAL LOGIC	:
******************************************************************
MODIFICATION
******************************************************************
수정일           작업자                DESCRIPTION
==================================================================
******************************************************************/
 @GUBUN	CHAR(2) = 'I',	--  I(대문자 I) : 저장 / U : 수정 / D : 삭제 / U2 : 카테고리 변경
 @ID OBJECTTYPE READONLY, -- 테이블 반환 매개변수 
 @DISPLAY_YN CHAR(1) = NULL,
 @CATEGORY_ID INT = NULL,
 @USER_ID VARCHAR(50) = NULL,
 @IP VARCHAR(15) = NULL
AS

 SET NOCOUNT ON
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 

 IF @GUBUN = 'I' BEGIN
	
	--DECLARE @OBJECTTYPE OBJECTTYPE

	--INSERT INTO @OBJECTTYPE (ID) VALUES(3)
	--SELECT ID, ID2 FROM @OBJECTTYPE

	/* 메인 진열 OR 카테고리 진열 상품추가 화면에서 상품을 특정분류에 추가 */

	DECLARE @SORT  INT

	SELECT @SORT = ISNULL(MAX(SORT), 0) + 1  
	FROM DBO.TB_PRODUCT_CATEGORY

	INSERT INTO TB_PRODUCT_CATEGORY (CATEGORY_ID, PRODUCT_ID, SORT, REGIST_DATETIME, REGIST_USER_ID, REGIST_IP, UPDATE_USER_ID, UPDATE_DATETIME, UPDATE_IP)
	SELECT PRODUCT_ID = ID2, CATEGORDID = ID, @SORT, GETDATE(), @USER_ID, @IP,  @USER_ID, GETDATE(), @IP 
	FROM @ID

	--SELECT ID, ID2, @SORT, 'Y' 
	--FROM @ID

 END ELSE IF  @GUBUN = 'U' BEGIN 

	/* 1. TB_PRODUCT_CATEGORY에 특정 카데고리에 해당하는 상품의 진열여부값 변경 */
	/* 2. TB_PRODUCT_CATEGORY에 특정 카데고리에 해당하는 상품 삭제 */
	
	DELETE FROM TB_PRODUCT_CATEGORY 
	FROM TB_PRODUCT_CATEGORY A INNER JOIN 
		 @ID B ON A.PRODUCT_ID = B.ID AND  
		 A.CATEGORY_ID = B.ID2

	--UPDATE TB_PRODUCT_CATEGORY
	--SET  TB_PRODUCT_CATEGORY.DISPLAY_YN = @DISPLAY_YN , 
	--	 TB_PRODUCT_CATEGORY.REGIST_DATETIME = GETDATE()
	--FROM TB_PRODUCT_CATEGORY A JOIN @ID B ON A.CATEGORY_ID = B.ID2 
	--WHERE  A.PRODUCT_ID = B.ID
 
 END ELSE IF  @GUBUN = 'U2' BEGIN 

	/* TB_PRODUCT_CATEGORY에서 특정 카데고리로 변경 */

	UPDATE TB_PRODUCT_CATEGORY
	SET  TB_PRODUCT_CATEGORY.CATEGORY_ID = @CATEGORY_ID, 
		 TB_PRODUCT_CATEGORY.UPDATE_USER_ID = @USER_ID,
		 TB_PRODUCT_CATEGORY.UPDATE_DATETIME = GETDATE(),
		 TB_PRODUCT_CATEGORY.UPDATE_IP = @IP
	FROM TB_PRODUCT_CATEGORY A JOIN @ID B ON A.CATEGORY_ID = B.ID2 
	WHERE  A.PRODUCT_ID = B.ID and A.Category_ID = B.ID2

 END ELSE IF @GUBUN = 'D' BEGIN  

	/* TB_PRODUCT_CATEGORY에서 특정 카데고리에 해당하는 상품 삭제 */

	UPDATE TB_PRODUCT
	SET DISPLAY_YN = 'N'
	FROM TB_PRODUCT A JOIN @ID B ON A.PRODUCT_ID = B.ID

	DELETE FROM TB_PRODUCT_CATEGORY 
	FROM TB_PRODUCT_CATEGORY A INNER JOIN 
		 @ID B ON A.PRODUCT_ID = B.ID AND  
		 A.CATEGORY_ID = B.ID2

 END 
GO