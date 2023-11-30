IF OBJECT_ID (N'dbo.SP_S_ADMIN_ORDER_MEMBER_NEW_VER2_TEST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_S_ADMIN_ORDER_MEMBER_NEW_VER2_TEST
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_S_ADMIN_ORDER_MEMBER_NEW_VER2_TEST]
/***************************************************************
작성자	:	표수현
작성일	:	2021-05-26
DESCRIPTION	:	ADMIN - 회원관리 - 주문한 회원목록 
SPECIAL LOGIC	: SP_S_ADMIN_ORDER_MEMBER_NEW '2021-04-07', '2021-08-24' , 'ALL', NULL
SP_S_ADMIN_ORDER_MEMBER '2021-05-19', '2021-05-26' , 'ALL',	'브'
******************************************************************
MODIFICATION
******************************************************************
수정일           작업자                DESCRIPTION
==================================================================
******************************************************************/
 @START_DATE VARCHAR(10) = '2021-10-01',
 @END_DATE VARCHAR(10) = '2021-10-10',
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
		case  
			when JOIN_TYPE = 'SB' then '바'
			when JOIN_TYPE = 'B' then '몰'
			when JOIN_TYPE = 'SS' then '프'
			when JOIN_TYPE = 'ST' then '더'
			when JOIN_TYPE = 'SA' then '비'
			when JOIN_TYPE = 'BM' then 'M'
			else '비회원'
		end JOIN_TYPE,
		MAX(WEDDING_DATE) WEDDING_DATE,
		MAX(REGIST_DATETIME) REGIST_DATETIME,
		MAX(ORDER_DATE) ORDER_DATE,
		MEMBER_TYPE,
		null PRODUCE_DATE,
		회원모초유료구매상품코드 = (
									SELECT TOP 1 '○'
									FROM  TB_ORDER A INNER JOIN 
											TB_ORDER_PRODUCT B ON A.ORDER_ID = B.ORDER_ID INNER JOIN 
											TB_PRODUCT C ON B.PRODUCT_ID = C.PRODUCT_ID
									WHERE PAYMENT_STATUS_CODE = 'PSC02' 
											AND ISNULL(PAYMENT_PRICE, 0) > 0
											AND A.USER_ID = Base.[USER_ID]
																
								),
		회원모초무료구매상품코드 = (
									SELECT TOP 1 '○'
									FROM TB_ORDER A INNER JOIN 
											TB_ORDER_PRODUCT B ON A.ORDER_ID = B.ORDER_ID INNER JOIN 
											TB_PRODUCT C ON B.PRODUCT_ID = C.PRODUCT_ID
									WHERE PAYMENT_STATUS_CODE = 'PSC02' 
											AND ISNULL(PAYMENT_PRICE, 0) = 0
											AND A.USER_ID = Base.[USER_ID]
																	
																
								),
		비회원모초유료구매상품코드 = (
									SELECT TOP 1 '○'
									FROM  TB_ORDER A INNER JOIN 
											TB_ORDER_PRODUCT B ON A.ORDER_ID = B.ORDER_ID INNER JOIN 
											TB_PRODUCT C ON B.PRODUCT_ID = C.PRODUCT_ID
									WHERE PAYMENT_STATUS_CODE = 'PSC02' 
											AND ISNULL(PAYMENT_PRICE, 0) > 0
													AND A.NAME = Base.[USER_NAME] 
																AND A.EMAIL = Base.[USER_ID] 
																
								),
		비회원모초무료구매상품코드 = (
									SELECT TOP 1 '○'
									FROM TB_ORDER A INNER JOIN 
											TB_ORDER_PRODUCT B ON A.ORDER_ID = B.ORDER_ID INNER JOIN 
											TB_PRODUCT C ON B.PRODUCT_ID = C.PRODUCT_ID
									WHERE PAYMENT_STATUS_CODE = 'PSC02' 
											AND ISNULL(PAYMENT_PRICE, 0) = 0
													AND A.NAME = Base.[USER_NAME] 
													AND A.EMAIL = Base.[USER_ID] 
																	
																
								)

	FROM (
			SELECT	ORDER_ID = A.ORDER_ID,
					[USER_NAME] = ISNULL(B.NAME, A.NAME),
					[USER_ID] = ISNULL(B.UID, A.EMAIL),
					JOIN_TYPE = B.REFERER_SALES_GUBUN, 
					WEDDING_DATE = D.WEDDINGDATE,
					REGIST_DATETIME = B.reg_date,
					ORDER_DATE =  A.REGIST_DATETIME,
					MEMBER_TYPE = 'U' 
			FROM (
					SELECT	UID USER_ID, 
							UMAIL EMAIL,
							UNAME NAME
					FROM 	bar_shop1.dbo.s2_userinfo_thecard (NOLOCK)
					WHERE	REFERER_SALES_GUBUN = 'BM'
					UNION
					SELECT	U.UID USER_ID, 
							U.UMAIL EMAIL,
							U.UNAME NAME
					FROM 	BARUNSON.DBO.TB_ORDER AS O
						LEFT JOIN bar_shop1.dbo.s2_userinfo_thecard(NOLOCK) AS U
							ON U.UID = O.User_ID
					WHERE	U.REFERER_SALES_GUBUN <> 'BM'
					GROUP BY U.UID, U.UMAIL, U.UNAME
					
				) AS Base
				LEFT JOIN BARUNSON.DBO.TB_ORDER A ON BASE.USER_ID = A.User_ID
				LEFT JOIN bar_shop1.dbo.s2_userinfo_thecard B ON BASE.USER_ID = B.UID 
				LEFT JOIN TB_INVITATION C ON A.ORDER_ID = C.ORDER_ID  
				LEFT JOIN TB_INVITATION_DETAIL D ON C.INVITATION_ID = D.INVITATION_ID

			WHERE	(BASE.NAME LIKE  '%' + @SEARCHTXT + '%' OR  BASE.USER_ID LIKE  '%' + @SEARCHTXT + '%') AND
					A.REGIST_DATETIME BETWEEN @START_DATE + ' 00:00:00' AND  @END_DATE + ' 23:59:59' 
					AND 'A' =  (case when @MEMBER_TYPE = 'U' OR @MEMBER_TYPE = 'ALL' THEN 'A' ELSE 'B' END)

		UNION
		
		-- 비회원
		SELECT  ORDER_ID = MAX(ORDER_ID),
				[USER_NAME] = NAME, 
				USER_ID = Email , 
				NULL, NULL, NULL, 
				MAX(ORDER_DATETIME) ORDER_DATETIME, 
				MEMBER_TYPE = 'G'
		FROM	TB_ORDER 
		WHERE	USER_ID = '' 
		    AND NAME LIKE  '%' + @SEARCHTXT + '%' 
			AND REGIST_DATETIME BETWEEN @START_DATE + ' 00:00:00' AND  @END_DATE + ' 23:59:59' 
			AND 'A' =  (case when @MEMBER_TYPE = 'G' OR @MEMBER_TYPE = 'ALL' THEN 'A' ELSE 'B' END)
		GROUP BY NAME, email
	) AS Base
		LEFT JOIN (
			SELECT
				o.member_id,
				max(c.Card_Code) card_code
			from bar_shop1.dbo.custom_order as O
				inner join bar_shop1.dbo.s2_card as C
					on o.card_seq = c.card_seq
			where o.status_seq > 9
				and o.member_id <> ''
				and o.member_id is not null
			group by o.member_id
	) AS B
		ON Base.USER_ID = B.member_id
	WHERE USER_ID <> ''
	GROUP BY USER_NAME, USER_ID, JOIN_TYPE ,MEMBER_TYPE, card_code
	ORDER BY ORDER_ID DESC

GO
