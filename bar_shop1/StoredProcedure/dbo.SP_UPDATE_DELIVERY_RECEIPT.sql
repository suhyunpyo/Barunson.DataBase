IF OBJECT_ID (N'dbo.SP_UPDATE_DELIVERY_RECEIPT', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_UPDATE_DELIVERY_RECEIPT
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_UPDATE_DELIVERY_RECEIPT]
/***************************************************************
작성자	:	표수현
작성일	:	2022-11-22
DESCRIPTION	:  발송완료된 주문건을 CJ API 호출한 결과 이후의 로직
SPECIAL LOGIC	: 
******************************************************************
MODIFICATION
******************************************************************
수정일           작업자                DESCRIPTION
==================================================================
******************************************************************/
 @GUBUN CHAR(1) = 'S',
 @KIND varchar(100) = null,
 @ORDER_SEQ  VARCHAR(20),
 @ORDER_TABLE_NAME  VARCHAR(50),
 @INVC_NO VARCHAR(20),
 @RESULT_CODE VARCHAR(4),
 @RESULT_MSG NVARCHAR(500)   
AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 

BEGIN

	--IF @GUBUN = 'S' BEGIN 
		
		IF @ORDER_TABLE_NAME = 'CUSTOM_ORDER' BEGIN
                
            UPDATE  DELIVERY_INFO_DELCODE
            SET     ISHJ = '1'
            WHERE   ORDER_SEQ = @ORDER_SEQ
            AND     DELIVERY_CODE_NUM = @INVC_NO

        END ELSE IF @ORDER_TABLE_NAME = 'CUSTOM_SAMPLE_ORDER' BEGIN
                
            UPDATE  CUSTOM_SAMPLE_ORDER
            SET     ISHJ = '1'
            WHERE   SAMPLE_ORDER_SEQ = @ORDER_SEQ
            AND     DELIVERY_CODE_NUM = @INVC_NO

        END ELSE IF @ORDER_TABLE_NAME = 'CUSTOM_ETC_ORDER' BEGIN
                
            UPDATE  CUSTOM_ETC_ORDER
            SET     ISHJ = '1'
            WHERE   ORDER_SEQ = @ORDER_SEQ
            AND     DELIVERY_CODE = @INVC_NO

        END


	--END
			--/* 로그 기록 */
            EXEC SP_INSERT_DELIVERY_SEND_LOG @ORDER_SEQ, @ORDER_TABLE_NAME, @INVC_NO, @RESULT_CODE, @RESULT_MSG, '', '' 

			insert CJ_API_LOG(ORDER_SEQ, KIND, RESULT_CODE, RESULT_MSG,REG_DATE)
			values (@ORDER_SEQ, @KIND, @RESULT_CODE, @RESULT_MSG, GETDATE())


			--DECLARE @MSG VARCHAR(4000) 

			--SET @MSG =  '주문번호: ' + @ORDER_SEQ + ' API 전송 완료'

			--DECLARE @API전송개수 INT

			--SELECT  @API전송개수 = COUNT(*)
			--FROM DELIVERY_SEND_LOG
			--WHERE RESULT_MSG = 'API 전송 완료'

			--IF @API전송개수 = 1 BEGIN 

			--	EXEC BAR_SHOP1.DBO.PROC_SMS_MMS_SEND '', 0, '', @MSG, '', '1644-0708', 1, 'AA^010-2227-6303', 0, '', 0, 'SB', '', '', '', '', '', '','', '','',''  
			--END 

END


GO
