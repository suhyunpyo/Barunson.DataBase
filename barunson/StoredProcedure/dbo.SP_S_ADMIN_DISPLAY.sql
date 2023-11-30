IF OBJECT_ID (N'dbo.SP_S_ADMIN_DISPLAY', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_S_ADMIN_DISPLAY
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_S_ADMIN_DISPLAY]
/***************************************************************
작성자	:	표수현
작성일	:	2020-02-15
DESCRIPTION	:	ADMIN - 진열관리 - 메인/카테고리 진열에 매칭되는 상품 검색 
SPECIAL LOGIC	: 
******************************************************************
MODIFICATION
******************************************************************
수정일           작업자                DESCRIPTION
==================================================================
******************************************************************/
 @GUBUN					INT = 1,		--  1 : 메인진열 / 2: 카테고리 진열
 @Product_Category_Code VARCHAR(50) = NULL, -- 청첩장, 감사장 등등..
 @Product_Brand_Code	VARCHAR(50) = NULL, -- 바른손, 더카드 등등..
 @CATEGORY_ID			INT = NULL,			-- 대분류카테고리번호 OR 중분류카테고리번호 
 @SEARCHTXT				VARCHAR(100) = NULL -- 검색어 

AS

 SET NOCOUNT ON
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

 IF @GUBUN = 1 BEGIN  -- 메인진열 
	
	SELECT *
	FROM TB_PRODUCT A INNER JOIN 
		 TB_PRODUCT_CATEGORY B ON A.PRODUCT_ID = B.PRODUCT_ID INNER JOIN
		 TB_CATEGORY C ON B.CATEGORY_ID = C.CATEGORY_ID INNER JOIN
		 TB_COMMON_CODE D ON A.PRODUCT_CATEGORY_CODE = D.CODE INNER JOIN
		 TB_COMMON_CODE E ON A.PRODUCT_BRAND_CODE = E.CODE
	WHERE C.CATEGORY_TYPE_CODE = 'CTC01' AND
		  A.PRODUCT_CATEGORY_CODE = @PRODUCT_CATEGORY_CODE AND
		  A.PRODUCT_BRAND_CODE = @PRODUCT_BRAND_CODE AND  
		  C.CATEGORY_ID = @CATEGORY_ID AND  
		 (A.PRODUCT_NAME LIKE  '%' + @SEARCHTXT + '%' OR A.PRODUCT_CODE LIKE '%' + @SEARCHTXT + '%')
	
 END ELSE IF  @GUBUN = 2 BEGIN   -- 중분류 

	SELECT * 
	FROM TB_PRODUCT A INNER JOIN
		 TB_PRODUCT_CATEGORY B ON A.PRODUCT_ID = B.PRODUCT_ID INNER JOIN
		 TB_CATEGORY C ON B.CATEGORY_ID = C.CATEGORY_ID INNER JOIN
		 TB_COMMON_CODE D ON A.PRODUCT_CATEGORY_CODE = D.CODE INNER JOIN
		 TB_COMMON_CODE E ON A.PRODUCT_BRAND_CODE = E.CODE
	WHERE C.CATEGORY_TYPE_CODE = 'CTC01' AND
		  A.PRODUCT_CATEGORY_CODE = @PRODUCT_CATEGORY_CODE AND
		  A.PRODUCT_BRAND_CODE = @PRODUCT_BRAND_CODE AND  
		  C.PARENT_CATEGORY_ID IS NULL  AND 
		  C.CATEGORY_ID = @CATEGORY_ID AND  
		  (A.PRODUCT_NAME LIKE  '%' + @SEARCHTXT + '%' OR A.PRODUCT_CODE LIKE '%' + @SEARCHTXT + '%')

 END 

GO
