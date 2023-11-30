IF OBJECT_ID (N'dbo.SP_S_USER_PAY_STEP_STATUS', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_S_USER_PAY_STEP_STATUS
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_S_USER_PAY_STEP_STATUS]
/***************************************************************
작성자	:	표수현
작성일	:	2020-02-15
DESCRIPTION	:	마이페이지 - 제작중 / 제작완료 / 취소/환불카운트 
SPECIAL LOGIC	: SP_S_USER_PAY_STEP_STATUS 'M', 'VYRUDAKS80'
******************************************************************
MODIFICATION
******************************************************************
수정일           작업자                DESCRIPTION
==================================================================
******************************************************************/
 @GUBUN CHAR(1) = 'U',  -- U : 회원 / G : 비회원
 @USER_ID VARCHAR(50) = NULL,
 @USER_NAME VARCHAR(100) = NULL,
 @USER_EMAIL VARCHAR(100) = NULL
AS

 SET NOCOUNT ON
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

 IF @GUBUN = 'U' BEGIN
 
 	-- 마이페이지(회원) - 제작중  리스트
		SELECT 제작중 = COUNT(*)
		FROM 
		(
			SELECT	ORDER_ID = A.ORDER_ID,
					ORDER_CODE = A.ORDER_CODE, 
					PRODUCT_CATEGORY = F.CODE_NAME,
					PRODUCT_CODE = D.PRODUCT_CODE,
					PRODUCT_NAME = D.PRODUCT_NAME,
					REGIST_DATETIME = A.REGIST_DATETIME,
					ORDER_PRICE = A.ORDER_PRICE,
					PREVIEW_IMAGE_URL = D.PREVIEW_IMAGE_URL,
					MAIN_IMAGE_URL = D.MAIN_IMAGE_URL,
					PRODUCT_ID = C.PRODUCT_ID
			FROM	BARUNSON.DBO.TB_ORDER A INNER JOIN 
					BARUNSON.DBO.VW_USER B ON A.USER_ID = B.USER_ID INNER JOIN 
					BARUNSON.DBO.TB_ORDER_PRODUCT C ON A.ORDER_ID = C.ORDER_ID  INNER JOIN 
					BARUNSON.DBO.TB_PRODUCT D ON C.PRODUCT_ID = D.PRODUCT_ID  INNER JOIN 
					BARUNSON.DBO.TB_TEMPLATE E ON D.TEMPLATE_ID = E.TEMPLATE_ID  INNER JOIN 
					BARUNSON.DBO.TB_COMMON_CODE F ON D.PRODUCT_CATEGORY_CODE = F.CODE INNER JOIN 
					BARUNSON.DBO.TB_INVITATION G ON A.ORDER_ID = G.ORDER_ID 
			WHERE	A.USER_ID = @USER_ID  
					--AND A.NAME = @USER_NAME
					AND F.CODE_GROUP = 'PRODUCT_CATEGORY_CODE' 
					AND A.ORDER_STATUS_CODE = 'OSC01'   --주문완료
					AND A.PAYMENT_STATUS_CODE = 'PSC01' --결제대기
			GROUP BY A.ORDER_ID, A.ORDER_CODE, F.CODE_NAME, D.PRODUCT_CODE,
					 D.PRODUCT_NAME,  A.REGIST_DATETIME, A.ORDER_PRICE, D.PREVIEW_IMAGE_URL,
					 D.MAIN_IMAGE_URL, C.PRODUCT_ID
		) TB


		-- 마이페이지(회원) - 제작완료  리스트 
		SELECT 완료 = COUNT(*)
		FROM
		(
			SELECT	ORDER_ID = A.ORDER_ID,
					ORDER_CODE = A.ORDER_CODE, 
					PRODUCT_CATEGORY = F.CODE_NAME,
					PRODUCT_CODE = D.PRODUCT_CODE,
					PRODUCT_NAME = D.PRODUCT_NAME,
					REGIST_DATETIME = A.REGIST_DATETIME,
					ORDER_PRICE = A.PAYMENT_PRICE,
					PREVIEW_IMAGE_URL = D.PREVIEW_IMAGE_URL,
					MAIN_IMAGE_URL = D.MAIN_IMAGE_URL,
					PRODUCT_ID = C.PRODUCT_ID
			FROM	BARUNSON.DBO.TB_ORDER A INNER JOIN 
					BARUNSON.DBO.VW_USER B ON A.USER_ID = B.USER_ID  INNER JOIN 
					BARUNSON.DBO.TB_ORDER_PRODUCT C ON A.ORDER_ID = C.ORDER_ID  INNER JOIN 
					BARUNSON.DBO.TB_PRODUCT D ON C.PRODUCT_ID = D.PRODUCT_ID  INNER JOIN 
					BARUNSON.DBO.TB_TEMPLATE E ON D.TEMPLATE_ID = E.TEMPLATE_ID INNER JOIN 
					BARUNSON.DBO.TB_COMMON_CODE F ON D.PRODUCT_CATEGORY_CODE = F.CODE INNER JOIN 
					BARUNSON.DBO.TB_INVITATION G ON A.ORDER_ID = G.ORDER_ID  INNER JOIN 
					BARUNSON.DBO.TB_COMMON_CODE H ON A.PAYMENT_STATUS_CODE = H.CODE INNER JOIN   
					BARUNSON.DBO.TB_Invitation_Detail K ON G.Invitation_ID =  K.Invitation_ID INNER JOIN 
					BARUNSON.DBO.TB_COMMON_CODE P on A.Payment_Method_Code = P.Code
			WHERE	A.USER_ID = @USER_ID  --AND A.NAME = @USER_NAME
					AND A.ORDER_STATUS_CODE = 'OSC01'  --주문완료
					AND A.PAYMENT_STATUS_CODE IN ('PSC02' , 'PSC04') --결제완료 / 입금대기 
					AND P.CODE_GROUP = 'PAYMENT_METHOD_CODE'
			GROUP BY A.ORDER_ID, A.ORDER_CODE, F.CODE_NAME, D.PRODUCT_CODE,
					 D.PRODUCT_NAME,  A.REGIST_DATETIME, A.PAYMENT_PRICE, D.PREVIEW_IMAGE_URL,
					 D.MAIN_IMAGE_URL, C.PRODUCT_ID
		) TB

		
		-- 마이페이지(회원) - 취소/환불
		SELECT 취소환불 = COUNT(*)
		FROM
		(
			SELECT	ORDER_ID = A.ORDER_ID,
					ORDER_CODE = A.ORDER_CODE, 
					PRODUCT_CATEGORY = F.CODE_NAME,
					PRODUCT_CODE = D.PRODUCT_CODE,
					PRODUCT_NAME = D.PRODUCT_NAME,
					REGIST_DATETIME = A.ORDER_DATETIME,
					ORDER_PRICE = A.PAYMENT_PRICE,
					PREVIEW_IMAGE_URL = D.PREVIEW_IMAGE_URL,
					MAIN_IMAGE_URL = D.MAIN_IMAGE_URL,
					PRODUCT_ID = C.PRODUCT_ID,
					REFUND_REGIST_DATETIME = G.REGIST_DATETIME,
					PAY_CODE = H.CODE
			FROM	BARUNSON.DBO.TB_ORDER A INNER JOIN 
					BARUNSON.DBO.VW_USER B ON A.USER_ID = B.USER_ID  INNER JOIN 
					BARUNSON.DBO.TB_ORDER_PRODUCT C ON A.ORDER_ID = C.ORDER_ID  INNER JOIN 
					BARUNSON.DBO.TB_PRODUCT D ON C.PRODUCT_ID = D.PRODUCT_ID  INNER JOIN 
					BARUNSON.DBO.TB_TEMPLATE E ON D.TEMPLATE_ID = E.TEMPLATE_ID INNER JOIN 
					BARUNSON.DBO.TB_COMMON_CODE F ON D.PRODUCT_CATEGORY_CODE = F.CODE  INNER JOIN 
					BARUNSON.DBO.TB_REFUND_INFO G ON A.ORDER_ID = G.ORDER_ID  INNER JOIN 
					BARUNSON.DBO.TB_COMMON_CODE H ON G.REFUND_TYPE_CODE = H.CODE INNER JOIN 
					BARUNSON.DBO.TB_INVITATION I ON A.ORDER_ID = I.ORDER_ID INNER JOIN 
					BARUNSON.DBO.TB_COMMON_CODE J ON A.PAYMENT_STATUS_CODE = J.CODE INNER JOIN   
					BARUNSON.DBO.TB_INVITATION_DETAIL K ON I.INVITATION_ID =  K.INVITATION_ID INNER JOIN 
					BARUNSON.DBO.TB_COMMON_CODE P ON A.PAYMENT_METHOD_CODE = P.CODE
			WHERE	A.USER_ID = @USER_ID  --AND A.NAME = @USER_NAME
					AND (
						G.REFUND_STATUS_CODE = 'RSC01' OR  --환불신청
						G.REFUND_STATUS_CODE ='RSC02' OR  --환불완료
						G.REFUND_STATUS_CODE = 'RSC04' OR --취소완료
						G.REFUND_STATUS_CODE = 'RSC05' --입금대기취소완료
					) 
					AND P.CODE_GROUP = 'PAYMENT_METHOD_CODE'
			GROUP BY A.ORDER_ID, A.ORDER_CODE, F.CODE_NAME, D.PRODUCT_CODE,
					 D.PRODUCT_NAME,  A.ORDER_DATETIME, A.PAYMENT_PRICE,
					 D.PREVIEW_IMAGE_URL, D.MAIN_IMAGE_URL,  C.PRODUCT_ID,
					 G.REGIST_DATETIME,  H.CODE
		) TB
				 

	--SELECT	COUNT(CASE  WHEN PAYMENT_STATUS_CODE = 'PSC01' AND ORDER_STATUS_CODE = 'OSC01' /*OR PAYMENT_STATUS_CODE = 'PSC05'*/ THEN 1 END) AS 제작중,
	--		COUNT(CASE  WHEN PAYMENT_STATUS_CODE = 'PSC02' OR PAYMENT_STATUS_CODE = 'PSC04' /*OR PAYMENT_STATUS_CODE = 'PSC04'*/ THEN 1 END) AS 완료
	--FROM	BARUNSON.DBO.TB_ORDER A INNER JOIN 
	--		BARUNSON.DBO.VW_USER B ON A.USER_ID = B.USER_ID INNER JOIN 
	--		BARUNSON.DBO.TB_ORDER_PRODUCT C ON A.ORDER_ID = C.ORDER_ID  INNER JOIN 
	--		BARUNSON.DBO.TB_PRODUCT D ON C.PRODUCT_ID = D.PRODUCT_ID  INNER JOIN 
	--		BARUNSON.DBO.TB_TEMPLATE E ON D.TEMPLATE_ID = E.TEMPLATE_ID  INNER JOIN 
	--		BARUNSON.DBO.TB_COMMON_CODE F ON D.PRODUCT_CATEGORY_CODE = F.CODE 
	--WHERE	A.USER_ID = @USER_ID

	--SELECT	COUNT(CASE  WHEN G.REFUND_STATUS_CODE = 'RSC01' OR G.REFUND_STATUS_CODE ='RSC02' OR G.REFUND_STATUS_CODE = 'RSC04' THEN 1 END) AS 취소환불
	--FROM	BARUNSON.DBO.TB_ORDER A INNER JOIN 
	--		BARUNSON.DBO.VW_USER B ON A.USER_ID = B.USER_ID INNER JOIN 
	--		BARUNSON.DBO.TB_ORDER_PRODUCT C ON A.ORDER_ID = C.ORDER_ID  INNER JOIN 
	--		BARUNSON.DBO.TB_PRODUCT D ON C.PRODUCT_ID = D.PRODUCT_ID  INNER JOIN 
	--		BARUNSON.DBO.TB_TEMPLATE E ON D.TEMPLATE_ID = E.TEMPLATE_ID  INNER JOIN 
	--		BARUNSON.DBO.TB_COMMON_CODE F ON D.PRODUCT_CATEGORY_CODE = F.CODE  INNER JOIN 
	--		BARUNSON.DBO.TB_REFUND_INFO G ON A.ORDER_ID = G.ORDER_ID
	--WHERE	A.USER_ID = @USER_ID

	
 END ELSE BEGIN

 SELECT 제작중 = COUNT(*)
		FROM 
		(
		-- 마이페이지(비회원) - 제작중  리스트
		SELECT	ORDER_ID = A.ORDER_ID,
				ORDER_CODE = A.ORDER_CODE, 
				PRODUCT_CATEGORY = F.CODE_NAME,
				PRODUCT_CODE = D.PRODUCT_CODE,
				PRODUCT_NAME = D.PRODUCT_NAME,
				REGIST_DATETIME = A.REGIST_DATETIME,
				ORDER_PRICE = A.ORDER_PRICE,
				PREVIEW_IMAGE_URL = D.PREVIEW_IMAGE_URL,
				MAIN_IMAGE_URL = D.MAIN_IMAGE_URL,
				PRODUCT_ID = C.PRODUCT_ID
		FROM	BARUNSON.DBO.TB_ORDER A  INNER JOIN 
				BARUNSON.DBO.TB_ORDER_PRODUCT C ON A.ORDER_ID = C.ORDER_ID  INNER JOIN 
				BARUNSON.DBO.TB_PRODUCT D ON C.PRODUCT_ID = D.PRODUCT_ID  INNER JOIN 
				BARUNSON.DBO.TB_TEMPLATE E ON D.TEMPLATE_ID = E.TEMPLATE_ID INNER JOIN 
				BARUNSON.DBO.TB_COMMON_CODE F ON D.PRODUCT_CATEGORY_CODE = F.CODE INNER JOIN 
				BARUNSON.DBO.TB_INVITATION G ON A.ORDER_ID = G.ORDER_ID
		WHERE	NAME = @USER_NAME 
				AND F.CODE_GROUP = 'PRODUCT_CATEGORY_CODE' 
				AND EMAIL = @USER_EMAIL 
				AND ORDER_STATUS_CODE = 'OSC01' --주문완료	
				AND PAYMENT_STATUS_CODE = 'PSC01' --결제대기
				AND (A.USER_ID = '' OR A.USER_ID IS NULL)
		GROUP BY A.ORDER_ID, A.ORDER_CODE, F.CODE_NAME, D.PRODUCT_CODE,
				 D.PRODUCT_NAME,  A.REGIST_DATETIME, A.ORDER_PRICE, D.PREVIEW_IMAGE_URL,
				 D.MAIN_IMAGE_URL, C.PRODUCT_ID
		) TB

		-- 마이페이지(비회원) - 제작완료  리스트 
		SELECT 완료 = COUNT(*)
		FROM
		(
			SELECT	ORDER_ID = A.ORDER_ID,
					ORDER_CODE = A.ORDER_CODE, 
					PRODUCT_CATEGORY = F.CODE_NAME,
					PRODUCT_CODE = D.PRODUCT_CODE,
					PRODUCT_NAME = D.PRODUCT_NAME,
					REGIST_DATETIME = A.REGIST_DATETIME,
					PREVIEW_IMAGE_URL = D.PREVIEW_IMAGE_URL,
					MAIN_IMAGE_URL = D.MAIN_IMAGE_URL,
					PRODUCT_ID = C.PRODUCT_ID
			FROM	BARUNSON.DBO.TB_ORDER  A INNER JOIN 
					BARUNSON.DBO.TB_ORDER_PRODUCT C ON A.ORDER_ID = C.ORDER_ID  INNER JOIN 
					BARUNSON.DBO.TB_PRODUCT D ON C.PRODUCT_ID = D.PRODUCT_ID  INNER JOIN 
					BARUNSON.DBO.TB_TEMPLATE E ON D.TEMPLATE_ID = E.TEMPLATE_ID INNER JOIN 
					BARUNSON.DBO.TB_COMMON_CODE F ON D.PRODUCT_CATEGORY_CODE = F.CODE INNER JOIN 
					BARUNSON.DBO.TB_INVITATION G ON A.ORDER_ID = G.ORDER_ID  INNER JOIN 
					BARUNSON.DBO.TB_COMMON_CODE J ON A.PAYMENT_STATUS_CODE = J.CODE INNER JOIN   
					BARUNSON.DBO.TB_INVITATION_DETAIL K ON G.INVITATION_ID =  K.INVITATION_ID INNER JOIN 
					BARUNSON.DBO.TB_COMMON_CODE P ON A.PAYMENT_METHOD_CODE = P.CODE
			WHERE	NAME = @USER_NAME 
					AND EMAIL = @USER_EMAIL 
					AND ORDER_STATUS_CODE = 'OSC01' --주문완료
					AND PAYMENT_STATUS_CODE IN ('PSC02' , 'PSC04') --결제완료 / 입금대기 
					AND P.CODE_GROUP = 'PAYMENT_METHOD_CODE'
					AND (A.USER_ID = '' OR A.USER_ID IS NULL)
			GROUP BY A.ORDER_ID, A.ORDER_CODE, F.CODE_NAME, D.PRODUCT_CODE,
					 D.PRODUCT_NAME,  A.REGIST_DATETIME, A.ORDER_PRICE, D.PREVIEW_IMAGE_URL,
					 D.MAIN_IMAGE_URL, C.PRODUCT_ID
		) TB


		SELECT 취소환불 = COUNT(*)
		FROM
		(
			-- 마이페이지(비회원) - 취소/환불

	  		SELECT	ORDER_ID = A.ORDER_ID,
					ORDER_CODE = A.ORDER_CODE, 
					PRODUCT_CATEGORY = F.CODE_NAME,
					PRODUCT_CODE = D.PRODUCT_CODE,
					PRODUCT_NAME = D.PRODUCT_NAME,
					REGIST_DATETIME = A.REGIST_DATETIME,
					ORDER_PRICE = A.PAYMENT_PRICE,
					IMAGE_URL = D.PREVIEW_IMAGE_URL, --E.PREVIEW_IMAGE_URL 
					REFUND_REGIST_DATETIME = G.REGIST_DATETIME
			FROM	BARUNSON.DBO.TB_ORDER  A  INNER JOIN 
					BARUNSON.DBO.TB_ORDER_PRODUCT C ON A.ORDER_ID = C.ORDER_ID  INNER JOIN 
					BARUNSON.DBO.TB_PRODUCT D ON C.PRODUCT_ID = D.PRODUCT_ID  INNER JOIN 
					BARUNSON.DBO.TB_TEMPLATE E ON D.TEMPLATE_ID = E.TEMPLATE_ID INNER JOIN 
					BARUNSON.DBO.TB_COMMON_CODE F ON D.PRODUCT_CATEGORY_CODE = F.CODE INNER JOIN 
					BARUNSON.DBO.TB_REFUND_INFO G ON A.ORDER_ID = G.ORDER_ID  INNER JOIN 
					BARUNSON.DBO.TB_INVITATION I ON A.ORDER_ID = I.ORDER_ID  INNER JOIN 
					BARUNSON.DBO.TB_COMMON_CODE J ON A.PAYMENT_STATUS_CODE = J.CODE INNER JOIN   
					BARUNSON.DBO.TB_INVITATION_DETAIL K ON I.INVITATION_ID =  K.INVITATION_ID INNER JOIN 
					BARUNSON.DBO.TB_COMMON_CODE P ON A.PAYMENT_METHOD_CODE = P.CODE
			WHERE	NAME = @USER_NAME 
					AND EMAIL = @USER_EMAIL 
					AND (
							G.REFUND_STATUS_CODE = 'RSC01' OR  --환불신청
							G.REFUND_STATUS_CODE ='RSC02' OR  --환불완료
							G.REFUND_STATUS_CODE = 'RSC04' OR --취소완료
							G.REFUND_STATUS_CODE = 'RSC05' --입금대기취소완료
						) 
					AND P.Code_Group = 'Payment_Method_Code'
					AND (A.USER_ID = '' OR A.USER_ID IS NULL)
			GROUP BY A.ORDER_ID, A.ORDER_CODE, F.CODE_NAME, D.PRODUCT_CODE,
					 D.PRODUCT_NAME,  A.ORDER_DATETIME, A.PAYMENT_PRICE,
					 D.PREVIEW_IMAGE_URL, D.MAIN_IMAGE_URL,  C.PRODUCT_ID,
					 A.REGIST_DATETIME, G.REGIST_DATETIME
		) TB

 --	SELECT COUNT(CASE  WHEN PAYMENT_STATUS_CODE = 'PSC01' AND ORDER_STATUS_CODE = 'OSC01' /*OR PAYMENT_STATUS_CODE = 'PSC05'*/ THEN 1 END) AS 제작중,
	--COUNT(CASE  WHEN PAYMENT_STATUS_CODE = 'PSC02' OR PAYMENT_STATUS_CODE = 'PSC04'/* OR  PAYMENT_STATUS_CODE = 'PSC04'*/ THEN 1 END) AS 완료
	--	FROM	BARUNSON.DBO.TB_ORDER A INNER JOIN 
	--			BARUNSON.DBO.TB_ORDER_PRODUCT C ON A.ORDER_ID = C.ORDER_ID  INNER JOIN 
	--			BARUNSON.DBO.TB_PRODUCT D ON C.PRODUCT_ID = D.PRODUCT_ID  INNER JOIN 
	--			BARUNSON.DBO.TB_TEMPLATE E ON D.TEMPLATE_ID = E.TEMPLATE_ID  INNER JOIN 
	--			BARUNSON.DBO.TB_COMMON_CODE F ON D.PRODUCT_CATEGORY_CODE = F.CODE 
	--	WHERE	NAME = @USER_NAME AND 
	--			EMAIL = @USER_EMAIL 

	--SELECT	COUNT(CASE  WHEN G.REFUND_STATUS_CODE = 'RSC01' OR G.REFUND_STATUS_CODE ='RSC02' OR G.REFUND_STATUS_CODE = 'RSC04' THEN 1 END) AS 취소환불
	--	FROM	BARUNSON.DBO.TB_ORDER A INNER JOIN 
	--			BARUNSON.DBO.TB_ORDER_PRODUCT C ON A.ORDER_ID = C.ORDER_ID  INNER JOIN 
	--			BARUNSON.DBO.TB_PRODUCT D ON C.PRODUCT_ID = D.PRODUCT_ID  INNER JOIN 
	--			BARUNSON.DBO.TB_TEMPLATE E ON D.TEMPLATE_ID = E.TEMPLATE_ID  INNER JOIN 
	--			BARUNSON.DBO.TB_COMMON_CODE F ON D.PRODUCT_CATEGORY_CODE = F.CODE  INNER JOIN 
	--			BARUNSON.DBO.TB_REFUND_INFO G ON A.ORDER_ID = G.ORDER_ID
	--	WHERE	NAME = @USER_NAME AND 
	--			EMAIL = @USER_EMAIL

 END
GO