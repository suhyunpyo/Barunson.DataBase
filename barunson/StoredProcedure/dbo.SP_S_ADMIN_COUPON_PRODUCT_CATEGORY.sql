IF OBJECT_ID (N'dbo.SP_S_ADMIN_COUPON_PRODUCT_CATEGORY', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_S_ADMIN_COUPON_PRODUCT_CATEGORY
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_S_ADMIN_COUPON_PRODUCT_CATEGORY]
/***************************************************************
작성자	:	표수현
작성일	:	2021-11-10
DESCRIPTION	:	
SPECIAL LOGIC	: 
SP_S_ADMIN_COUPON_PRODUCT_CATEGORY_TEST @PARENT_CATEGORY_ID = 1
SP_S_ADMIN_COUPON_PRODUCT_CATEGORY @SEARCHTXT = '혼례'
****************************************************************** 
MODIFICATION
******************************************************************
수정일           작업자                DESCRIPTION
==================================================================
******************************************************************/

 @CATEGORY_ID1	INT = NULL, --대분류 카테고리 
 @CATEGORY_ID2	INT = NULL,			--중분류 카테고리

 --@PARENT_CATEGORY_ID	INT = NULL, --대분류 카테고리 
 --@CATEGORY_ID	INT = NULL,			--중분류 카테고리 
 @SEARCHTXT VARCHAR(1000) = NULL	-- 검색어
AS

 SET NOCOUNT ON
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

 DECLARE @CATEGORY_TYPE_CODE VARCHAR(100) = 'CTC02'

 DECLARE @CATEGORY_CODE_CONDITION1 INT = 0
 DECLARE @BRAND_CODE_CONDITION INT = 0
 DECLARE @SEARCHVIEWYN_CONDITION INT = 0
 
 DECLARE @PARENT_CATEGORY_ID_CONDITION1 INT = 0
 DECLARE @CATEGORY_ID_CONDITION INT = 0

 
 IF @CATEGORY_ID1 IS NOT NULL AND @CATEGORY_ID1 <> '' AND @CATEGORY_ID1 > 0 BEGIN 
	SET @PARENT_CATEGORY_ID_CONDITION1 = 1
 END

  IF @CATEGORY_ID2 IS NOT NULL AND @CATEGORY_ID2 <> '' AND @CATEGORY_ID2 > 0 BEGIN 
	SET @CATEGORY_ID_CONDITION = 1
 END


 
 IF @SEARCHTXT IS NOT NULL AND @SEARCHTXT <> '' BEGIN 
 
 	SELECT	E.CATEGORY_ID, E.PARENT_CATEGORY_ID, 
			A.PRODUCT_ID, A.DISPLAY_YN, --A.MAIN_IMAGE_URL, 
			A.PRICE, 
			A.PRODUCT_BRAND_CODE, 
			A.PRODUCT_CATEGORY_CODE, 
			A.PRODUCT_CODE, --A.PRODUCT_DESCRIPTION, 
			A.PRODUCT_NAME, 
			--A.TEMPLATE_ID,  B.PRODUCT_ID, --B.DISPLAY_YN, 
			--B.REGIST_DATETIME, 
			B.SORT, 
			E.CATEGORY_ID, --E.CATEGORY_NAME_MOBILE, E.CATEGORY_NAME_MOBILE_URL, 
			--E.CATEGORY_NAME_PC, E.CATEGORY_NAME_PC_URL, E.CATEGORY_NAME_TYPE_CODE, 
			E.CATEGORY_STEP, E.CATEGORY_TYPE_CODE, 
			E.DISPLAY_YN,
			E.SORT, F.CODE_GROUP, F.CODE, F.CODE_NAME, F.SORT, G.CODE_GROUP, G.CODE, G.CODE_NAME, G.SORT-- C.TEMPLATE_ID, --C.DELETE_DATETIME, 
			--C.DELETE_IP, C.DELETE_USER_ID, 
			--C.PHOTO_YN, A.PREVIEW_IMAGE_URL, C.PREVIEW_URL, 
			--C.REGIST_IP, C.REGIST_USER_ID, C.TEMPLATE_NAME, C.UPDATE_DATETIME, C.UPDATE_IP, C.UPDATE_USER_ID
			
	FROM	TB_PRODUCT A INNER JOIN 
			TB_PRODUCT_CATEGORY B ON A.PRODUCT_ID = B.PRODUCT_ID INNER JOIN 
			TB_TEMPLATE C ON A.TEMPLATE_ID = C.TEMPLATE_ID 
					INNER JOIN (SELECT D.PARENT_CATEGORY_ID, D.CATEGORY_ID, D.CATEGORY_NAME, D.CATEGORY_NAME_MOBILE, 
								   D.CATEGORY_NAME_MOBILE_URL, D.CATEGORY_NAME_PC, D.CATEGORY_NAME_PC_URL, D.CATEGORY_NAME_TYPE_CODE, 
								   D.CATEGORY_STEP, D.CATEGORY_TYPE_CODE, D.DISPLAY_YN, D.SORT
								FROM TB_CATEGORY D
								WHERE D.CATEGORY_TYPE_CODE = @CATEGORY_TYPE_CODE AND
									  D.DISPLAY_YN = 'Y'
								) E ON B.CATEGORY_ID = E.CATEGORY_ID INNER JOIN 
			TB_COMMON_CODE F ON A.PRODUCT_CATEGORY_CODE = F.CODE INNER JOIN 
			TB_COMMON_CODE G ON A.PRODUCT_BRAND_CODE = G.CODE

	WHERE A.DISPLAY_YN = 'Y' 
		  AND ISNULL(E.PARENT_CATEGORY_ID, E.CATEGORY_ID) = (
															CASE WHEN @PARENT_CATEGORY_ID_CONDITION1 = 1 THEN @CATEGORY_ID1 
															ELSE ISNULL(E.PARENT_CATEGORY_ID, E.CATEGORY_ID) END
														) 
		  AND E.CATEGORY_ID =  (
								CASE WHEN @CATEGORY_ID_CONDITION = 1 THEN @CATEGORY_ID2 
								ELSE E.CATEGORY_ID END
							  ) 

		  AND (CHARINDEX(A.Product_Code, @SEARCHTXT) > 0) OR (A.PRODUCT_NAME LIKE  '%' + @SEARCHTXT + '%')
		    --OR (A.Product_Code LIKE  '%' + @SEARCHTXT + '%')
	ORDER BY E.SORT ASC, B.SORT ASC

 END ELSE BEGIN 
 
	SELECT  E.CATEGORY_ID, E.PARENT_CATEGORY_ID, 
			A.PRODUCT_ID, A.DISPLAY_YN, --A.MAIN_IMAGE_URL, 
			A.PRICE, 
			A.PRODUCT_BRAND_CODE, 
			A.PRODUCT_CATEGORY_CODE, 
			A.PRODUCT_CODE, --A.PRODUCT_DESCRIPTION, 
			A.PRODUCT_NAME, 
			--A.TEMPLATE_ID,  B.PRODUCT_ID, --B.DISPLAY_YN, 
			--B.REGIST_DATETIME, 
			B.SORT, 
			E.CATEGORY_ID, --E.CATEGORY_NAME_MOBILE, E.CATEGORY_NAME_MOBILE_URL, 
			--E.CATEGORY_NAME_PC, E.CATEGORY_NAME_PC_URL, E.CATEGORY_NAME_TYPE_CODE, 
			E.CATEGORY_STEP, E.CATEGORY_TYPE_CODE, 
			E.DISPLAY_YN,
			E.SORT, F.CODE_GROUP, F.CODE, F.CODE_NAME, F.SORT, G.CODE_GROUP, G.CODE, G.CODE_NAME, G.SORT-- C.TEMPLATE_ID, --C.DELETE_DATETIME, 
			--C.DELETE_IP, C.DELETE_USER_ID, 
			--C.PHOTO_YN, A.PREVIEW_IMAGE_URL, C.PREVIEW_URL, 
			--C.REGIST_IP, C.REGIST_USER_ID, C.TEMPLATE_NAME, C.UPDATE_DATETIME, C.UPDATE_IP, C.UPDATE_USER_ID
	FROM	TB_PRODUCT A INNER JOIN 
			TB_PRODUCT_CATEGORY B ON A.PRODUCT_ID = B.PRODUCT_ID INNER JOIN 
			TB_TEMPLATE C ON A.TEMPLATE_ID = C.TEMPLATE_ID 
					INNER JOIN (SELECT D.PARENT_CATEGORY_ID, D.CATEGORY_ID, D.CATEGORY_NAME, D.CATEGORY_NAME_MOBILE, 
								   D.CATEGORY_NAME_MOBILE_URL, D.CATEGORY_NAME_PC, D.CATEGORY_NAME_PC_URL, D.CATEGORY_NAME_TYPE_CODE, 
								   D.CATEGORY_STEP, D.CATEGORY_TYPE_CODE, D.DISPLAY_YN, D.SORT
								FROM TB_CATEGORY D
								WHERE D.CATEGORY_TYPE_CODE = @CATEGORY_TYPE_CODE AND
									  D.DISPLAY_YN = 'Y'
								) E ON B.CATEGORY_ID = E.CATEGORY_ID INNER JOIN 
			TB_COMMON_CODE F ON A.PRODUCT_CATEGORY_CODE = F.CODE INNER JOIN 
			TB_COMMON_CODE G ON A.PRODUCT_BRAND_CODE = G.CODE

	WHERE A.DISPLAY_YN = 'Y' 
	      AND ISNULL(E.PARENT_CATEGORY_ID, E.CATEGORY_ID) = (
																CASE WHEN @PARENT_CATEGORY_ID_CONDITION1 = 1 THEN @CATEGORY_ID1 
																ELSE ISNULL(E.PARENT_CATEGORY_ID, E.CATEGORY_ID) END
															) 
		 AND E.CATEGORY_ID =  (CASE WHEN @CATEGORY_ID_CONDITION = 1 THEN @CATEGORY_ID2 ELSE E.CATEGORY_ID END) 

		 ORDER BY E.SORT ASC, B.SORT ASC
 END 
GO
