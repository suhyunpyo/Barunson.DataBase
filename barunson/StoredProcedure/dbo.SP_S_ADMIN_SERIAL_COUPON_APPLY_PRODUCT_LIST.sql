IF OBJECT_ID (N'dbo.SP_S_ADMIN_SERIAL_COUPON_APPLY_PRODUCT_LIST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_S_ADMIN_SERIAL_COUPON_APPLY_PRODUCT_LIST
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_S_ADMIN_SERIAL_COUPON_APPLY_PRODUCT_LIST]
/*************************************************************** 
작성자	:	송태정
작성일	:	2022-01-07
DESCRIPTION	:	ADMIN - 쿠폰 적용 / 제외 상품 리스트
SPECIAL LOGIC	: 
SP_S_ADMIN_SERIAL_COUPON_APPLY_PRODUCT_LIST 
******************************************************************
MODIFICATION
******************************************************************
수정일           작업자                DESCRIPTION
==================================================================
******************************************************************/

 @COUPON_APPLY_PRODUCT_ID int
AS

 SET NOCOUNT ON
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

 SELECT * 
 FROM TB_SERIAL_COUPON_APPLY_PRODUCT A 
		INNER JOIN TB_SERIAL_APPLY_PRODUCT B ON A.PRODUCT_APPLY_ID = B.PRODUCT_APPLY_ID
 WHERE	A.PRODUCT_APPLY_ID = @COUPON_APPLY_PRODUCT_ID

GO
