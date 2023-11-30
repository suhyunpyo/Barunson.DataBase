IF OBJECT_ID (N'dbo.SP_S_ADMIN_SERIAL_COUPON', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_S_ADMIN_SERIAL_COUPON
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_S_ADMIN_SERIAL_COUPON]
/***************************************************************
작성자	:	송태정
작성일	:	2022-01-06
DESCRIPTION	:	ADMIN - 시리얼 쿠폰 전체 리스트 
SPECIAL LOGIC	: 
******************************************************************
MODIFICATION
******************************************************************
수정일           작업자                DESCRIPTION
==================================================================
SP_S_ADMIN_SERIAL_COUPON
******************************************************************/
 @SEARCHTXT VARCHAR(100) = NULL -- 검색어 

AS

 SET NOCOUNT ON
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

 IF @SEARCHTXT IS NOT NULL AND @SEARCHTXT <> '' BEGIN 
	
	SELECT COUPON_ID = A.COUPON_ID,
		   COUPON_NAME = A.COUPON_NAME,
		   COUPON_TYPE_NAME = B.CODE_NAME ,
		   COUPON_TYPE_CODE,
		   DISCOUNT_PRICE = A.DISCOUNT_PRICE,
		   DISCOUNT_RATE = A.DISCOUNT_RATE,
		   DISCOUNTFLAG = CASE  DISCOUNT_METHOD_CODE WHEN 'DMC02' THEN '%' ELSE '원' END,
		   PUBLISH_CNT = (SELECT COUNT(1) FROM TB_SERIAL_COUPON_PUBLISH WHERE COUPON_ID = A.COUPON_ID),
		   USE_CNT = (SELECT COUNT(1) FROM TB_SERIAL_COUPON_PUBLISH WHERE COUPON_ID = A.COUPON_ID AND USE_YN = 'Y'),
		   DIS_USE_CNT = (SELECT COUNT(1) FROM TB_SERIAL_COUPON_PUBLISH WHERE COUPON_ID = A.COUPON_ID AND USE_YN = 'N' AND Retrieve_DateTime IS NULL),
		   RETRIEVE_CNT = (SELECT COUNT(1) FROM TB_SERIAL_COUPON_PUBLISH WHERE COUPON_ID = A.COUPON_ID AND Retrieve_DateTime IS NOT NULL),
		   REGIST_DATETIME = A.REGIST_DATETIME
	FROM   TB_SERIAL_COUPON A INNER JOIN 
		   TB_COMMON_CODE B ON A.Coupon_Type_Code = B.CODE
	WHERE  B.CODE_GROUP = 'Coupon_Type_Code' AND
	       A.COUPON_NAME LIKE  '%' + @SEARCHTXT + '%' 
	ORDER BY REGIST_DATETIME DESC

  END ELSE BEGIN

	SELECT COUPON_ID = A.COUPON_ID,
		   COUPON_NAME = A.COUPON_NAME,
		   COUPON_TYPE_NAME = B.CODE_NAME,
		   COUPON_TYPE_CODE,
		   DISCOUNT_PRICE = A.DISCOUNT_PRICE,
		   DISCOUNT_RATE = A.DISCOUNT_RATE,
		   DISCOUNTFLAG = CASE  DISCOUNT_METHOD_CODE WHEN 'DMC02' THEN '%' ELSE '원' END,
		   PUBLISH_CNT = (SELECT COUNT(1) FROM TB_SERIAL_COUPON_PUBLISH WHERE COUPON_ID = A.COUPON_ID),
		   USE_CNT = (SELECT COUNT(1) FROM TB_SERIAL_COUPON_PUBLISH WHERE COUPON_ID = A.COUPON_ID AND USE_YN = 'Y'),
		   DIS_USE_CNT = (SELECT COUNT(1) FROM TB_SERIAL_COUPON_PUBLISH WHERE COUPON_ID = A.COUPON_ID AND USE_YN = 'N' AND Retrieve_DateTime IS NULL),
		   RETRIEVE_CNT = (SELECT COUNT(1) FROM TB_SERIAL_COUPON_PUBLISH WHERE COUPON_ID = A.COUPON_ID AND Retrieve_DateTime IS NOT NULL),
		   REGIST_DATETIME = A.REGIST_DATETIME
	FROM   TB_SERIAL_COUPON A INNER JOIN 
		   TB_COMMON_CODE B ON A.Coupon_Type_Code = B.CODE
    WHERE  B.CODE_GROUP = 'Coupon_Type_Code' 
	ORDER BY REGIST_DATETIME DESC

  END
GO