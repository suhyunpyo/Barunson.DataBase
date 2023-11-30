IF OBJECT_ID (N'dbo.SP_S_ORDER_TOTAL_PRICE', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_S_ORDER_TOTAL_PRICE
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_S_ORDER_TOTAL_PRICE]
/***************************************************************
작성자	:	표수현
******************************************************************
MODIFICATION
******************************************************************
수정일           작업자                DESCRIPTION
==================================================================
******************************************************************/
AS

 SET NOCOUNT ON
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
 
 DECLARE @신용카드토탈결재금액 INT

 DECLARE @계좌이체토탈결재금액 INT

 DECLARE @무통장토탈결재금액 INT

 SELECT @신용카드토탈결재금액 = SUM(PAYMENT_PRICE) 
 FROM TB_ORDER A 
	  INNER JOIN TB_COMMON_CODE B ON A.PAYMENT_STATUS_CODE = B.CODE 
	  INNER JOIN TB_COMMON_CODE C ON A.PAYMENT_METHOD_CODE = C.CODE 
 WHERE B.CODE_GROUP = 'PAYMENT_STATUS_CODE' 
		AND C.CODE_GROUP = 'PAYMENT_METHOD_CODE' 
		AND A.PAYMENT_STATUS_CODE = 'PSC02' 
		AND ISNULL(A.PAYMENT_PRICE, 0) > 0 
		AND A.PAYMENT_METHOD_CODE = 'PMC01'

 SELECT @무통장토탈결재금액 = SUM(PAYMENT_PRICE) 
 FROM TB_ORDER A 
	  INNER JOIN TB_COMMON_CODE B ON A.PAYMENT_STATUS_CODE = B.CODE  
	  INNER JOIN TB_COMMON_CODE C ON A.PAYMENT_METHOD_CODE = C.CODE 
 WHERE B.CODE_GROUP = 'PAYMENT_STATUS_CODE' 
		AND C.CODE_GROUP = 'PAYMENT_METHOD_CODE' 
		AND A.PAYMENT_STATUS_CODE = 'PSC02' 
		AND ISNULL(A.PAYMENT_PRICE, 0) > 0 
		AND A.PAYMENT_METHOD_CODE = 'PMC02'


 SELECT @계좌이체토탈결재금액 = SUM(PAYMENT_PRICE) 
 FROM TB_ORDER A 
	  INNER JOIN TB_COMMON_CODE B ON A.PAYMENT_STATUS_CODE = B.CODE  
	  INNER JOIN TB_COMMON_CODE C ON A.PAYMENT_METHOD_CODE = C.CODE 
 WHERE B.CODE_GROUP = 'PAYMENT_STATUS_CODE' 
		AND C.CODE_GROUP = 'PAYMENT_METHOD_CODE' 
		AND A.PAYMENT_STATUS_CODE = 'PSC02' 
		AND ISNULL(A.PAYMENT_PRICE, 0) > 0 
		AND A.PAYMENT_METHOD_CODE = 'PMC03'

 SELECT 토탈결재금액 = @신용카드토탈결재금액 + @계좌이체토탈결재금액 + @무통장토탈결재금액 , 
		@신용카드토탈결재금액 AS '신용카드토탈결재금액' ,  
		@계좌이체토탈결재금액  AS '계좌이체토탈결재금액', 
		@무통장토탈결재금액  AS '무통장토탈결재금액'
GO