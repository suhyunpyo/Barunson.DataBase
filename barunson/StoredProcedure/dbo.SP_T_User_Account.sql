IF OBJECT_ID (N'dbo.SP_T_User_Account', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_T_User_Account
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_T_User_Account]
/***************************************************************
작성자	:	표수현
작성일	:	2020-02-15
DESCRIPTION	:	무통장입금완료 처리 
SPECIAL LOGIC	: SP_T_User_Account  @ORDER_CODE = 'M2108240053' , @RESULTMSG = '입금완료'

select PAYMENT_STATUS_CODE from  TB_ORDER where ORDER_CODE = 'M2108240053'
******************************************************************
MODIFICATION
******************************************************************
수정일           작업자                DESCRIPTION
==================================================================
******************************************************************/
 @ORDER_CODE VARCHAR(20),
 @RESULTMSG VARCHAR(20),
 @PAYMENT_PATH NVARCHAR(100) -- PC / M

AS
 
 SET NOCOUNT ON
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
 
 DECLARE @무통장입금주문건수 INT = 0
 
 SELECT @무통장입금주문건수 = COUNT(1) FROM TEST WHERE ORDER_CODE = @ORDER_CODE

 IF @무통장입금주문건수 = 0 BEGIN 

	INSERT TEST(ORDER_CODE, RESULTMSG, REG_DATE)
	VALUES (@ORDER_CODE,@RESULTMSG, GETDATE())

	 UPDATE TB_ORDER
	 SET PAYMENT_STATUS_CODE = 'PSC02' , Payment_DateTime = GETDATE(), --ORDER_DATETIME = GETDATE(),
	 PAYMENT_PATH = @PAYMENT_PATH
	 WHERE ORDER_CODE = @ORDER_CODE

	 EXEC BARUNSON.DBO.SP_T_SEND_ORDER_BIZTALK @ORDER_CODE, @PAYMENT_PATH
 END 
GO
