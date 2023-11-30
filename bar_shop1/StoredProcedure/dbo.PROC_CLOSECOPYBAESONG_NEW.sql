IF OBJECT_ID (N'dbo.PROC_CLOSECOPYBAESONG_NEW', N'P') IS NOT NULL DROP PROCEDURE dbo.PROC_CLOSECOPYBAESONG_NEW
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PROC_CLOSECOPYBAESONG_NEW]
/***************************************************************
작성자	:	표수현
작성일	:	2022-03-15
DESCRIPTION	:  주문건 송장번호 부여 	
SPECIAL LOGIC	: 
******************************************************************
MODIFICATION
******************************************************************
수정일           작업자                DESCRIPTION
==================================================================
******************************************************************/
 @ORDER_SEQ INT,
 @DEL_ID INT
AS
BEGIN
	DECLARE @DEL_CODE VARCHAR(15)
	--DECLARE @DELIVERY_COMPANY_SHORT_NAME AS VARCHAR(10)
    --SELECT @DELIVERY_COMPANY_SHORT_NAME = CODE FROM DELIVERY_CODE WHERE USE_YN = 'Y'
	
	EXEC [DBO].[SP_CJ_DELEVERY_NEW] 'DELIVERY_INFO_DELCODE|DELIVERY_INFO|', @ORDER_SEQ, @DEL_ID, 'LT', @DEL_CODE OUTPUT
	
END
GO
