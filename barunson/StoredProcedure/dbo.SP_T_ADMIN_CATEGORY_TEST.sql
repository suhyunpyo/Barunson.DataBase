IF OBJECT_ID (N'dbo.SP_T_ADMIN_CATEGORY_TEST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_T_ADMIN_CATEGORY_TEST
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_T_ADMIN_CATEGORY_TEST]
/***************************************************************
작성자	:	표수현
작성일	:	2020-02-15
DESCRIPTION	:	ADMIN - 메인 / 카데고리 분류 저장
SPECIAL LOGIC	: SP_T_ADMIN_CATEGORY 'I', 'CTC02', 'CNC01', 'TEXTPC', NULL, 'TEXTM', NULL, NULL, 1, 'Y' ,'바른손','세일상품' , NULL

SP_T_ADMIN_CATEGORY 'D', 'CTC01', 19
******************************************************************
MODIFICATION
******************************************************************
수정일           작업자                DESCRIPTION
==================================================================
******************************************************************/
 @GUBUN						CHAR(1) = 'I',			--  I(대문자 I) : 저장 / U : 수정 / D : 삭제 
 @CATEGORY_TYPE_CODE		VARCHAR(50) = NULL,		-- 분류_구분_코드 (메인 CTC01 / 카테고리 CTC02)
 @CATEGORY_NAME1			VARCHAR(100) = NULL,	-- 대분류명
 @CATEGORY_NAME_TYPE_CODE1	VARCHAR(50) = NULL,		-- 대분류_명_구분_코드 (CNC01 텍스트 / CNC02	이미지)
 @CATEGORY_NAME_PC1			VARCHAR(100) = NULL,	-- 대분류_명_PC 
 @CATEGORY_NAME_PC_URL1		VARCHAR(1000) = NULL,	-- 대분류_명_PC_URL
 @CATEGORY_NAME_MOBILE1		VARCHAR(100) = NULL,	-- 대분류_명_모바일
 @CATEGORY_NAME_MOBILE_URL1	VARCHAR(1000) = NULL,	-- 대분류_명_모바일_URL  
 @CATEGORY_STEP1			INT = NULL,				-- 대분류_단계 
 @SORT						INT = NULL,				-- 분류순서
 @DISPLAY_YN1				CHAR(1) = 'N',			-- 대분류진열여부 

 --@CATEGORY_NAME2			VARCHAR(100) = NULL,	-- 중분류명
 --@CATEGORY_NAME_TYPE_CODE2	VARCHAR(50) = NULL,		-- 중분류_명_구분_코드 (CNC01 텍스트 / CNC02	이미지)
 --@CATEGORY_NAME_PC2			VARCHAR(100) = NULL,	-- 중분류_명_PC 
 --@CATEGORY_NAME_PC_URL2		VARCHAR(1000) = NULL,	-- 중분류_명_PC_URL
 --@CATEGORY_NAME_MOBILE2		VARCHAR(100) = NULL,	-- 중분류_명_모바일
 --@CATEGORY_NAME_MOBILE_URL2	VARCHAR(1000) = NULL,	-- 중분류_명_모바일_URL  
 --@CATEGORY_STEP2			INT = NULL,				-- 중분류_단계
 --@DISPLAY_YN2				CHAR(1) = 'N',			-- 중분류진열여부 
 @DEPTH2_YN				INT = 0,	-- 중분류 존재 여부 
 @DEL_UP_CATEGORY_ID1		INT = NULL,				-- 삭제하거나 수정할 대분류 카테고리ID
 @DEL_UP_CATEGORY_ID2		INT = NULL,				-- 삭제하거나 수정할 중분류 카테고리ID
 @DEPTH2					DEPTH2LISTTYPE READONLY,
 @ID						OBJECTTYPE READONLY		-- 테이블 반환 매개변수 
AS

 SET NOCOUNT ON
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

 -- 순서 업데이트  
 UPDATE TB_CATEGORY
 SET TB_CATEGORY.SORT = B.ID2
 FROM TB_CATEGORY A INNER JOIN @ID B ON A.CATEGORY_ID = B.ID
 WHERE A.CATEGORY_TYPE_CODE = @CATEGORY_TYPE_CODE


 IF @GUBUN = 'I' BEGIN
	
	DECLARE @CATEGORY_ID  INT
	DECLARE @PARENT_CATEGORY_ID  INT

	/* 대분류 정보를 저장하므로 PARENT_CATEGORY_ID는 NULL값이 들어감 */
	INSERT INTO DBO.TB_CATEGORY (PARENT_CATEGORY_ID, CATEGORY_NAME, CATEGORY_TYPE_CODE, CATEGORY_NAME_TYPE_CODE, CATEGORY_NAME_PC, CATEGORY_NAME_PC_URL,
								CATEGORY_NAME_MOBILE, CATEGORY_NAME_MOBILE_URL, CATEGORY_STEP, SORT, DISPLAY_YN) 
	VALUES (NULL, @CATEGORY_NAME1, @CATEGORY_TYPE_CODE, @CATEGORY_NAME_TYPE_CODE1, @CATEGORY_NAME_PC1, @CATEGORY_NAME_PC_URL1,
			@CATEGORY_NAME_MOBILE1, @CATEGORY_NAME_MOBILE_URL1, @CATEGORY_STEP1, @SORT, @DISPLAY_YN1)
	
	IF @DEPTH2_YN > 0 BEGIN 

		SET @PARENT_CATEGORY_ID = @@IDENTITY

		SELECT @CATEGORY_ID = ISNULL(MAX(CATEGORY_ID), 0) + 1
		FROM DBO.TB_CATEGORY
	
		IF @CATEGORY_TYPE_CODE = 'CTC02' BEGIN  -- 소분류명 저장 (카테고리 분류 추가일 경우)
	
			INSERT INTO DBO.TB_CATEGORY (PARENT_CATEGORY_ID, CATEGORY_NAME, CATEGORY_TYPE_CODE, CATEGORY_NAME_TYPE_CODE, CATEGORY_NAME_PC, CATEGORY_NAME_PC_URL,
										CATEGORY_NAME_MOBILE, CATEGORY_NAME_MOBILE_URL, CATEGORY_STEP, SORT, DISPLAY_YN) 
			SELECT  @PARENT_CATEGORY_ID, CATEGORY_NAME, CATEGORY_TYPE_CODE, CATEGORY_NAME_TYPE_CODE, CATEGORY_NAME_PC, CATEGORY_NAME_PC_URL,
					NULL, NULL, CATEGORY_STEP, SORT, DISPLAY_YN
			FROM	@DEPTH2

			--INSERT INTO DBO.TB_CATEGORY (PARENT_CATEGORY_ID, CATEGORY_NAME, CATEGORY_TYPE_CODE, CATEGORY_NAME_TYPE_CODE, CATEGORY_NAME_PC, CATEGORY_NAME_PC_URL,
			--							CATEGORY_NAME_MOBILE, CATEGORY_NAME_MOBILE_URL, CATEGORY_STEP, SORT, DISPLAY_YN) 
			--VALUES (@PARENT_CATEGORY_ID, @CATEGORY_NAME2, @CATEGORY_TYPE_CODE, @CATEGORY_NAME_TYPE_CODE2, @CATEGORY_NAME_PC2, @CATEGORY_NAME_PC_URL2,
			--		@CATEGORY_NAME_MOBILE2, @CATEGORY_NAME_MOBILE_URL2, @CATEGORY_STEP2, @SORT, @DISPLAY_YN2)

		END 


	END 
	


 END ELSE IF @GUBUN = 'U' BEGIN 
		
	UPDATE TB_CATEGORY
	SET CATEGORY_NAME = @CATEGORY_NAME_PC1,
		--CATEGORY_TYPE_CODE = @CATEGORY_TYPE_CODE,
		CATEGORY_NAME_TYPE_CODE = @CATEGORY_NAME_TYPE_CODE1,
		CATEGORY_NAME_PC = @CATEGORY_NAME_PC1,
		CATEGORY_NAME_PC_URL = @CATEGORY_NAME_PC_URL1,
		CATEGORY_NAME_MOBILE = @CATEGORY_NAME_MOBILE1,
		CATEGORY_NAME_MOBILE_URL = @CATEGORY_NAME_MOBILE_URL1,
		--CATEGORY_STEP = @CATEGORY_STEP1,
		DISPLAY_YN = @DISPLAY_YN1
	WHERE CATEGORY_ID = @DEL_UP_CATEGORY_ID1

	IF @CATEGORY_TYPE_CODE = 'CTC02' BEGIN 

		 UPDATE TB_CATEGORY
		 SET TB_CATEGORY.CATEGORY_NAME = B.CATEGORY_NAME,
			TB_CATEGORY.CATEGORY_NAME_PC = B.CATEGORY_NAME_PC,
			TB_CATEGORY.CATEGORY_NAME_TYPE_CODE  = B.CATEGORY_NAME_TYPE_CODE,
			TB_CATEGORY.CATEGORY_NAME_PC_URL  = B.CATEGORY_NAME_PC_URL,
			TB_CATEGORY.CATEGORY_STEP = B.CATEGORY_STEP,
			TB_CATEGORY.DISPLAY_YN = B.DISPLAY_YN
		 FROM TB_CATEGORY A INNER JOIN @DEPTH2 B ON A.CATEGORY_ID = B.CATEGORY_ID
		 WHERE B.Category_ID > 0

	 
		INSERT INTO DBO.TB_CATEGORY (PARENT_CATEGORY_ID, CATEGORY_NAME, CATEGORY_TYPE_CODE, CATEGORY_NAME_TYPE_CODE, CATEGORY_NAME_PC, CATEGORY_NAME_PC_URL,
											CATEGORY_NAME_MOBILE, CATEGORY_NAME_MOBILE_URL, CATEGORY_STEP, SORT, DISPLAY_YN) 
		SELECT  @DEL_UP_CATEGORY_ID1, CATEGORY_NAME, CATEGORY_TYPE_CODE, CATEGORY_NAME_TYPE_CODE, CATEGORY_NAME_PC, CATEGORY_NAME_PC_URL,
				NULL, NULL, CATEGORY_STEP, SORT, DISPLAY_YN
		FROM	@DEPTH2
		 WHERE  Category_ID = 0


	END


	

	--UPDATE TB_CATEGORY
	--SET --CATEGORY_NAME = @CATEGORY_NAME2,
	--	--CATEGORY_TYPE_CODE = @CATEGORY_TYPE_CODE,
	--	CATEGORY_NAME_TYPE_CODE = @CATEGORY_NAME_TYPE_CODE2,
	--	CATEGORY_NAME_PC = @CATEGORY_NAME_PC2,
	--	CATEGORY_NAME_PC_URL = @CATEGORY_NAME_PC_URL2,
	--	CATEGORY_NAME_MOBILE = @CATEGORY_NAME_MOBILE2,
	--	CATEGORY_NAME_MOBILE_URL = @CATEGORY_NAME_MOBILE_URL2,
	--	CATEGORY_STEP = @CATEGORY_STEP2,
	--	DISPLAY_YN = @DISPLAY_YN1
	--WHERE CATEGORY_ID = @DEL_UP_CATEGORY_ID2

	--	IF @CATEGORY_TYPE_CODE = 'CTC02' BEGIN 
			
	--		UPDATE TB_CATEGORY
	--		SET CATEGORY_NAME = @CATEGORY_NAME2,
	--			CATEGORY_TYPE_CODE = @CATEGORY_TYPE_CODE,
	--			CATEGORY_NAME_TYPE_CODE = @CATEGORY_NAME_TYPE_CODE,
	--			CATEGORY_NAME_PC = @CATEGORY_NAME_PC,
	--			CATEGORY_NAME_PC_URL = @CATEGORY_NAME_PC_URL,
	--			CATEGORY_NAME_MOBILE = @CATEGORY_NAME_MOBILE,
	--			CATEGORY_NAME_MOBILE_URL = @CATEGORY_NAME_MOBILE_URL,
	--			CATEGORY_STEP = @CATEGORY_STEP,
	--			SORT = @SORT,
	--			DISPLAY_YN = @DISPLAY_YN
	--		WHERE PARENT_CATEGORY_ID = @DEL_UP_CATEGORY_ID

	--END 
	

 END ELSE IF @GUBUN = 'D' BEGIN  -- 삭제 
	
			IF @CATEGORY_TYPE_CODE = 'CTC01' BEGIN -- 대분류 

				DELETE FROM TB_CATEGORY 
				WHERE CATEGORY_TYPE_CODE = @CATEGORY_TYPE_CODE AND
					  CATEGORY_ID = @DEL_UP_CATEGORY_ID1

				DELETE 
				FROM  TB_PRODUCT_CATEGORY
				WHERE CATEGORY_ID = @DEL_UP_CATEGORY_ID1

			END ELSE BEGIN 

				DECLARE @CATEGORY_STEP INT
				DECLARE @C_PARENT_CATEGORY_ID INT

				SELECT @CATEGORY_STEP = CATEGORY_STEP,
					   @C_PARENT_CATEGORY_ID = PARENT_CATEGORY_ID
				FROM  DBO.TB_CATEGORY
				WHERE CATEGORY_TYPE_CODE = @CATEGORY_TYPE_CODE AND
					  CATEGORY_ID = @DEL_UP_CATEGORY_ID1 

				IF @CATEGORY_STEP = 1 BEGIN -- 대/중분류 삭제 

					DELETE FROM TB_CATEGORY 
					WHERE CATEGORY_TYPE_CODE = @CATEGORY_TYPE_CODE AND
						  CATEGORY_ID = @DEL_UP_CATEGORY_ID1 OR PARENT_CATEGORY_ID = @DEL_UP_CATEGORY_ID1

					DELETE 
					FROM  TB_PRODUCT_CATEGORY
					WHERE CATEGORY_ID = @DEL_UP_CATEGORY_ID1 OR CATEGORY_ID = @C_PARENT_CATEGORY_ID

				END ELSE BEGIN  --중분류 삭제 
					
					DELETE FROM TB_CATEGORY 
					WHERE CATEGORY_TYPE_CODE = @CATEGORY_TYPE_CODE AND
						  CATEGORY_ID = @DEL_UP_CATEGORY_ID1 

					DELETE 
					FROM  TB_PRODUCT_CATEGORY
					WHERE CATEGORY_ID = @DEL_UP_CATEGORY_ID1

				END 
 
			END 
 END 
GO
