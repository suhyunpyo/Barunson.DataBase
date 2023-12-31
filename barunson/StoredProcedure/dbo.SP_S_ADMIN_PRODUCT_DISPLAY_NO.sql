IF OBJECT_ID (N'dbo.SP_S_ADMIN_PRODUCT_DISPLAY_NO', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_S_ADMIN_PRODUCT_DISPLAY_NO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_S_ADMIN_PRODUCT_DISPLAY_NO]
/***************************************************************
작성자	:	표수현
작성일	:	2020-02-15
DESCRIPTION	:	ADMIN - 진열관리 - 메인/카테고리 진열에 매칭되지 않는 상품 검색
				* 상품추가 화면리스트에 뿌려질 용도.

				 우선 실제 기획 니즈에 100% 부합하는지는 추후 쿼리 내용 검증이 필요
SPECIAL LOGIC	: SP_S_ADMIN_PRODUCT_DISPLAY_NO 'CTC01'
******************************************************************
MODIFICATION
******************************************************************
수정일           작업자                DESCRIPTION
==================================================================
******************************************************************/
 @CATEGORY_TYPE_CODE	VARCHAR(50) = 'CTC01',		-- CTC01 - 메인 진열 / CTC02 - 카테고리 진열
 @PRODUCT_CATEGORY_CODE VARCHAR(50) = NULL, -- 청첩장, 감사장 등등..
 @PRODUCT_BRAND_CODE	VARCHAR(50) = NULL, -- 바른손, 더카드 등등..
 @SEARCHTXT				VARCHAR(100) = NULL -- 검색어 

AS

 SET NOCOUNT ON
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

 DECLARE @NOWDISPLAYEDID TABLE(
	PRODUCT_ID  INT
 )

  /* 메인 OR 카테고리로 진열설정된 상품ID 추출 */
 INSERT INTO @NOWDISPLAYEDID
 SELECT PRODUCT_ID 
 FROM TB_CATEGORY A INNER JOIN 
  	  TB_PRODUCT_CATEGORY B 
 ON A.CATEGORY_ID = B.CATEGORY_ID 
 WHERE A.CATEGORY_TYPE_CODE = 'CTC01' AND
		A.DISPLAY_YN = 'Y'

 DECLARE @CONDITION1 INT = 0
 DECLARE @CONDITION2 INT = 0

 IF @PRODUCT_CATEGORY_CODE IS NOT NULL BEGIN  -- 청첩장, 감사장 등등..
	SET @CONDITION1 = 1
 END

 IF @PRODUCT_BRAND_CODE IS NOT NULL BEGIN  -- 바른손, 더카드 등등..
	SET @CONDITION2 = 1
 END


 /* 메인진열설정되지 않은 전체 상품정보 조회(곧, 카테고리 진열로 설정된 상품까지 포함)*/

 IF @CATEGORY_TYPE_CODE = 'CTC01' BEGIN  -- 메인진열 

	IF @SEARCHTXT IS NOT NULL BEGIN 
	
		SELECT A.PRODUCT_ID,
			   A.PRODUCT_CODE,
			   A.PRODUCT_CATEGORY_CODE,
			   A.PRODUCT_BRAND_CODE,
			   A.PRODUCT_NAME,
			   A.MAIN_IMAGE_URL,
			   A.PRICE,
			   B.REGIST_DATETIME
		FROM TB_PRODUCT A INNER JOIN 
			 TB_TEMPLATE B ON A.TEMPLATE_ID = B.TEMPLATE_ID --LEFT OUTER JOIN 
			-- @NOWDISPLAYEDID C ON A.PRODUCT_ID = C.PRODUCT_ID
		WHERE --C.PRODUCT_ID IS NULL AND
			  A.PRODUCT_CATEGORY_CODE = (CASE WHEN @CONDITION1 = 1 THEN @PRODUCT_CATEGORY_CODE ELSE A.PRODUCT_CATEGORY_CODE END) AND
			  A.PRODUCT_BRAND_CODE = (CASE WHEN @CONDITION2 = 1 THEN @PRODUCT_BRAND_CODE ELSE A.PRODUCT_BRAND_CODE END) AND 
			  (A.PRODUCT_NAME LIKE  '%' + @SEARCHTXT + '%' OR A.PRODUCT_CODE LIKE '%' + @SEARCHTXT + '%')

	END ELSE BEGIN 

		SELECT A.PRODUCT_ID,
			   A.PRODUCT_CODE,
			   A.PRODUCT_CATEGORY_CODE,
			   A.PRODUCT_BRAND_CODE,
			   A.PRODUCT_NAME,
			   A.MAIN_IMAGE_URL,
			   A.PRICE,
			   B.REGIST_DATETIME
		FROM TB_PRODUCT A INNER JOIN 
			 TB_TEMPLATE B ON A.TEMPLATE_ID = B.TEMPLATE_ID-- LEFT OUTER JOIN 
			 --@NOWDISPLAYEDID C ON A.PRODUCT_ID = C.PRODUCT_ID
		WHERE --C.PRODUCT_ID IS NULL AND
			  A.PRODUCT_CATEGORY_CODE = (CASE WHEN @CONDITION1 = 1 THEN @PRODUCT_CATEGORY_CODE ELSE A.PRODUCT_CATEGORY_CODE END) AND
			  A.PRODUCT_BRAND_CODE = (CASE WHEN @CONDITION2 = 1 THEN @PRODUCT_BRAND_CODE ELSE A.PRODUCT_BRAND_CODE END)

	END 
	
 END ELSE BEGIN   -- 카테고리 진열 

  /* 카테고리 진열설정되지 않은 전체 상품정보 조회(곧, 메인 진열로 설정된 상품까지 포함)*/

	IF @SEARCHTXT IS NOT NULL BEGIN 
	
		SELECT A.PRODUCT_ID,
			   A.PRODUCT_CODE,
			   A.PRODUCT_CATEGORY_CODE,
			   A.PRODUCT_BRAND_CODE,
			   A.PRODUCT_NAME,
			   A.MAIN_IMAGE_URL,
			   A.PRICE,
			   B.REGIST_DATETIME
		FROM TB_PRODUCT A INNER JOIN 
			 TB_TEMPLATE B ON A.TEMPLATE_ID = B.TEMPLATE_ID --LEFT OUTER JOIN 
			 --@NOWDISPLAYEDID C ON A.PRODUCT_ID = C.PRODUCT_ID
		WHERE --C.PRODUCT_ID IS NULL AND
			  A.PRODUCT_CATEGORY_CODE = (CASE WHEN @CONDITION1 = 1 THEN @PRODUCT_CATEGORY_CODE ELSE A.PRODUCT_CATEGORY_CODE END) AND
			  A.PRODUCT_BRAND_CODE = (CASE WHEN @CONDITION2 = 1 THEN @PRODUCT_BRAND_CODE ELSE A.PRODUCT_BRAND_CODE END) AND 
			  (A.PRODUCT_NAME LIKE  '%' + @SEARCHTXT + '%' OR A.PRODUCT_CODE LIKE '%' + @SEARCHTXT + '%')

		--SELECT A.PRODUCT_ID,
		--	   A.PRODUCT_CODE,
		--	   A.PRODUCT_CATEGORY_CODE,
		--	   A.PRODUCT_BRAND_CODE,
		--	   A.PRODUCT_NAME,
		--	   A.MAIN_IMAGE_URL,
		--	   A.PRICE,
		--	   B.REGIST_DATETIME
		--FROM TB_PRODUCT A INNER JOIN 
		--	 TB_TEMPLATE B ON A.TEMPLATE_ID = B.TEMPLATE_ID LEFT OUTER JOIN 
		--	 @NOWDISPLAYEDID C ON A.PRODUCT_ID = C.PRODUCT_ID
		--WHERE C.PRODUCT_ID IS NULL AND
		--	  A.PRODUCT_CATEGORY_CODE = (CASE WHEN @CONDITION1 = 1 THEN @PRODUCT_CATEGORY_CODE ELSE A.PRODUCT_CATEGORY_CODE END) AND
		--	  A.PRODUCT_BRAND_CODE = (CASE WHEN @CONDITION2 = 1 THEN @PRODUCT_BRAND_CODE ELSE A.PRODUCT_BRAND_CODE END) AND 
		--	  (A.PRODUCT_NAME LIKE  '%' + @SEARCHTXT + '%' OR A.PRODUCT_CODE LIKE '%' + @SEARCHTXT + '%')

	END ELSE BEGIN 

		SELECT A.PRODUCT_ID,
			   A.PRODUCT_CODE,
			   A.PRODUCT_CATEGORY_CODE,
			   A.PRODUCT_BRAND_CODE,
			   A.PRODUCT_NAME,
			   A.MAIN_IMAGE_URL,
			   A.PRICE,
			   B.REGIST_DATETIME
		FROM TB_PRODUCT A INNER JOIN 
			 TB_TEMPLATE B ON A.TEMPLATE_ID = B.TEMPLATE_ID --LEFT OUTER JOIN 
			 --@NOWDISPLAYEDID C ON A.PRODUCT_ID = C.PRODUCT_ID
		WHERE --C.PRODUCT_ID IS NULL AND
			  A.PRODUCT_CATEGORY_CODE = (CASE WHEN @CONDITION1 = 1 THEN @PRODUCT_CATEGORY_CODE ELSE A.PRODUCT_CATEGORY_CODE END) AND
			  A.PRODUCT_BRAND_CODE = (CASE WHEN @CONDITION2 = 1 THEN @PRODUCT_BRAND_CODE ELSE A.PRODUCT_BRAND_CODE END)

		--SELECT A.PRODUCT_ID,
		--	   A.PRODUCT_CODE,
		--	   A.PRODUCT_CATEGORY_CODE,
		--	   A.PRODUCT_BRAND_CODE,
		--	   A.PRODUCT_NAME,
		--	   A.MAIN_IMAGE_URL,
		--	   A.PRICE,
		--	   B.REGIST_DATETIME
		--FROM TB_PRODUCT A INNER JOIN 
		--	 TB_TEMPLATE B ON A.TEMPLATE_ID = B.TEMPLATE_ID LEFT OUTER JOIN 
		--	 @NOWDISPLAYEDID C ON A.PRODUCT_ID = C.PRODUCT_ID
		--WHERE C.PRODUCT_ID IS NULL AND
		--	  A.PRODUCT_CATEGORY_CODE = (CASE WHEN @CONDITION1 = 1 THEN @PRODUCT_CATEGORY_CODE ELSE A.PRODUCT_CATEGORY_CODE END) AND
		--	  A.PRODUCT_BRAND_CODE = (CASE WHEN @CONDITION2 = 1 THEN @PRODUCT_BRAND_CODE ELSE A.PRODUCT_BRAND_CODE END)

	END 


   END 
GO
