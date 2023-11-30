IF OBJECT_ID (N'dbo.SP_S_ADMIN_PRODUCT_CATEGORY', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_S_ADMIN_PRODUCT_CATEGORY
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_S_ADMIN_PRODUCT_CATEGORY]
/***************************************************************
작성자	:	표수현
작성일	:	2020-02-15
DESCRIPTION	:	진열관리 -> 카테고리 진열 -> 상품리스트 (대분류명,소분류명을 같이 노출시켜야되는 이슈로 우선 프로시저로 구현 
SPECIAL LOGIC	: 
SP_S_ADMIN_PRODUCT_CATEGORY  @CATEGORY_TYPE_CODE = 'CTC01', @PRODUCT_CATEGORY_CODE = null, @PRODUCT_BRAND_CODE= null, @SEARCHTXT= null, @SEARCHVIEWYN= 'Y', @CATEGORY_ID= 0

SP_S_ADMIN_PRODUCT_CATEGORY @PRODUCT_CATEGORY_CODE = 'PCC02', @PRODUCT_BRAND_CODE= 'PBC02', @SEARCHTXT= '', @SEARCHVIEWYN= '', @CATEGORY_ID= 11

****************************************************************** 
MODIFICATION
******************************************************************
수정일           작업자                DESCRIPTION
==================================================================
******************************************************************/
 @CATEGORY_TYPE_CODE	VARCHAR(100) = 'CTC02',	--   CTC01 : 메인 / CTC02 : 카테고리 
 @PRODUCT_CATEGORY_CODE VARCHAR(50) = NULL,		-- 청첩장, 감사장 등등..
 @PRODUCT_BRAND_CODE	VARCHAR(50) = NULL,		-- 바른손, 더카드 등등..
 @SEARCHTXT				VARCHAR(100) = NULL,	-- 검색어
 @SEARCHVIEWYN			CHAR(3) = 'Y',			-- 노출여부 
 @CATEGORY_ID			INT = NULL,
 @USER_ID				VARCHAR(50) = NULL
AS

 SET NOCOUNT ON
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

 DECLARE @CATEGORY_CODE_CONDITION1 INT = 0
 DECLARE @BRAND_CODE_CONDITION INT = 0
 DECLARE @SEARCHVIEWYN_CONDITION INT = 0
 DECLARE @CATEGORY_ID_CONDITION INT = 0

 IF @PRODUCT_CATEGORY_CODE IS NOT NULL AND @PRODUCT_CATEGORY_CODE <> '' BEGIN  
	SET @CATEGORY_CODE_CONDITION1 = 1
 END

 IF @PRODUCT_BRAND_CODE IS NOT NULL AND @PRODUCT_BRAND_CODE <> '' BEGIN 
	SET @BRAND_CODE_CONDITION = 1
 END

 -- IF @SEARCHVIEWYN IS NOT NULL AND @SEARCHVIEWYN != 'ALL' AND @SEARCHVIEWYN <> '' BEGIN 
	--SET @SEARCHVIEWYN_CONDITION = 1
 --END


 IF @CATEGORY_ID IS NOT NULL AND @CATEGORY_ID <> '' AND @CATEGORY_ID > 0 BEGIN 
	SET @CATEGORY_ID_CONDITION = 1
 END

 IF @SEARCHTXT IS NOT NULL AND @SEARCHTXT <> '' BEGIN 
 
 	SELECT	CATEGORY_NAME1 = CASE WHEN(
									SELECT COUNT(*) FROM  TB_CATEGORY WHERE CATEGORY_ID =  E.PARENT_CATEGORY_ID) > 0 THEN 
									(SELECT CATEGORY_NAME FROM  TB_CATEGORY WHERE CATEGORY_ID =  E.PARENT_CATEGORY_ID)
							 ELSE E.CATEGORY_NAME END,
			CATEGORY_NAME2 = CASE WHEN(
									SELECT COUNT(*) FROM  TB_CATEGORY WHERE CATEGORY_ID =  E.PARENT_CATEGORY_ID) > 0 THEN 
									E.CATEGORY_NAME
						  ELSE '' END,
			E.CATEGORY_ID, E.PARENT_CATEGORY_ID, 
			A.PRODUCT_ID, A.DISPLAY_YN, A.MAIN_IMAGE_URL, A.PRICE, 
			A.PRODUCT_BRAND_CODE, A.PRODUCT_CATEGORY_CODE, A.PRODUCT_CODE, A.PRODUCT_DESCRIPTION, A.PRODUCT_NAME, 
			A.TEMPLATE_ID,  B.PRODUCT_ID, --B.DISPLAY_YN, 
			B.REGIST_DATETIME, B.SORT, E.CATEGORY_ID, E.CATEGORY_NAME_MOBILE, E.CATEGORY_NAME_MOBILE_URL, 
			E.CATEGORY_NAME_PC, E.CATEGORY_NAME_PC_URL, E.CATEGORY_NAME_TYPE_CODE, E.CATEGORY_STEP, E.CATEGORY_TYPE_CODE, E.DISPLAY_YN,
			E.SORT, F.CODE_GROUP, F.CODE, F.CODE_NAME, F.SORT, G.CODE_GROUP, G.CODE, G.CODE_NAME, G.SORT, C.TEMPLATE_ID, --C.DELETE_DATETIME, 
			--C.DELETE_IP, C.DELETE_USER_ID, 
			C.PHOTO_YN, A.PREVIEW_IMAGE_URL, C.PREVIEW_URL, 
			C.REGIST_IP, C.REGIST_USER_ID, C.TEMPLATE_NAME, C.UPDATE_DATETIME, C.UPDATE_IP, C.UPDATE_USER_ID,
			PAY_CNT = 0, /*(  
						SELECT COUNT(*)   
						FROM TB_ORDER Q INNER JOIN   
						TB_ORDER_PRODUCT V  ON  Q.ORDER_ID = V.ORDER_ID  
						WHERE Q.PAYMENT_STATUS_CODE = 'PSC02' AND  
						ISNULL(Q.PAYMENT_PRICE, 0) > 0 AND   
						V.PRODUCT_ID = A.PRODUCT_ID   
  
  
  
					),  */
			FREE_CNT = 0, /*(   
     
				SELECT COUNT(*)   
				FROM TB_ORDER Q INNER JOIN   
				TB_ORDER_PRODUCT V  ON  Q.ORDER_ID = V.ORDER_ID  
				WHERE Q.PAYMENT_STATUS_CODE = 'PSC02' AND  
				ISNULL(Q.PAYMENT_PRICE, 0) = 0 AND   
				V.PRODUCT_ID = A.PRODUCT_ID   
  
			) ,*/
			WISH_CNT = (
						CASE WHEN @USER_ID is null THEN 0 ELSE
						(
							SELECT COUNT(*)   
							FROM TB_WISH_LIST WHERE USER_ID = @USER_ID AND
							PRODUCT_ID = A.PRODUCT_ID
						)
						END
					
				
			)
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

	WHERE A.PRODUCT_CATEGORY_CODE = (CASE WHEN @CATEGORY_CODE_CONDITION1 = 1 THEN @PRODUCT_CATEGORY_CODE ELSE A.PRODUCT_CATEGORY_CODE END) AND
		  A.PRODUCT_BRAND_CODE = (CASE WHEN @BRAND_CODE_CONDITION = 1 THEN @PRODUCT_BRAND_CODE ELSE A.PRODUCT_BRAND_CODE END) AND
		  A.DISPLAY_YN = 'Y' AND
		  --B.DISPLAY_YN = (CASE WHEN @SEARCHVIEWYN_CONDITION = 1 THEN @SEARCHVIEWYN ELSE A.DISPLAY_YN END) AND
		  (
			E.CATEGORY_ID = (CASE WHEN @CATEGORY_ID_CONDITION = 1 THEN @CATEGORY_ID ELSE E.CATEGORY_ID END) OR
			ISNULL(E.PARENT_CATEGORY_ID, '') = (CASE WHEN @CATEGORY_ID_CONDITION = 1 THEN @CATEGORY_ID ELSE  ISNULL(E.PARENT_CATEGORY_ID, '') END) 
		  ) AND
		  (A.PRODUCT_NAME LIKE  '%' + @SEARCHTXT + '%' OR A.PRODUCT_CODE LIKE '%' + @SEARCHTXT + '%')
		   ORDER BY E.SORT ASC, B.SORT ASC

 END ELSE BEGIN 
 
	SELECT	CATEGORY_NAME1 = CASE WHEN(
									SELECT COUNT(*) FROM  TB_CATEGORY WHERE CATEGORY_ID =  E.PARENT_CATEGORY_ID) > 0 THEN 
									(SELECT CATEGORY_NAME FROM  TB_CATEGORY WHERE CATEGORY_ID =  E.PARENT_CATEGORY_ID)
							 ELSE E.CATEGORY_NAME END,
			CATEGORY_NAME2 = CASE WHEN(
									SELECT COUNT(*) FROM  TB_CATEGORY WHERE CATEGORY_ID =  E.PARENT_CATEGORY_ID) > 0 THEN 
									E.CATEGORY_NAME
							 ELSE '' END,
			E.CATEGORY_ID, E.PARENT_CATEGORY_ID, 
			A.PRODUCT_ID, A.DISPLAY_YN, A.MAIN_IMAGE_URL, A.PRICE, 
			A.PRODUCT_BRAND_CODE, A.PRODUCT_CATEGORY_CODE, A.PRODUCT_CODE, A.PRODUCT_DESCRIPTION, A.PRODUCT_NAME, 
			A.TEMPLATE_ID,  B.PRODUCT_ID, --B.DISPLAY_YN, 
			B.REGIST_DATETIME, B.SORT, E.CATEGORY_ID, E.CATEGORY_NAME_MOBILE, E.CATEGORY_NAME_MOBILE_URL, 
			E.CATEGORY_NAME_PC, E.CATEGORY_NAME_PC_URL, E.CATEGORY_NAME_TYPE_CODE, E.CATEGORY_STEP, E.CATEGORY_TYPE_CODE, E.DISPLAY_YN,
			E.SORT, F.CODE_GROUP, F.CODE, F.CODE_NAME, F.SORT, G.CODE_GROUP, G.CODE, G.CODE_NAME, G.SORT, C.TEMPLATE_ID, --C.DELETE_DATETIME, 
			--C.DELETE_IP, C.DELETE_USER_ID, 
			C.PHOTO_YN, A.PREVIEW_IMAGE_URL, C.PREVIEW_URL, 
			C.REGIST_IP, C.REGIST_USER_ID, C.TEMPLATE_NAME, C.UPDATE_DATETIME, C.UPDATE_IP, C.UPDATE_USER_ID,
			PAY_CNT = 0, /*(   
						SELECT COUNT(*)   
						FROM TB_ORDER Q INNER JOIN   
						TB_ORDER_PRODUCT V  ON  Q.ORDER_ID = V.ORDER_ID  
						WHERE Q.PAYMENT_STATUS_CODE = 'PSC02' AND  
						ISNULL(Q.PAYMENT_PRICE, 0) > 0 AND   
						V.PRODUCT_ID = A.PRODUCT_ID   
  
			),  */
			FREE_CNT = 0, /*(   
     
				SELECT COUNT(*)   
				FROM TB_ORDER Q INNER JOIN   
				TB_ORDER_PRODUCT V  ON  Q.ORDER_ID = V.ORDER_ID  
				WHERE Q.PAYMENT_STATUS_CODE = 'PSC02' AND  
				ISNULL(Q.PAYMENT_PRICE, 0) = 0 AND   
				V.PRODUCT_ID = A.PRODUCT_ID   
  
			) , */
			WISH_CNT = (
						CASE WHEN @USER_ID is null THEN 0 ELSE
						(
						SELECT COUNT(*)   
						FROM TB_WISH_LIST WHERE USER_ID = @USER_ID AND
						PRODUCT_ID = A.PRODUCT_ID
						)
						END
					
				
			)
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

	WHERE A.PRODUCT_CATEGORY_CODE = (CASE WHEN @CATEGORY_CODE_CONDITION1 = 1 THEN @PRODUCT_CATEGORY_CODE ELSE A.PRODUCT_CATEGORY_CODE END) AND
		  A.PRODUCT_BRAND_CODE = (CASE WHEN @BRAND_CODE_CONDITION = 1 THEN @PRODUCT_BRAND_CODE ELSE A.PRODUCT_BRAND_CODE END) AND
		  A.DISPLAY_YN = 'Y' AND
		  --B.DISPLAY_YN = (CASE WHEN @SEARCHVIEWYN_CONDITION = 1 THEN @SEARCHVIEWYN ELSE A.DISPLAY_YN END) AND
		  (
			E.CATEGORY_ID = (CASE WHEN @CATEGORY_ID_CONDITION = 1 THEN @CATEGORY_ID ELSE E.CATEGORY_ID END) OR
			ISNULL(E.PARENT_CATEGORY_ID, '') = (CASE WHEN @CATEGORY_ID_CONDITION = 1 THEN @CATEGORY_ID ELSE  ISNULL(E.PARENT_CATEGORY_ID, '') END) 
		  )
		  ORDER BY E.SORT ASC, B.SORT ASC
 END 
GO