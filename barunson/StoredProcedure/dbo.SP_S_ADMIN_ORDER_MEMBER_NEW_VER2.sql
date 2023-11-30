IF OBJECT_ID (N'dbo.SP_S_ADMIN_ORDER_MEMBER_NEW_VER2', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_S_ADMIN_ORDER_MEMBER_NEW_VER2
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_S_ADMIN_ORDER_MEMBER_NEW_VER2]
/***************************************************************
작성자	:	표수현
작성일	:	2021-05-26
DESCRIPTION	:	ADMIN - 회원관리 - 주문한 회원목록 
SPECIAL LOGIC	: SP_S_ADMIN_ORDER_MEMBER_NEW_VER2 '2021-10-21', '2021-10-28' , '', NULL

******************************************************************
MODIFICATION
******************************************************************
수정일           작업자                DESCRIPTION
==================================================================
******************************************************************/
 @START_DATE VARCHAR(10) = '2021-01-01',
 @END_DATE VARCHAR(10) = '2099-12-31',
 @MEMBER_TYPE CHAR(3) = 'ALL', -- U - 회원 / G - 비회원
 @SEARCHTXT VARCHAR(100) = '' -- 검색어 
AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
 
  	SELECT 
		MAX(ORDER_ID) ORDER_ID,
		CASE WHEN [USER_NAME] IS NULL OR [USER_NAME] = '' THEN '알수없음' ELSE [USER_NAME] END USER_NAME,
		CASE WHEN [USER_ID] IS NULL OR [USER_ID] = '' THEN '알수없음' ELSE [USER_ID] END USER_ID,
		CARD_CODE,
		CASE  
			WHEN JOIN_TYPE = 'SB' THEN '바'
			WHEN JOIN_TYPE = 'B' THEN '몰'
			WHEN JOIN_TYPE = 'SS' THEN '프'
			WHEN JOIN_TYPE = 'ST' THEN '더'
			WHEN JOIN_TYPE = 'SA' THEN '비'
			WHEN JOIN_TYPE = 'BM' THEN 'M'
			ELSE '비회원'
		END JOIN_TYPE,
		MAX(WEDDING_DATE) WEDDING_DATE,
		MAX(REGIST_DATETIME) REGIST_DATETIME,
		MAX(ORDER_DATE) ORDER_DATE,
		MEMBER_TYPE,
		NULL PRODUCE_DATE,
		
		회원모초유료구매상품코드 = (
									SELECT TOP 1 '○'
									FROM  TB_ORDER A INNER JOIN 
											TB_ORDER_PRODUCT B ON A.ORDER_ID = B.ORDER_ID INNER JOIN 
											TB_PRODUCT C ON B.PRODUCT_ID = C.PRODUCT_ID
									WHERE PAYMENT_STATUS_CODE = 'PSC02' 
											AND ISNULL(PAYMENT_PRICE, 0) > 0
											AND A.USER_ID = BASE.[USER_ID]
								   ),
		회원모초무료구매상품코드 = (
									SELECT TOP 1 '○'
									FROM TB_ORDER A INNER JOIN 
											TB_ORDER_PRODUCT B ON A.ORDER_ID = B.ORDER_ID INNER JOIN 
											TB_PRODUCT C ON B.PRODUCT_ID = C.PRODUCT_ID
									WHERE PAYMENT_STATUS_CODE = 'PSC02' 
											AND ISNULL(PAYMENT_PRICE, 0) = 0
											AND A.USER_ID = BASE.[USER_ID]
								   ),
		비회원모초유료구매상품코드 = (
										SELECT TOP 1 '○'
										FROM  TB_ORDER A INNER JOIN 
											  TB_ORDER_PRODUCT B ON A.ORDER_ID = B.ORDER_ID INNER JOIN 
											  TB_PRODUCT C ON B.PRODUCT_ID = C.PRODUCT_ID
										WHERE PAYMENT_STATUS_CODE = 'PSC02' 
											  AND ISNULL(PAYMENT_PRICE, 0) > 0
											  AND A.NAME = BASE.[USER_NAME] 
											  AND A.EMAIL = BASE.[USER_ID] 
											  AND A.USER_ID = ''
									),
		비회원모초무료구매상품코드 = (
										SELECT TOP 1 '○'
										FROM TB_ORDER A INNER JOIN 
												TB_ORDER_PRODUCT B ON A.ORDER_ID = B.ORDER_ID INNER JOIN 
												TB_PRODUCT C ON B.PRODUCT_ID = C.PRODUCT_ID
										WHERE PAYMENT_STATUS_CODE = 'PSC02' 
											  AND ISNULL(PAYMENT_PRICE, 0) = 0
											  AND A.NAME = BASE.[USER_NAME] 
											  AND A.EMAIL = BASE.[USER_ID] 
											  AND A.USER_ID = ''
									 )

	FROM (
			SELECT	ORDER_ID = A.ORDER_ID,
					[USER_NAME] = ISNULL(B.NAME, A.NAME),
					[USER_ID] = ISNULL(B.UID, A.EMAIL),
					JOIN_TYPE = B.REFERER_SALES_GUBUN, 
					WEDDING_DATE = D.WEDDINGDATE,
					REGIST_DATETIME = B.REG_DATE,
					ORDER_DATE =  A.REGIST_DATETIME,
					MEMBER_TYPE = 'U' 
			FROM (
					SELECT	UID USER_ID, 
							UMAIL EMAIL,
							UNAME NAME
					FROM 	BAR_SHOP1.DBO.S2_USERINFO_THECARD (NOLOCK)
					WHERE	REFERER_SALES_GUBUN = 'BM'
					UNION
					SELECT	U.UID USER_ID, 
							U.UMAIL EMAIL,
							U.UNAME NAME
					FROM 	BARUNSON.DBO.TB_ORDER AS O
						LEFT JOIN BAR_SHOP1.DBO.S2_USERINFO_THECARD(NOLOCK) AS U
							ON U.UID = O.USER_ID
					WHERE	U.REFERER_SALES_GUBUN <> 'BM'
					GROUP BY U.UID, U.UMAIL, U.UNAME
					
				) AS BASE
				LEFT JOIN BARUNSON.DBO.TB_ORDER A ON BASE.USER_ID = A.USER_ID
				LEFT JOIN BAR_SHOP1.DBO.S2_USERINFO_THECARD B ON BASE.USER_ID = B.UID 
				LEFT JOIN TB_INVITATION C ON A.ORDER_ID = C.ORDER_ID  
				LEFT JOIN TB_INVITATION_DETAIL D ON C.INVITATION_ID = D.INVITATION_ID

			WHERE	(BASE.NAME LIKE  '%' + @SEARCHTXT + '%' OR  BASE.USER_ID LIKE  '%' + @SEARCHTXT + '%') AND
					A.REGIST_DATETIME BETWEEN @START_DATE + ' 00:00:00' AND  @END_DATE + ' 23:59:59' 
					AND 'A' =  (CASE WHEN @MEMBER_TYPE = 'U' OR @MEMBER_TYPE = 'ALL' THEN 'A' ELSE 'B' END)

		UNION
		
		-- 비회원
		SELECT  ORDER_ID = MAX(ORDER_ID),
				[USER_NAME] = NAME, 
				USER_ID = EMAIL , 
				NULL, NULL, NULL, 
				MAX(ORDER_DATETIME) ORDER_DATETIME, 
				MEMBER_TYPE = 'G'
		FROM	TB_ORDER 
		WHERE	USER_ID = '' 
		    AND NAME LIKE  '%' + @SEARCHTXT + '%' 
			AND REGIST_DATETIME BETWEEN @START_DATE + ' 00:00:00' AND  @END_DATE + ' 23:59:59' 
			AND 'A' =  (CASE WHEN @MEMBER_TYPE = 'G' OR @MEMBER_TYPE = 'ALL' THEN 'A' ELSE 'B' END)
		GROUP BY NAME, EMAIL
	) AS BASE
		LEFT JOIN (
			SELECT
				O.MEMBER_ID,
				MAX(C.CARD_CODE) CARD_CODE
			FROM BAR_SHOP1.DBO.CUSTOM_ORDER AS O
				INNER JOIN BAR_SHOP1.DBO.S2_CARD AS C
					ON O.CARD_SEQ = C.CARD_SEQ
			WHERE O.STATUS_SEQ > 9
				AND O.MEMBER_ID <> ''
				AND O.MEMBER_ID IS NOT NULL
			GROUP BY O.MEMBER_ID
	) AS B
		ON BASE.USER_ID = B.MEMBER_ID
	WHERE USER_ID <> ''
	GROUP BY USER_NAME, USER_ID, JOIN_TYPE ,MEMBER_TYPE, CARD_CODE
	ORDER BY ORDER_ID DESC


GO