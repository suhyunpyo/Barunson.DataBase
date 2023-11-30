IF OBJECT_ID (N'dbo.SP_S_ADMIN_MEMBER_DETAIL', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_S_ADMIN_MEMBER_DETAIL
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_S_ADMIN_MEMBER_DETAIL]
/***************************************************************
작성자	:	표수현
작성일	:	2020-02-15
DESCRIPTION	:	ADMIN - 회원상세 
SPECIAL LOGIC	: SP_S_ADMIN_MEMBER_DETAIL 'U', 71115
******************************************************************
MODIFICATION
******************************************************************
수정일           작업자                DESCRIPTION
==================================================================
******************************************************************/
 @GUBUN CHAR(1) = 1, --  U : 회원 / G : 비회원
 @ORDER_ID INT = NULL
AS

 SET NOCOUNT ON
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

 DECLARE @USER_NAME NVARCHAR(100)
 DECLARE @USER_ID VARCHAR(50)
 DECLARE @USER_EMAIL VARCHAR(100)
 
 IF @GUBUN = 'U'
 BEGIN 

	SELECT	@USER_NAME = MAX(A.NAME),
			@USER_ID = MAX(A.USER_ID),
			@USER_EMAIL = MAX(A.EMAIL)
	FROM	TB_ORDER A INNER JOIN 
			VW_USER B ON A.USER_ID = B.USER_ID
	WHERE	A.ORDER_ID = @ORDER_ID

 END 
 
 ELSE 
 
 BEGIN 

	SELECT	@USER_NAME = MAX(NAME),
			@USER_ID = NULL,
			@USER_EMAIL = MAX(EMAIL)
	FROM	TB_ORDER
	WHERE	ORDER_ID = @ORDER_ID

 END 

 IF @GUBUN = 'U' BEGIN 

	SELECT  USER_NAME = @USER_NAME,
			USER_ID = @USER_ID,
			USER_HP = MAX(A.CELLPHONE_NUMBER),
			USER_EMAIL = @USER_EMAIL, 
			WEDDING_DATE = MAX(D.WEDDINGDATE), -- MAX(B.WEDDING_DATE), 
			REGIST_DATETIME = MAX(B.REGIST_DATETIME) 
	 FROM	TB_ORDER A INNER JOIN VW_USER B ON A.USER_ID = B.USER_ID INNER JOIN 
			TB_INVITATION C ON A.ORDER_ID = C.ORDER_ID  INNER JOIN 
			TB_INVITATION_DETAIL D ON C.INVITATION_ID = D.INVITATION_ID
	 WHERE	A.ORDER_ID = @ORDER_ID


	-- 2. 주문정보(주문번호, 상품코드, 주문금액, 쿠폰사용금액, 결재금액, 결재수단, 결재일자, 결제취소, 모초 바로가기 URL)
	-- 그중에 결재일자, 결재취소날짜 여부 알수 없음 

	SELECT	ORDER_CODE = A.ORDER_CODE, 
			ORDER_ID = A.ORDER_ID, 
			PRODUCT_ID = C.PRODUCT_ID,
			PRODUCT_CODE= C.PRODUCT_CODE,
			Product_Category_Code = CASE  c.Product_Category_Code  WHEN 'PCC01' THEN 'Mcard' WHEN 'PCC02'  THEN 'Mthanks' END ,
			ORDER_PRICE = A.ORDER_PRICE,
			쿠폰사용금액 =(SELECT distinct DISCOUNT_PRICE FROM TB_ORDER_COUPON_USE WHERE ORDER_ID = A.ORDER_ID), 
			결제금액 = ISNULL(A.PAYMENT_PRICE,0),
			A.PAYMENT_PRICE,
			PAYMENT_METHOD_CODE = A.PAYMENT_METHOD_CODE, 
			PAYMENT_STATUS_CODE = A.PAYMENT_STATUS_CODE, 
			결제방법_코드 = A.PAYMENT_METHOD_CODE, 
			결제상태_코드 = A.PAYMENT_STATUS_CODE, 
			결제방법_명 = D.CODE_NAME, 
			결제상태_명 = E.CODE_NAME,
			CODE_NAME1 = D.CODE_NAME, 
			CODE_NAME2 = E.CODE_NAME,
			REG_DATE = A.REGIST_DATETIME,
			결제일 = A.ORDER_DATETIME,
			CANCEL_DATE = (CASE WHEN E.CODE_NAME = '결제취소' OR E.CODE_NAME = '입금대기취소' THEN A.CANCEL_DATETIME ELSE NULL END),
			INVITATION_URL = 'https://www.barunsonmcard.com/m/' + H.INVITATION_URL,
			DEPOSIT_DEADLINE_DATETIME = A.DEPOSIT_DEADLINE_DATETIME,
			무통장환불접수여부 = (SELECT COUNT(*) FROM TB_REFUND_INFO WHERE ORDER_ID = A.ORDER_ID AND REFUND_TYPE_CODE = 'RTC03' AND REFUND_STATUS_CODE = 'RSC01'), --환불접수
			무통장환불완료여부 = (SELECT COUNT(*) FROM TB_REFUND_INFO WHERE ORDER_ID = A.ORDER_ID AND REFUND_TYPE_CODE = 'RTC03' AND REFUND_STATUS_CODE = 'RSC02') --환불완료
	FROM TB_ORDER A INNER JOIN TB_ORDER_PRODUCT B ON A.ORDER_ID = B.ORDER_ID INNER JOIN 
			TB_PRODUCT C ON B.PRODUCT_ID = C.PRODUCT_ID INNER JOIN 
			TB_COMMON_CODE D ON A.PAYMENT_METHOD_CODE = D.CODE AND D.CODE_GROUP = 'PAYMENT_METHOD_CODE' INNER JOIN 
			TB_COMMON_CODE E ON A.PAYMENT_STATUS_CODE = E.CODE AND E.CODE_GROUP = 'PAYMENT_STATUS_CODE' INNER JOIN 
			TB_ORDER_PRODUCT F ON A.ORDER_ID = F.ORDER_ID INNER JOIN 
			TB_INVITATION G ON A.ORDER_ID = G.ORDER_ID INNER JOIN 
			TB_INVITATION_DETAIL H ON G.INVITATION_ID = H.INVITATION_ID  
	WHERE	A.USER_ID = @USER_ID AND 
			A.NAME = @USER_NAME
	ORDER BY A.REGIST_DATETIME DESC


	-- 3. 쿠폰 정보 (사용 X)
	
	SELECT  '일반' GUBUN,
	        B.COUPON_NAME,  
			A.COUPON_ID, 
			A.USE_YN, 
			DISCOUNT_PRICE = B.Discount_Price,
			Discount_Rate = B.Discount_Rate,
			Discount_Method_Code = B.Discount_Method_Code,
			USE_DATETIME = (SELECT USE_DATETIME  FROM TB_COUPON_PUBLISH WHERE COUPON_PUBLISH_ID = A.COUPON_PUBLISH_ID),
			A.REGIST_DATETIME,
			A.RETRIEVE_DATETIME ,
			A.EXPIRATION_DATE ,
			A.COUPON_PUBLISH_ID
	 FROM TB_COUPON_PUBLISH A INNER JOIN TB_COUPON B ON A.COUPON_ID = B.COUPON_ID
	 WHERE A.USER_ID = @USER_ID 
	 UNION ALL
	 SELECT '시리얼' GUBUN,
	        B2.COUPON_NAME,  
			A2.COUPON_ID, 
			A2.USE_YN, 
			DISCOUNT_PRICE = B2.Discount_Price,
			Discount_Rate = B2.Discount_Rate,
			Discount_Method_Code = B2.Discount_Method_Code,
			USE_DATETIME = (SELECT USE_DATETIME  FROM TB_COUPON_PUBLISH WHERE COUPON_PUBLISH_ID = A2.COUPON_PUBLISH_ID),
			A2.REGIST_DATETIME,
			A2.RETRIEVE_DATETIME ,
			A2.EXPIRATION_DATE ,
			A2.COUPON_PUBLISH_ID
	 FROM TB_SERIAL_COUPON_PUBLISH A2 INNER JOIN TB_SERIAL_COUPON B2 ON A2.COUPON_ID = B2.COUPON_ID
	 WHERE A2.USER_ID = @USER_ID 
	 ORDER BY REGIST_DATETIME DESC

	-- 4. 결재 환불 정보 

	SELECT	주문번호 = A.ORDER_ID , 
			주문코드 = A.ORDER_CODE,
			결재금액 = ISNULL(A.PAYMENT_PRICE, 0) ,
			결제수단 = C.CODE_NAME,
			결제수단코드 = C.Code,
			결제상태 = D.Code_Name,
			결제상태코드 = D.Code,
			결제기관명 = A.FINANCE_NAME,
			계좌정보 = A.ACCOUNT_NUMBER,
			주문일 = A.REGIST_DATETIME,
			결제일 = A.PAYMENT_DATETIME,
			환불금액 = (SELECT top 1  REFUND_PRICE FROM TB_REFUND_INFO WHERE ORDER_ID = A.ORDER_ID),
			환불날짜= (SELECT top 1  REFUND_DATETIME FROM TB_REFUND_INFO WHERE ORDER_ID = A.ORDER_ID),
			환불타입_명 = (
							SELECT  top 1 F.CODE_NAME 
							FROM TB_REFUND_INFO E INNER JOIN 
								 TB_COMMON_CODE F ON E.REFUND_TYPE_CODE = F.CODE 
							WHERE F.CODE_GROUP = 'REFUND_TYPE_CODE' AND 
								  E.ORDER_ID = A.ORDER_ID ),
			환불타입_코드 = (
								SELECT  top 1 F.CODE 
								FROM TB_REFUND_INFO E INNER JOIN 
									 TB_COMMON_CODE F ON E.REFUND_TYPE_CODE = F.CODE 
								WHERE F.CODE_GROUP = 'REFUND_TYPE_CODE' AND 
									  E.ORDER_ID = A.ORDER_ID 
							),
			환불상태_명 = (
							SELECT  top 1 F.CODE_NAME 
							FROM TB_REFUND_INFO E INNER JOIN 
								 TB_COMMON_CODE F ON E.REFUND_STATUS_CODE = F.CODE 
							WHERE F.CODE_GROUP = 'REFUND_STATUS_CODE' AND 
								  E.ORDER_ID = A.ORDER_ID ),
			환불상태_코드 = (
								SELECT  top 1 F.CODE 
								FROM TB_REFUND_INFO E INNER JOIN 
									 TB_COMMON_CODE F ON E.REFUND_STATUS_CODE = F.CODE 
								WHERE F.CODE_GROUP = 'REFUND_STATUS_CODE' AND 
									  E.ORDER_ID = A.ORDER_ID 
							),
			DEPOSIT_DEADLINE_DATETIME = A.DEPOSIT_DEADLINE_DATETIME,
			INVITATION_URL = 'https://www.barunsonmcard.com/m/' + H.INVITATION_URL
	FROM	TB_ORDER A INNER JOIN 
			TB_COMMON_CODE C ON A.PAYMENT_METHOD_CODE = C.CODE AND C.CODE_GROUP = 'PAYMENT_METHOD_CODE' INNER JOIN 
			TB_COMMON_CODE D ON A.Payment_Status_Code = D.CODE AND D.CODE_GROUP = 'Payment_Status_Code'  INNER JOIN 
			TB_INVITATION G ON A.ORDER_ID = G.ORDER_ID INNER JOIN 
			TB_INVITATION_DETAIL H ON G.INVITATION_ID = H.INVITATION_ID  
	WHERE	A.USER_ID = @USER_ID  AND A.NAME = @USER_NAME
	ORDER BY A.ORDER_DATETIME DESC

	-- 5. 고객 상담
	SELECT * 
	FROM VW_USER_QNA 
	WHERE  USERID = @USER_ID
	ORDER BY REGIST_DATETIME DESC

 END 
 
 ELSE BEGIN

	SELECT  USER_NAME = @USER_NAME,
			USER_ID = @USER_ID,
			USER_HP = CELLPHONE_NUMBER,
			USER_EMAIL = @USER_EMAIL, 
			WEDDING_DATE = '',
			REGIST_DATETIME = ''
	FROM	TB_ORDER A  INNER JOIN 
			TB_INVITATION C ON A.ORDER_ID = C.ORDER_ID  INNER JOIN 
			TB_INVITATION_DETAIL D ON C.INVITATION_ID = D.INVITATION_ID
	WHERE	A.ORDER_ID = @ORDER_ID

	
	-- 2. 주문정보(주문번호, 상품코드, 주문금액, 쿠폰사용금액, 결재금액, 결재수단, 결재일자, 결제취소, 모초 바로가기 URL)
	-- 그중에 결재일자, 결재취소날짜 여부 알수 없음 

	 SELECT ORDER_CODE = A.ORDER_CODE, 
			ORDER_ID = A.ORDER_ID, 
			PRODUCT_ID = C.PRODUCT_ID,
			PRODUCT_CODE= C.PRODUCT_CODE,
			Product_Category_Code = CASE  c.Product_Category_Code  WHEN 'PCC01' THEN 'Mcard' WHEN 'PCC02'  THEN 'Mthanks' END ,
			ORDER_PRICE = A.ORDER_PRICE,
			쿠폰사용금액 =(SELECT distinct DISCOUNT_PRICE FROM TB_ORDER_COUPON_USE WHERE ORDER_ID = A.ORDER_ID), 
			결제금액 = ISNULL(A.PAYMENT_PRICE,0),
			A.PAYMENT_PRICE,
			PAYMENT_METHOD_CODE = A.PAYMENT_METHOD_CODE, 
			PAYMENT_STATUS_CODE = A.PAYMENT_STATUS_CODE, 
			결제방법_코드 = A.PAYMENT_METHOD_CODE, 
			결제상태_코드 = A.PAYMENT_STATUS_CODE, 
			결제방법_명 = D.CODE_NAME, 
			결제상태_명 = E.CODE_NAME,
			CODE_NAME1 = D.CODE_NAME, 
			CODE_NAME2 = E.CODE_NAME,
			REG_DATE = A.REGIST_DATETIME,
			결제일 = A.ORDER_DATETIME,
			CANCEL_DATE = (CASE WHEN E.CODE_NAME = '결제취소' OR E.CODE_NAME = '입금대기취소' THEN A.CANCEL_DATETIME ELSE NULL END),
			INVITATION_URL = 'https://www.barunsonmcard.com/m/' + H.INVITATION_URL,
			DEPOSIT_DEADLINE_DATETIME = A.DEPOSIT_DEADLINE_DATETIME,
			무통장환불접수여부 = (SELECT COUNT(*) FROM TB_REFUND_INFO WHERE ORDER_ID = A.ORDER_ID AND REFUND_TYPE_CODE = 'RTC03' AND REFUND_STATUS_CODE = 'RSC01'), --환불접수
			무통장환불완료여부 = (SELECT COUNT(*) FROM TB_REFUND_INFO WHERE ORDER_ID = A.ORDER_ID AND REFUND_TYPE_CODE = 'RTC03' AND REFUND_STATUS_CODE = 'RSC02')  --환불완료
		FROM TB_ORDER A INNER JOIN TB_ORDER_PRODUCT B ON A.ORDER_ID = B.ORDER_ID INNER JOIN 
			TB_PRODUCT C ON B.PRODUCT_ID = C.PRODUCT_ID INNER JOIN 
			TB_COMMON_CODE D ON A.PAYMENT_METHOD_CODE = D.CODE AND D.CODE_GROUP = 'PAYMENT_METHOD_CODE' INNER JOIN 
			TB_COMMON_CODE E ON A.PAYMENT_STATUS_CODE = E.CODE AND E.CODE_GROUP = 'PAYMENT_STATUS_CODE' INNER JOIN 
			TB_ORDER_PRODUCT F ON A.ORDER_ID = F.ORDER_ID INNER JOIN 
			TB_INVITATION G ON A.ORDER_ID = G.ORDER_ID INNER JOIN 
			TB_INVITATION_DETAIL H ON G.INVITATION_ID = H.INVITATION_ID  
		WHERE	A.EMAIL = @USER_EMAIL 
				AND A.NAME = @USER_NAME  
				AND (A.USER_ID = '' OR A.USER_ID IS NULL)
		ORDER BY A.REGIST_DATETIME DESC

	-- 3. 쿠폰 정보 

	 SELECT '일반' GUBUN,
	        D.COUPON_NAME,  
			D.COUPON_ID, 
			C.USE_YN, 
			DISCOUNT_PRICE = D.DISCOUNT_PRICE,
			DISCOUNT_RATE = D.DISCOUNT_RATE,
			DISCOUNT_METHOD_CODE = D.DISCOUNT_METHOD_CODE,
			C.USE_DATETIME, 
			D.REGIST_DATETIME,
			C.RETRIEVE_DATETIME,
			C.EXPIRATION_DATE,
			C.COUPON_PUBLISH_ID
	 FROM TB_ORDER A INNER JOIN 
		  TB_ORDER_COUPON_USE B ON A.ORDER_ID = B.ORDER_ID INNER JOIN
		  TB_COUPON_PUBLISH C ON B.COUPON_PUBLISH_ID = C.COUPON_PUBLISH_ID INNER JOIN 
		  TB_COUPON D ON C.COUPON_ID = D.COUPON_ID
	 WHERE	A.EMAIL = @USER_EMAIL 
			AND A.NAME = @USER_NAME
			AND (A.USER_ID = '' OR A.USER_ID IS NULL)
	 UNION
	 SELECT '시리얼' GUBUN,
	        D2.COUPON_NAME,  
			D2.COUPON_ID, 
			C2.USE_YN, 
			DISCOUNT_PRICE = D2.DISCOUNT_PRICE,
			DISCOUNT_RATE = D2.DISCOUNT_RATE,
			DISCOUNT_METHOD_CODE = D2.DISCOUNT_METHOD_CODE,
			C2.USE_DATETIME, 
			D2.REGIST_DATETIME,
			C2.RETRIEVE_DATETIME,
			C2.EXPIRATION_DATE,
			C2.COUPON_PUBLISH_ID
	 FROM TB_ORDER A2 INNER JOIN 
		  TB_ORDER_SERIAL_COUPON_USE B2 ON A2.ORDER_ID = B2.ORDER_ID INNER JOIN
		  TB_SERIAL_COUPON_PUBLISH C2 ON B2.COUPON_PUBLISH_ID = C2.COUPON_PUBLISH_ID INNER JOIN 
		  TB_SERIAL_COUPON D2 ON C2.COUPON_ID = D2.COUPON_ID
	 WHERE	A2.EMAIL = @USER_EMAIL 
			AND A2.NAME = @USER_NAME
			AND (A2.USER_ID = '' OR A2.USER_ID IS NULL)
	ORDER BY REGIST_DATETIME DESC

	-- 4. 결재 환불 정보 

	SELECT	주문번호 = A.ORDER_ID , 
			주문코드 = A.ORDER_CODE,
			결재금액 = ISNULL(A.PAYMENT_PRICE, 0) ,
			결제수단 = C.CODE_NAME,
			결제수단코드 = C.Code,
			결제상태 = D.Code_Name,
			결제상태코드 = D.Code,
			결제기관명 = A.FINANCE_NAME,
			계좌정보 = A.ACCOUNT_NUMBER,
			주문일 = A.Regist_DateTime,
			결제일 = A.PAYMENT_DATETIME,
			환불금액 = (SELECT top 1 REFUND_PRICE FROM TB_REFUND_INFO WHERE ORDER_ID = A.ORDER_ID),
			환불날짜= (SELECT  top 1 REFUND_DATETIME FROM TB_REFUND_INFO WHERE ORDER_ID = A.ORDER_ID),
			환불타입_명 = (
							SELECT  top 1  F.CODE_NAME 
							FROM TB_REFUND_INFO E INNER JOIN 
								 TB_COMMON_CODE F ON E.REFUND_TYPE_CODE = F.CODE 
							WHERE F.CODE_GROUP = 'REFUND_TYPE_CODE' AND 
								  E.ORDER_ID = A.ORDER_ID ),
			환불타입_코드 = (
								SELECT  top 1  F.CODE 
								FROM TB_REFUND_INFO E INNER JOIN 
									 TB_COMMON_CODE F ON E.REFUND_TYPE_CODE = F.CODE 
								WHERE F.CODE_GROUP = 'REFUND_TYPE_CODE' AND 
									  E.ORDER_ID = A.ORDER_ID 
							),
			환불상태_명 = (
							SELECT  top 1  F.CODE_NAME 
							FROM TB_REFUND_INFO E INNER JOIN 
								 TB_COMMON_CODE F ON E.REFUND_STATUS_CODE = F.CODE 
							WHERE F.CODE_GROUP = 'REFUND_STATUS_CODE' AND 
								  E.ORDER_ID = A.ORDER_ID ),
			환불상태_코드 = (
								SELECT  top 1  F.CODE 
								FROM TB_REFUND_INFO E INNER JOIN 
									 TB_COMMON_CODE F ON E.REFUND_STATUS_CODE = F.CODE 
								WHERE F.CODE_GROUP = 'REFUND_STATUS_CODE' AND 
									  E.ORDER_ID = A.ORDER_ID 
							),
			DEPOSIT_DEADLINE_DATETIME = A.DEPOSIT_DEADLINE_DATETIME,
			INVITATION_URL = 'https://www.barunsonmcard.com/m/' + H.INVITATION_URL
	FROM	TB_ORDER A INNER JOIN 
			TB_COMMON_CODE C ON A.PAYMENT_METHOD_CODE = C.CODE AND C.CODE_GROUP = 'PAYMENT_METHOD_CODE' INNER JOIN 
			TB_COMMON_CODE D ON A.PAYMENT_STATUS_CODE = D.CODE AND D.CODE_GROUP = 'PAYMENT_STATUS_CODE' INNER JOIN 
			TB_INVITATION G ON A.ORDER_ID = G.ORDER_ID INNER JOIN 
			TB_INVITATION_DETAIL H ON G.INVITATION_ID = H.INVITATION_ID  
	WHERE	A.EMAIL = @USER_EMAIL AND A.NAME = @USER_NAME  
			AND (A.USER_ID = '' OR A.USER_ID IS NULL)
	ORDER BY A.ORDER_DATETIME DESC

	-- 5. 고객 상담

	SELECT * 
	FROM VW_USER_QNA 
	WHERE EMAIL = @USER_EMAIL AND NAME = @USER_NAME
	ORDER BY REGIST_DATETIME DESC

 END 

 
 IF @GUBUN = 'U' BEGIN 

	-- 6. 관리자 메모 
	SELECT	A.MEMO_ID, A.CONTENT,  A.REGIST_USER_ID, A.REGIST_DATETIME, B.ADMIN_NAME
	FROM	TB_ADMIN_MEMO A INNER JOIN 
			VW_ADMIN B ON A.REGIST_USER_ID = B.ADMIN_ID
	WHERE	A.ORDER_ID IN ( SELECT ORDER_ID FROM TB_ORDER WHERE USER_ID = @USER_ID)
	ORDER BY A.REGIST_DATETIME DESC

 END ELSE BEGIN 

	-- 6. 관리자 메모 
	SELECT	A.MEMO_ID, A.CONTENT,  A.REGIST_USER_ID, A.REGIST_DATETIME, B.ADMIN_NAME
	FROM	TB_ADMIN_MEMO A INNER JOIN 
			VW_ADMIN B ON A.REGIST_USER_ID = B.ADMIN_ID
	WHERE	A.ORDER_ID in (select order_id from TB_ORDER where EMAIL = @USER_EMAIL AND NAME = @USER_NAME)
	ORDER BY A.REGIST_DATETIME DESC

 END 
GO