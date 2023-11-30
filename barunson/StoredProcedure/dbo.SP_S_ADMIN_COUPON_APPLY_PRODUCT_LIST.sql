IF OBJECT_ID (N'dbo.SP_S_ADMIN_COUPON_APPLY_PRODUCT_LIST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_S_ADMIN_COUPON_APPLY_PRODUCT_LIST
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_S_ADMIN_COUPON_APPLY_PRODUCT_LIST]
/*************************************************************** 2379 20
작성자	:	표수현
작성일	:	2021-05-26
DESCRIPTION	:	ADMIN - 쿠폰 적용 / 제외 상품 리스트
SPECIAL LOGIC	: SP_S_ADMIN_ORDER_LIST '2021-10-01', '2021-10-10' , 'Order', 'ALL', 'PCC01_'
SP_S_ADMIN_ORDER_MEMBER '2021-05-19', '2021-05-26' , 'ALL',	'브'
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
 FROM TB_COUPON_APPLY_PRODUCT A 
		INNER JOIN TB_APPLY_PRODUCT B ON A.PRODUCT_APPLY_ID = B.PRODUCT_APPLY_ID
 WHERE	A.PRODUCT_APPLY_ID = @COUPON_APPLY_PRODUCT_ID
GO
