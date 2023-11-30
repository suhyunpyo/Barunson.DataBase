IF OBJECT_ID (N'dbo.SP_S_ADMIN_ORDER_MEMBER_NEW_VER2_BACKUP', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_S_ADMIN_ORDER_MEMBER_NEW_VER2_BACKUP
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_S_ADMIN_ORDER_MEMBER_NEW_VER2_BACKUP]
/***************************************************************
작성자	:	표수현
작성일	:	2021-05-26
DESCRIPTION	:	ADMIN - 회원관리 - 주문한 회원목록 
SPECIAL LOGIC	: SP_S_ADMIN_ORDER_MEMBER_NEW_VER2 '2021-09-24', '2021-10-01' , 'ALL', 'jjiminjun'

******************************************************************
MODIFICATION
******************************************************************
수정일           작업자                DESCRIPTION
==================================================================
******************************************************************/
 @START_DATE VARCHAR(10) = NULL,
 @END_DATE VARCHAR(10) = NULL,
 @MEMBER_TYPE CHAR(3) = NULL, -- U - 회원 / G - 비회원
 @SEARCHTXT VARCHAR(100) = NULL -- 검색어 
AS

 SET NOCOUNT ON
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

 IF @MEMBER_TYPE = 'ALL' OR  @MEMBER_TYPE IS NULL BEGIN SET @MEMBER_TYPE = '' END

	--DROP TABLE #TEMP

	--DROP TABLE #TEMP_ORDER_TB

	SELECT * INTO #TEMP
	FROM 
	(
		SELECT	MAX(ORDER_ID) ORDER_ID,
				USER_NAME,
				USER_ID,
				CARD_CODE,
				JOIN_TYPE,
				MAX(WEDDING_DATE) WEDDING_DATE,
				MAX(REGIST_DATETIME) REGIST_DATETIME, -- 회원가입일
				MAX(PRODUCE_DATE) PRODUCE_DATE, -- 신규 모초 제작일(주문일이 아님) 
				'' MEMBER_TYPE
			FROM (
					SELECT	ORDER_ID = A.ORDER_ID,
							[USER_NAME] = ISNULL(B.NAME, A.NAME),
							[USER_ID] = ISNULL(B.USER_ID, A.EMAIL),
							CARD_CODE = B.CARD_CODE,
							JOIN_TYPE = B.REFERER_SALES_GUBUN, --  M은 모바일초대장 사이트에서, F는 청첩장 사이트에서 가입한 회원입니다.
							--WEDDING_DATE = MAX(B.WEDDING_DATE),
							WEDDING_DATE = D.WEDDINGDATE,
							REGIST_DATETIME = B.REGIST_DATETIME,
							PRODUCE_DATE = A.REGIST_DATETIME -- 신규 모초 제작일(주문일이 아님) 
					FROM (
							SELECT	USER_ID, 
									EMAIL,
									NAME
							FROM 	BARUNSON.DBO.VW_USER (NOLOCK)
							WHERE	REFERER_SALES_GUBUN = 'M'
							UNION 
							SELECT 
									USER_ID = '',
									EMAIL,
									NAME
							FROM	BARUNSON.DBO.TB_ORDER
							WHERE	USER_ID IS NULL OR 
									USER_ID = ''
							GROUP BY EMAIL, NAME
							UNION
							SELECT	U.USER_ID, 
									U.EMAIL,
									U.NAME
							FROM 	BARUNSON.DBO.TB_ORDER AS O
									LEFT JOIN BARUNSON.DBO.VW_USER(NOLOCK) AS U
									ON U.USER_ID = O.User_ID
							WHERE	U.REFERER_SALES_GUBUN <> 'M'
							GROUP BY U.USER_ID, U.EMAIL, U.NAME
						) AS BASE
						LEFT JOIN BARUNSON.DBO.TB_ORDER A ON BASE.EMAIL = A.Email OR BASE.USER_ID = A.User_ID
						LEFT JOIN BARUNSON.DBO.VW_USER B ON BASE.USER_ID = B.USER_ID 
						LEFT JOIN TB_INVITATION C ON A.ORDER_ID = C.ORDER_ID  
						LEFT JOIN TB_INVITATION_DETAIL D ON C.INVITATION_ID = D.INVITATION_ID
				) AS A
				GROUP BY USER_NAME, USER_ID, CARD_CODE, JOIN_TYPE

	) TEMP

	SELECT * 
	INTO #TEMP_ORDER_TB
	FROM (
			SELECT	ORDER_ID,
					CASE WHEN [USER_NAME] IS NULL OR [USER_NAME] = '' THEN '알수없음' ELSE [USER_NAME] END USER_NAME,
					CASE WHEN [USER_ID] IS NULL OR [USER_ID] = '' THEN '알수없음' ELSE [USER_ID] END USER_ID,
					CARD_CODE,
					JOIN_TYPE, 
					WEDDING_DATE, 
					REGIST_DATETIME,
					PRODUCE_DATE,
					MEMBER_TYPE,
					모초유료구매상품코드,
					모초무료구매상품코드
			FROM (
					-- 회원

					SELECT	회원_TB.ORDER_ID, 
							회원_TB.[USER_NAME], 
							회원_TB.[USER_ID], 
							회원_TB.CARD_CODE, 
							회원_TB.JOIN_TYPE, 
							회원_TB.WEDDING_DATE, 
							회원_TB.REGIST_DATETIME,
							회원_TB.PRODUCE_DATE, 
							회원_TB.MEMBER_TYPE,
							모초유료구매상품코드 = (
														SELECT TOP 1 '○'
														FROM  TB_ORDER A INNER JOIN 
																TB_ORDER_PRODUCT B ON A.ORDER_ID = B.ORDER_ID INNER JOIN 
																TB_PRODUCT C ON B.PRODUCT_ID = C.PRODUCT_ID
														WHERE PAYMENT_STATUS_CODE = 'PSC02' 
																AND ISNULL(PAYMENT_PRICE, 0) > 0
																AND A.USER_ID = 회원_TB.[USER_ID]
																
												   ),
							모초무료구매상품코드 = (
														SELECT TOP 1 '○'
														FROM TB_ORDER A INNER JOIN 
																TB_ORDER_PRODUCT B ON A.ORDER_ID = B.ORDER_ID INNER JOIN 
																TB_PRODUCT C ON B.PRODUCT_ID = C.PRODUCT_ID
														WHERE PAYMENT_STATUS_CODE = 'PSC02' 
																AND ISNULL(PAYMENT_PRICE, 0) = 0
																AND A.USER_ID = 회원_TB.[USER_ID]
																	
																
													)

							--모초유료구매상품코드 = STUFF(
							--								(
							--									SELECT ',' + C.PRODUCT_CODE 
							--									FROM  TB_ORDER A INNER JOIN 
							--										  TB_ORDER_PRODUCT B ON A.ORDER_ID = B.ORDER_ID INNER JOIN 
							--										  TB_PRODUCT C ON B.PRODUCT_ID = C.PRODUCT_ID
							--									WHERE PAYMENT_STATUS_CODE = 'PSC02' 
							--										  AND ISNULL(PAYMENT_PRICE, 0) > 0
							--										  AND A.USER_ID = 회원_TB.[USER_ID]
							--									FOR XML PATH('')
							--								 ) ,1 , 1, ''
							--							 ),
							--모초무료구매상품코드 = STUFF(
							--								(
							--									SELECT ',' + C.PRODUCT_CODE 
							--									FROM TB_ORDER A INNER JOIN 
							--											TB_ORDER_PRODUCT B ON A.ORDER_ID = B.ORDER_ID INNER JOIN 
							--											TB_PRODUCT C ON B.PRODUCT_ID = C.PRODUCT_ID
							--									WHERE PAYMENT_STATUS_CODE = 'PSC02' 
							--										  AND ISNULL(PAYMENT_PRICE, 0) = 0
							--										  AND A.USER_ID = 회원_TB.[USER_ID]
							--										FOR XML PATH('')
							--									), 1, 1, ''
							--							)

					FROM 
					(
						SELECT	ORDER_ID = MAX(ORDER_ID), 
								[USER_NAME], 
								[USER_ID], 
								CARD_CODE = MAX(CARD_CODE), 
								JOIN_TYPE,
								WEDDING_DATE, 
								REGIST_DATETIME = MAX(REGIST_DATETIME), 
								PRODUCE_DATE = MAX(PRODUCE_DATE), 
								MEMBER_TYPE = 'U'


						FROM	#TEMP
						GROUP BY USER_NAME, USER_ID, --CARD_CODE, 
									JOIN_TYPE, WEDDING_DATE,--REGIST_DATETIME,  REGIST_DATETIME , ORDER_DATE, 
									MEMBER_TYPE
					) 회원_TB

					UNION
		
					SELECT	비회원_TB.ORDER_ID, 비회원_TB.[USER_NAME], 비회원_TB.[USER_ID], 
							비회원_TB.CARD_CODE, 
							비회원_TB.JOIN_TYPE, 
							비회원_TB.WEDDING_DATE, 
							비회원_TB.REGIST_DATETIME,
							비회원_TB.PRODUCE_DATE, 
							비회원_TB.MEMBER_TYPE,
							모초유료구매상품코드 =  (
														SELECT TOP 1 '○'
														FROM TB_ORDER A INNER JOIN 
																TB_ORDER_PRODUCT B ON A.ORDER_ID = B.ORDER_ID INNER JOIN 
																TB_PRODUCT C ON B.PRODUCT_ID = C.PRODUCT_ID
														WHERE PAYMENT_STATUS_CODE = 'PSC02' 
																AND ISNULL(PAYMENT_PRICE, 0) > 0 
																AND A.NAME = 비회원_TB.[USER_NAME] 
																AND A.EMAIL = 비회원_TB.EMAIL 
															FOR XML PATH('')
													), 
															
							모초무료구매상품코드 =  (
														SELECT TOP 1 '○'
														FROM TB_ORDER A INNER JOIN 
																TB_ORDER_PRODUCT B ON A.ORDER_ID = B.ORDER_ID INNER JOIN 
																TB_PRODUCT C ON B.PRODUCT_ID = C.PRODUCT_ID
														WHERE PAYMENT_STATUS_CODE = 'PSC02' 
																AND ISNULL(PAYMENT_PRICE, 0) = 0 
																AND A.NAME = 비회원_TB.[USER_NAME] 
																AND A.EMAIL = 비회원_TB.EMAIL 
																
													)
														 

							--모초유료구매상품코드 = STUFF(
							--								(
							--									SELECT ',' + C.PRODUCT_CODE 
							--									FROM TB_ORDER A INNER JOIN 
							--											TB_ORDER_PRODUCT B ON A.ORDER_ID = B.ORDER_ID INNER JOIN 
							--											TB_PRODUCT C ON B.PRODUCT_ID = C.PRODUCT_ID
							--									WHERE PAYMENT_STATUS_CODE = 'PSC02' 
							--										  AND ISNULL(PAYMENT_PRICE, 0) > 0 
							--										  AND A.NAME = 비회원_TB.[USER_NAME] 
							--										  AND A.EMAIL = 비회원_TB.EMAIL 
							--										FOR XML PATH('')
							--									), 
							--								1, 1, ''
							--								),
							--모초무료구매상품코드 = STUFF(
							--								(
							--									SELECT ',' + C.PRODUCT_CODE 
							--									FROM TB_ORDER A INNER JOIN 
							--											TB_ORDER_PRODUCT B ON A.ORDER_ID = B.ORDER_ID INNER JOIN 
							--											TB_PRODUCT C ON B.PRODUCT_ID = C.PRODUCT_ID
							--									WHERE PAYMENT_STATUS_CODE = 'PSC02' 
							--										  AND ISNULL(PAYMENT_PRICE, 0) = 0 
							--										  AND A.NAME = 비회원_TB.[USER_NAME] 
							--										  AND A.EMAIL = 비회원_TB.EMAIL 
							--										FOR XML PATH('')
							--									), 1, 1, ''
							--							 )

					FROM 
					(
						-- 비회원
						SELECT  ORDER_ID = MAX(ORDER_ID),
								[USER_NAME] = NAME, 
								EMAIL =  MAX(EMAIL),
								[USER_ID] = NULL, CARD_CODE= NULL, JOIN_TYPE = NULL, WEDDING_DATE = NULL, REGIST_DATETIME = NULL,--MAX(REGIST_DATETIME),  
								PRODUCE_DATE = MAX(REGIST_DATETIME), 
								MEMBER_TYPE = 'G'

						FROM	TB_ORDER 
						WHERE	USER_ID = '' 
						GROUP BY NAME--, REGIST_DATETIME
					) 비회원_TB

				) TB
		) TEMP_ORDER_TB

	-- SELECT * FROM #TEMP_ORDER_TB where user_id = 'jjiminjun'


	IF @SEARCHTXT IS NOT NULL AND @SEARCHTXT <> '' BEGIN 
	
		SELECT	ORDER_ID,
				[USER_NAME],
				[USER_ID],
				CARD_CODE,
				JOIN_TYPE, 
				WEDDING_DATE, 
				REGIST_DATETIME,
				PRODUCE_DATE,
				MEMBER_TYPE,
				모초유료구매상품코드,
				모초무료구매상품코드
		FROM	#TEMP_ORDER_TB
		WHERE	([USER_NAME] LIKE  '%' + @SEARCHTXT + '%' OR  [USER_ID] LIKE  '%' + @SEARCHTXT + '%') 
				--AND REGIST_DATETIME BETWEEN @START_DATE + ' 00:00:00' AND  @END_DATE + ' 23:59:59' 
				AND PRODUCE_DATE BETWEEN @START_DATE + ' 00:00:00' AND  @END_DATE + ' 23:59:59' 
				AND (MEMBER_TYPE =  (CASE WHEN @MEMBER_TYPE <> '' THEN @MEMBER_TYPE ELSE MEMBER_TYPE END))
		ORDER BY REGIST_DATETIME DESC

	END ELSE BEGIN 

		SELECT	ORDER_ID,
				[USER_NAME],
				[USER_ID],
				CARD_CODE,
				JOIN_TYPE, 
				WEDDING_DATE, 
				REGIST_DATETIME,
				PRODUCE_DATE,
				MEMBER_TYPE,
				모초유료구매상품코드,
				모초무료구매상품코드
		FROM	#TEMP_ORDER_TB
		WHERE	PRODUCE_DATE BETWEEN @START_DATE + ' 00:00:00' AND  @END_DATE + ' 23:59:59' AND
				(MEMBER_TYPE =  (CASE WHEN @MEMBER_TYPE <> '' THEN @MEMBER_TYPE ELSE MEMBER_TYPE END))
		ORDER BY REGIST_DATETIME DESC


	
	END




 --IF @SEARCHTXT IS NOT NULL AND @SEARCHTXT <> '' BEGIN 
	

	--IF @START_DATE IS NOT NULL AND @END_DATE IS NOT NULL BEGIN
		
	--	SELECT	ORDER_ID,
	--			[USER_NAME],
	--			[USER_ID],
	--			CARD_CODE,
	--			JOIN_TYPE, 
	--			WEDDING_DATE, 
	--			REGIST_DATETIME,
	--			ORDER_DATE,
	--			MEMBER_TYPE--,
	--			--모초유료구매상품코드,
	--			--모초무료구매상품코드
	--	FROM	#TEMP_ORDER_TB
	--	WHERE	([USER_NAME] LIKE  '%' + @SEARCHTXT + '%' OR  [USER_ID] LIKE  '%' + @SEARCHTXT + '%') AND
	--		--REGIST_DATETIME BETWEEN @START_DATE + ' 00:00:00' AND  @END_DATE + ' 23:59:59' AND
	--			ORDER_DATE BETWEEN @START_DATE + ' 00:00:00' AND  @END_DATE + ' 23:59:59' AND
	--			(MEMBER_TYPE =  (CASE WHEN @MEMBER_TYPE <> '' THEN @MEMBER_TYPE ELSE MEMBER_TYPE END))
	--	ORDER BY REGIST_DATETIME DESC

	--END ELSE BEGIN
	
	--	SELECT ORDER_ID,
	--			[USER_NAME],
	--			[USER_ID],
	--			CARD_CODE,
	--			JOIN_TYPE, 
	--			WEDDING_DATE, 
	--			REGIST_DATETIME,
	--			ORDER_DATE,
	--			MEMBER_TYPE--,
	--			--모초유료구매상품코드,
	--			--모초무료구매상품코드
	--	FROM #TEMP_ORDER_TB
	--	WHERE ([USER_NAME] LIKE  '%' + @SEARCHTXT + '%' OR  [USER_ID] LIKE  '%' + @SEARCHTXT + '%') AND
	--		  (MEMBER_TYPE =  (CASE WHEN @MEMBER_TYPE <> '' THEN @MEMBER_TYPE ELSE MEMBER_TYPE END))
	--	ORDER BY REGIST_DATETIME DESC
	--END 
	
 --END ELSE BEGIN

	--IF @START_DATE IS NOT NULL AND @END_DATE IS NOT NULL BEGIN
	
	----select * from #TEMP_ORDER_TB --	WHERE	ORDER_DATE BETWEEN @START_DATE + ' 00:00:00' AND  @END_DATE + ' 23:59:59' 

	--	SELECT  ORDER_ID,
	--			[USER_NAME],
	--			[USER_ID],
	--			CARD_CODE,
	--			JOIN_TYPE, 
	--			WEDDING_DATE, 
	--			REGIST_DATETIME,
	--			ORDER_DATE,
	--			MEMBER_TYPE--,
	--			--모초유료구매상품코드,
	--			--모초무료구매상품코드
	--	FROM	#TEMP_ORDER_TB
	--	WHERE	REGIST_DATETIME BETWEEN @START_DATE + ' 00:00:00' AND  @END_DATE + ' 23:59:59' AND
	--	--WHERE	ORDER_DATE BETWEEN @START_DATE + ' 00:00:00' AND  @END_DATE + ' 23:59:59' AND
	--			(MEMBER_TYPE =  (CASE WHEN @MEMBER_TYPE <> '' THEN @MEMBER_TYPE ELSE MEMBER_TYPE END))
	--	ORDER BY REGIST_DATETIME DESC

	--END ELSE BEGIN 
	
	
	--	SELECT  ORDER_ID,
	--			[USER_NAME],
	--			[USER_ID],
	--			CARD_CODE,
	--			JOIN_TYPE, 
	--			WEDDING_DATE, 
	--			REGIST_DATETIME,
	--			ORDER_DATE,
	--			MEMBER_TYPE--,
	--			--모초유료구매상품코드,
	--			--모초무료구매상품코드
	--	FROM	#TEMP_ORDER_TB
	--	WHERE	MEMBER_TYPE =  (CASE WHEN @MEMBER_TYPE <> '' THEN @MEMBER_TYPE ELSE MEMBER_TYPE END)
	--	ORDER BY REGIST_DATETIME DESC
	--END 
	
 --END


GO
